//
//  ViewController.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 21.03.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit
import AudioKit
import AudioKitUI
import GoogleMobileAds

class InstrumentViewController: UIViewController, SettingsViewControllerDelegate {
     
    
    @IBOutlet weak var instrumentImageView: UIImageView!
    @IBOutlet weak var mainContainerView: UIView!
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var frequencyLabel: FrequencyLabel!
    @IBOutlet weak var microphoneButton: UIButton!
    @IBOutlet weak var displayView: UIView!
    @IBOutlet weak var fftButton: DisplayModeButton!
    @IBOutlet weak var amplitudeButton: DisplayModeButton!
    @IBOutlet weak var tuningForkButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    var bannerView: GADBannerView!
    
    var conductor = Conductor.sharedInstance
    var midiChannelIn: MIDIChannel = 0
    var omniMode = true

    var mic: AKMicrophone!
    var frequencyTracker: AKFrequencyTracker!
    var silence: AKBooster!
    var bandPass: AKBandPassButterworthFilter!
    var amplitudeTracker: AKAmplitudeTracker!
    var fftTap: AKFFTTap!
    var timer: Timer?

    var smoothArray = [Float]()


    private var embeddedGaugeViewController: GaugeViewController!
    private var embeddedVolumeMeterController: VolumeMeterViewController!
    private var embeddedDeviationMeterController: DeviationMeterViewController!
    private var embeddedBridgeViewController: BridgeViewController!
    private var embeddedDisplayViewController: DisplayViewController!
    private var settingsViewController: SettingsViewController!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        let instrument = Utils().getInstrument()

        if instrument == nil {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "settingsSegue", sender: nil)
            }
        } else {
            let image = instrument?.symbol
            instrumentImageView.image = image
        }

        
        if UIDevice.current.userInterfaceIdiom == .pad {
            mainContainerView.layer.cornerRadius = 0.05*mainContainerView.bounds.size.width
            headerView.roundCorners([.topLeft, .topRight], radius: mainContainerView.layer.cornerRadius)
            mainContainerView.dropShadow()
        }
        
        circleView.layer.cornerRadius = 0.5*circleView.frame.size.width
        displayView.roundCorners([.bottomLeft, .bottomRight], radius: 0.15*circleView.layer.cornerRadius)

        fftButton.text = "FFT"
        amplitudeButton.text = "Amplitude"

        
        embeddedBridgeViewController.delegate = self
        conductor.addMidiListener(listener: self)

        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { (notification) in
            print("app did become active")
        }

        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { (notification) in
            print("app did enter background")

            self.disableAudio()
        }

        setAudioMode()
        
        handleAd()
    }
    
    func didChangeInstrument() {
        
        let instrument = Utils().getInstrument()
        let image = instrument?.symbol
        instrumentImageView.image = image
        
        DispatchQueue.main.async {
            self.embeddedBridgeViewController.loadElements()
        }
        
    }
    
    func handleAd() {
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) else { return }
        
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.adUnitID = dict.value(forKey: "GADApplicationIdentifier") as? String
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.insertSubview(bannerView, aboveSubview: displayView)
        bannerView.autoPinEdge(.top, to: .top, of: displayView)
        bannerView.autoAlignAxis(.vertical, toSameAxisOf: displayView)
        
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }

    func setAudioMode() {
        
        embeddedDisplayViewController.clear()

        do {
            try AudioKit.stop()
        } catch {
            AKLog("AudioKit did not start!")
        }
        

        if mode == .play {
            
            if mic != nil {
                mic.disconnectOutput()
            }
            
            AKSettings.audioInputEnabled = false
            AudioKit.output = conductor.reverbMixer
            embeddedDisplayViewController.plotFFTFromSound(reverbMixer: conductor.reverbMixer)
            
        } else if mode == .record {
            
            AKSettings.audioInputEnabled = true
            AudioKit.output = nil

            mic = AKMicrophone()
            let micCopy = AKBooster(mic)
            
            let frequencies = Utils().getCurrentFrequencies()
            let sortedFreq = frequencies.sorted(by: { $0 < $1 })
            let minFreq: Float = sortedFreq.first ?? 0
            let maxFreq: Float = sortedFreq.last ?? 0
            let avrFreq = 0.5 * (minFreq + maxFreq)
            let bandwidth = maxFreq - minFreq
 
            bandPass = AKBandPassButterworthFilter(micCopy)
            bandPass.centerFrequency = avrFreq
            bandPass.bandwidth = Double(bandwidth)
            frequencyTracker = AKFrequencyTracker(bandPass)
            
            silence = AKBooster(frequencyTracker, gain: 0)
            amplitudeTracker = AKAmplitudeTracker(micCopy)
            fftTap = AKFFTTap.init(micCopy)
            let mixer = AKMixer(silence, amplitudeTracker)
            //mixer.volume = 0.0 // silence sound feeback on loudspeaker
            AudioKit.output = mixer
            
            embeddedDisplayViewController.plotAmplitude(trackedAmplitude: self.amplitudeTracker)
            embeddedDisplayViewController.plotFFT(fftTap: fftTap, amplitudeTracker: amplitudeTracker)

            
        } else if mode == .silent {
            
            return
        }
        
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? GaugeViewController,
            segue.identifier == "gaugeSegue" {
            embeddedGaugeViewController = vc
        }
        if let vc = segue.destination as? VolumeMeterViewController,
            segue.identifier == "volumeMeterSegue" {
            embeddedVolumeMeterController = vc
        }
        if let vc = segue.destination as? DeviationMeterViewController,
            segue.identifier == "deviationMeterSegue" {
            embeddedDeviationMeterController = vc
        }
        if let vc = segue.destination as? BridgeViewController,
            segue.identifier == "bridgeSegue" {
            embeddedBridgeViewController = vc
        }
        if let vc = segue.destination as? DisplayViewController,
            segue.identifier == "displaySegue" {
            embeddedDisplayViewController = vc
        }
        if let vc = segue.destination as? SettingsViewController,
            segue.identifier == "settingsSegue" {
            settingsViewController = vc
            guard let backgroundColor = self.view.backgroundColor else { return }
            settingsViewController.backgroundColor = backgroundColor
            settingsViewController.closeButton.backgroundColor = headerView.backgroundColor
            
            settingsViewController.settingsDelegate = self
        }
        
    }
    
    

    
    fileprivate func disableAudio() {
        mode = .silent
        handleMicrophoneButton()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    
    @objc func updateUI() {

        if frequencyTracker == nil { return }

        
        if frequencyTracker.amplitude > 0.05 {
            
//            let frequency: Float = 251 - Float.random(in: 0..<10)//Float(frequencyTracker.frequency)
//            embeddedGaugeViewController.displayFrequency(frequency: frequency, soundGenerator: false)
//            return
            
            let frequency: Float = Float(frequencyTracker.frequency)
            
            //if frequency < Float(bandPass.centerFrequency - bandPass.bandwidth) || frequency > Float(bandPass.centerFrequency + bandPass.bandwidth) { return }
            
            frequencyLabel.frequency = frequency
            // Gauge
            embeddedGaugeViewController.displayFrequency(frequency: frequency, soundGenerator: false)
            embeddedVolumeMeterController.displayVolume(volume: frequencyTracker.amplitude)
            
            embeddedDeviationMeterController.displayDeviation(frequency: frequency)
            
  
//            smoothArray.append(frequency)
//            //print("\(frequency) --\(smoothArray.avg()) -- \(smoothArray.std())")
//
//            if smoothArray.count > 5 {
//                smoothArray.remove(at: 0)
//            }
//
//            if smoothArray.count > 0 && smoothArray.std() < 2.0 {
//                // Header
//                frequencyLabel.frequency = frequency
//                // Gauge
//                embeddedGaugeViewController.displayFrequency(frequency: frequency, soundGenerator: false)
//                embeddedVolumeMeterController.displayVolume(volume: frequencyTracker.amplitude)
//
//                embeddedDeviationMeterController.displayDeviation(frequency: frequency)
//
//                //print("\(frequency) --\(smoothArray.avg()) -- \(smoothArray.std())")
//            } else {
//                print("\(frequency) --\(smoothArray.avg()) -- \(smoothArray.std())")
//            }

        } else {
            embeddedVolumeMeterController.displayVolume(volume: 0.1)
        }
    }
    
    
    @IBAction func fftButtonTouched(_ sender: Any) {
        fftButton.setImage(UIImage(named: "btnActive"), for: .normal)
        amplitudeButton.setImage(UIImage(named: "btnPassive"), for: .normal)
        embeddedDisplayViewController.setDisplayMode(mode: .fft)
    }
    
    @IBAction func amplitudeButtonTouched(_ sender: Any) {
        amplitudeButton.setImage(UIImage(named: "btnActive"), for: .normal)
        fftButton.setImage(UIImage(named: "btnPassive"), for: .normal)
        embeddedDisplayViewController.setDisplayMode(mode: .amplitude)
    }
    
    @IBAction func tuningforkButtonTouched(_ sender: Any) {
        
        let buttons = embeddedBridgeViewController.buttonCollection
        
        var activeButton: UIButton
        
        if let firstButton = buttons.first(where: { $0.isActive == true }) {
            let tag = firstButton.tag + 1

            let count = buttons.count

            if tag > count - 1 {
                guard let lastButton: UIButton = buttons.last else { return }
                embeddedBridgeViewController.buttonTouched(lastButton)
                return
            }
            activeButton = embeddedBridgeViewController.buttonCollection[tag]

        } else {
            activeButton = embeddedBridgeViewController.buttonCollection[0]
        }
        
        embeddedBridgeViewController.buttonTouched(activeButton)
    }
    
    @IBAction func microphoneButtonTouched(_ sender: Any) {
        
        if mode == .silent {
            mode = .record
        } else {
            mode = .silent
        }
        
        setAudioMode()
        UIApplication.shared.isIdleTimerDisabled = mode == .record
        handleMicrophoneButton()
        
        for button in self.embeddedBridgeViewController.buttonCollection {
            button.isEnabled = mode == .silent
        }
        tuningForkButton.isEnabled = mode == .silent
    }
    
    fileprivate func handleMicrophoneButton() {
        let buttonImage = mode == .record ? UIImage(named: "microphoneOff") : UIImage(named: "microphoneOn")
        microphoneButton.setImage(buttonImage, for: .normal)

        if mode == .record {
            self.timer = Timer.scheduledTimer(timeInterval: 0.01,
                                              target: self,
                                              selector: #selector(InstrumentViewController.updateUI),
                                              userInfo: nil,
                                              repeats: true)
            UIApplication.shared.isIdleTimerDisabled = true
        } else {
            self.timer?.invalidate()
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}


// **********************************************************
// MARK: - Keyboard Delegate Note on/off
// **********************************************************

extension InstrumentViewController: AKKeyboardDelegate {
    
    public func noteOn(note: Note) {
        
        mode = .play
        setAudioMode()
        microphoneButton.isEnabled = false
        
        let frequency = note.frequency
 
        self.embeddedVolumeMeterController.displayVolume(volume: 0.1)
        conductor.playNote(note: note.number, velocity: MIDIVelocity(127), channel: midiChannelIn)

        
        frequencyLabel.frequency = frequency
        embeddedGaugeViewController.displayFrequency(frequency: frequency, soundGenerator: true)
        embeddedDeviationMeterController.displayExactMatch(on: true)

        startObservingVolumeChanges()
    }
    
    public func noteOff(note: Note) {
        
        mode = .silent
        setAudioMode()
        microphoneButton.isEnabled = true
        
        DispatchQueue.main.async {
            self.conductor.stopNote(note: note.number, channel: self.midiChannelIn)
            self.embeddedVolumeMeterController.displayVolume(volume: 0.1)
            self.embeddedDeviationMeterController.displayExactMatch(on: false)
            self.embeddedDisplayViewController.clear()
            self.stopObservingVolumeChanges()
        }
    }
    
    
    public func stopAllNotes() {
        conductor.allNotesOff()
        //stopObservingVolumeChanges()
    }
    
    private struct Observation {
        static let VolumeKey = "outputVolume"
        static var Context = 0

    }
    
    func startObservingVolumeChanges() {
        AVAudioSession.sharedInstance().addObserver(self, forKeyPath: Observation.VolumeKey, options: [.initial, .new], context: &Observation.Context)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &Observation.Context {
            if keyPath == Observation.VolumeKey, let volume = (change?[NSKeyValueChangeKey.newKey] as? NSNumber)?.floatValue {
                //print("Volume: \(volume)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.embeddedVolumeMeterController.displayVolume(volume: volume*0.3)
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    func stopObservingVolumeChanges() {
        AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: Observation.VolumeKey, context: &Observation.Context)
    }
}

extension InstrumentViewController: AKMIDIListener  {
    
    // MIDI Setup Change
    func receivedMIDISetupChange() {
        print("midi setup change, midi.inputNames: \(conductor.midi.inputNames)")
        let inputNames = conductor.midi.inputNames
        inputNames.forEach { inputName in
            conductor.midi.openInput(name: inputName)
        }
    }
    
}


  extension UIView {

    func dropShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize(width: -10, height: -10)
        self.layer.shadowRadius = self.layer.cornerRadius
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
         let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
         let mask = CAShapeLayer()
         mask.path = path.cgPath
         self.layer.mask = mask
    }
}
