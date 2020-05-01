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
import SwiftRater
import EasyTipView

class InstrumentViewController: UIViewController, SettingsViewControllerDelegate, CalibrationSliderDelegate, DeviationDelegate, EasyTipViewDelegate {
    
    let indexOfLastInfo = 13
    var activeInfo = 0
    
    
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var instrumentButton: UIButton!
    @IBOutlet weak var mainContainerView: UIView!
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var frequencyLabel: FrequencyLabel!
    @IBOutlet weak var calibrationLabel: CalibrationLabel!
    @IBOutlet weak var tuningLabel: UILabel!
    @IBOutlet weak var octaveLabel: UILabel!
    
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
    
    let semitone = pow(2.0, 1.0/12.0)
    
    
    var smoothArray = [Float]()
    
    
    private var embeddedGaugeViewController: GaugeViewController!
    private var embeddedVolumeMeterController: VolumeMeterViewController!
    private var embeddedDeviationMeterController: DeviationMeterViewController!
    private var embeddedBridgeViewController: BridgeViewController!
    private var embeddedDisplayViewController: DisplayViewController!
    private var settingsViewController: SettingsViewController!
    
    
    var preferencesGreen = EasyTipView.Preferences()
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func initTooltips() {
        
        let fact1: CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? 0.04 : 0.02
        let arrowSize = fact1 * self.view.bounds.size.width
        let fact2: CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? 0.6 : 0.4
        
        preferencesGreen.drawing.font = calibrationLabel.font
        preferencesGreen.drawing.foregroundColor = .white
        preferencesGreen.drawing.backgroundColor = UIColor(red: 0, green: 0.5569, blue: 0.2588, alpha: 1.0)
        preferencesGreen.drawing.shadowColor = .darkGray
        preferencesGreen.drawing.shadowOpacity = 0.3
        preferencesGreen.drawing.arrowPosition = EasyTipView.ArrowPosition.any
        preferencesGreen.drawing.arrowHeight = arrowSize
        preferencesGreen.drawing.arrowWidth = arrowSize
        preferencesGreen.positioning.maxWidth = fact2 * self.view.bounds.size.width
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SwiftRater.check()
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        initTooltips()
        
        let instrument = Utils().getInstrument()
        
        //if true {
        if instrument == nil {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "settingsSegue", sender: nil)
                
                EasyTipView.show(forView: self.infoButton,
                                 withinSuperview: self.view,
                                 text: "Tap this info button if you would like further information about all displays and buttons in this view. Repeat tapping in order to go through all elements.",
                                 preferences: self.preferencesGreen,
                                 delegate: self)
            }
        } else {
            let image = instrument?.symbol
            instrumentButton.setImage(image, for: .normal)
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
        tuningLabel.text = Utils().getCurrentTuningName()
        
        
        embeddedBridgeViewController.delegate = self
        conductor.addMidiListener(listener: self)
        
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { (notification) in
            print("app did become active")
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { (notification) in
            print("app did enter background")
            
            self.disableAudio()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didPerformIAP), name: .didPerformIAP, object: nil)
        
        setAudioMode()
        
        handleAd()
    }
    
    
    // TODO: didChangeTuning
    func didChangeInstrument() {
        
        let instrument = Utils().getInstrument()
        let image = instrument?.symbol
        instrumentButton.setImage(image, for: .normal)
        
        tuningLabel.text = Utils().getCurrentTuningName()
        
        DispatchQueue.main.async {
            self.embeddedBridgeViewController.loadElements()
        }
    }
    
    func didChangeTuning() {
        
        tuningLabel.text = Utils().getCurrentTuningName()
        
        DispatchQueue.main.async {
            self.embeddedBridgeViewController.loadElements()
        }
    }
    
    // MARK: CalibrationSliderDelegate
    func didChangeCalibration() {
        calibrationLabel.updateValueFromKeychain()
        embeddedGaugeViewController.updateCalibration()
        embeddedDeviationMeterController.updateCalibration()
    }
    
    // MARK: DeviationDelegate
    func hitNote(frequency: Float, flag: Bool) {
        embeddedBridgeViewController.animateString(frequency: frequency, flag: flag)
    }
    
    @objc func didPerformIAP(_ notification: Notification) {
        
        if IAPHandler().displayAd() == false {
            bannerView.removeFromSuperview()
        }
    }
    
    func handleAd() {
        
        if IAPHandler().displayAd() == false {
            return
        }
        
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
            
            let ratio = Utils().getCurrentCalibration() / chambertone
            let fractionSemitone = 12.0 * log2(ratio)
            
            let effect = AKOperationEffect(conductor.reverbMixer) { player, parameters in
                return player.pitchShift(semitones: fractionSemitone)
            }
            
            AudioKit.output = effect
            embeddedDisplayViewController.plotFFTFromSound(reverbMixer: conductor.reverbMixer)
            
        } else if mode == .record {
            
            AKSettings.audioInputEnabled = true
            AudioKit.output = nil
            
            mic = AKMicrophone()
            let micCopy = AKBooster(mic)
            
            let minFreq: Float = 80.0
            let maxFreq: Float = 900.0
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
            embeddedDeviationMeterController.deviationDelegate = self
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
            settingsViewController.embeddedCalibrationViewController.calibrationDelegate = self 
        }
        
    }
    
    fileprivate func disableAudio() {
        
        UIApplication.shared.isIdleTimerDisabled = false
        
        do {
            try AudioKit.stop()
        } catch {
            AKLog("AudioKit did not start!")
        }
        
        mode = .silent
        handleMicrophoneButton()
    }
    
    
    @objc func updateUI() {
        
        if frequencyTracker == nil { return }
        
        
        if frequencyTracker.amplitude > 0.02 {
            
            
            let frequency: Float = Float(frequencyTracker.frequency)
            
            frequencyLabel.frequency = frequency
            octaveLabel.text = "Octave: \(Utils().getOctaveFrom(frequency: frequency))"
            // Gauge
            embeddedGaugeViewController.displayFrequency(frequency: frequency, soundGenerator: false)
            embeddedVolumeMeterController.displayVolume(volume: frequencyTracker.amplitude)
            embeddedDeviationMeterController.displayDeviation(frequency: frequency)
            
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
    }
    
    fileprivate func handleMicrophoneButton() {
        
        // TODO: put this logic into the button class
        let buttonImage = mode == .record ? UIImage(named: "microphoneOff") : UIImage(named: "microphoneOn")
        microphoneButton.setImage(buttonImage, for: .normal)
        microphoneButton.isEnabled = mode == .silent
        
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
        
        for button in self.embeddedBridgeViewController.buttonCollection {
            button.isEnabled = mode == .silent
        }
        
        tuningForkButton.isEnabled = mode == .silent
        settingsButton.isEnabled = mode == .silent
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // **********************************************************
    // MARK: - Tooltip
    // **********************************************************
    @IBAction func infoButtonTouched(_ sender: Any) {
        
        dismissAllTooltips()
        
        if activeInfo > indexOfLastInfo {
            activeInfo = 0
        } else {
            showTipView(index: activeInfo)
            activeInfo += 1
        }
    }
    
    
    func easyTipViewDidDismiss(_ tipView: EasyTipView) {
        //print("dismiss")
    }
    
    fileprivate func dismissAllTooltips() {
        for view in self.view.subviews {
            if let tipView = view as? EasyTipView {
                tipView.dismiss()
            }
        }
    }
    
    fileprivate func showTipView(index: Int) {
        
        switch index {
        case 0:        EasyTipView.show(forView: instrumentButton,
                                        withinSuperview: self.view,
                                        text: "Display of the instrument you selected  in 'Settings' ( the button can be found at the bottom right). Tapping on the symbol opens the settings dialogue where you can change the instrument.",
                                        preferences: preferencesGreen,
                                        delegate: self)
            break
        case 1:  EasyTipView.show(forView: frequencyLabel,
                                  withinSuperview: self.view,
                                  text: "Display of the frequency of the plucked string in Hz. This info is useful for professionals ...",
                                  preferences: preferencesGreen,
                                  delegate: self)
            break
        case 2: EasyTipView.show(forView: calibrationLabel,
                                 withinSuperview: self.view,
                                 text: "The chamber tone is about 440 Hz. You can calibrate your instrument. After doing  so, the new frequency will be displayed here.",
                                 preferences: preferencesGreen,
                                 delegate: self)
            break
        case 3:      EasyTipView.show(forView: fftButton,
                                      withinSuperview: self.view,
                                      text: "Tap this button in order to see the spectrum of the plucked strings - you will see the harmonics as well.",
                                      preferences: preferencesGreen,
                                      delegate: self)
            break
            
        case 4:       EasyTipView.show(forView: amplitudeButton,
                                       withinSuperview: self.view,
                                       text: "Tap this button in order to see the amplitude of the plucked strings.",
                                       preferences: preferencesGreen,
                                       delegate: self)
            break
        case 5:        EasyTipView.show(forView: embeddedBridgeViewController.buttonCollection.first!,
                                        withinSuperview: self.view,
                                        text: "Tap the single string button in order to tune a predetermined string by ear. A second tap will silence the signal sound. By the way, the number located behind the note indicates the octave.",
                                        preferences: preferencesGreen,
                                        delegate: self)
            break
        case 6:   EasyTipView.show(forView: tuningForkButton,
                                   withinSuperview: self.view,
                                   text: "Tap this button if you would like to tune your instrument by ear. Repeat tapping in order to go through all strings.",
                                   preferences: preferencesGreen,
                                   delegate: self)
            break
        case 7:         EasyTipView.show(forView: tuningLabel,
                                         withinSuperview: self.view,
                                         text: "Display of the tuning of the instrument you chose in 'Settings'. For guitar, the standard tuning is 'classical / acoustic'.",
                                         preferences: preferencesGreen,
                                         delegate: self)
        case 8:    EasyTipView.show(forView: embeddedVolumeMeterController.view,
                                    withinSuperview: self.view,
                                    text: "Display of the volume.",
                                    preferences: preferencesGreen,
                                    delegate: self)
            break
            
        case 9:         EasyTipView.show(forView: embeddedDeviationMeterController.view,
                                         withinSuperview: self.view,
                                         text: "Display of the deviation of the plucked string from the next likely note recognized by the sound system. Tune your string until only the green LED  is displayed. Red LEDs to the left indicate that you need to turn the peg away from you to avoid sounding  sharp - red LEDs to the right indicate that you need to turn the peg toward you to avoid sounding flat.",
                                         preferences: preferencesGreen,
                                         delegate: self)
            break
        case 10:        EasyTipView.show(forView: octaveLabel,
                                         withinSuperview: self.view,
                                         text: "Display of the octave of the plucked string. An octave played by any instrument is always a pitch that is double the frequency of the first note when going up an octave and halved when going down.",
                                         preferences: preferencesGreen,
                                         delegate: self)
            break
        case 11:         EasyTipView.show(forView: embeddedGaugeViewController.view,
                                          withinSuperview: self.view,
                                          text: "Display of the note or half-note of the plucked string. This info is very useful in conjunction with the octave displayed above. Take as an example, the 'thick' E string of a guitar - in order to tune the E2 string, notice how both the tone 'E' within this gauge, and the octave '2' above are displayed.",
                                          preferences: preferencesGreen,
                                          delegate: self)
            break
        case 12:  EasyTipView.show(forView: microphoneButton,
                                   withinSuperview: self.view,
                                   text: "Tap this button in order to tune your instrument with the integrated frequency detection engine.",
                                   preferences: preferencesGreen,
                                   delegate: self)
            break
        case 13:  EasyTipView.show(forView: settingsButton,
                                   withinSuperview: self.view,
                                   text: "Tap this button if you would like to change the instrument and/or the tuning.",
                                   preferences: preferencesGreen,
                                   delegate: self)
        default: print("no")
            
        }
        
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
        octaveLabel.text = "Octave: \(Utils().getOctaveFrom(frequency: frequency))"
        embeddedGaugeViewController.displayFrequency(frequency: frequency, soundGenerator: true)
        embeddedDeviationMeterController.displayExactMatch(on: true)
        
        fftButton.isEnabled = false
        amplitudeButton.isEnabled = false
        fftButton.alpha = 0
        amplitudeButton.alpha = 0
        
        startObservingVolumeChanges()
    }
    
    public func noteOff(note: Note) {
        
        mode = .silent
        setAudioMode()
        microphoneButton.isEnabled = true
        
        fftButton.isEnabled = true
        amplitudeButton.isEnabled = true
        fftButton.alpha = 1
        amplitudeButton.alpha = 1
        
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
