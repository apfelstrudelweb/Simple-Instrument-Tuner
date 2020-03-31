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
//import GameplayKit


class InstrumentViewController: UIViewController {
    
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var frequencyLabel: FrequencyLabel!
    @IBOutlet weak var microphoneButton: UIButton!
    
    let conductor = Conductor.sharedInstance
    var midiChannelIn: MIDIChannel = 0
    var omniMode = true
    
    var mic: AKMicrophone!
    var frequencyTracker: AKFrequencyTracker!
    var silence: AKBooster!
    var lowPass: AKLowPassFilter!
    var timer: Timer?
    
    var audioActive = false
    
    private var embeddedGaugeViewController: GaugeViewController!
    private var embeddedVolumeMeterController: VolumeMeterViewController!
    private var embeddedDeviationMeterController: DeviationMeterViewController!
    private var embeddedBridgeViewController: BridgeViewController!
    private var embeddedDisplayViewController: DisplayViewController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        embeddedBridgeViewController.delegate = self
        conductor.addMidiListener(listener: self)
        setDefaults()
        
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { (notification) in
            print("app did become active")
            
            self.enableAudio()
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { (notification) in
            print("app did enter background")
            
            self.disableAudio()
        }
        
        circleView.layer.cornerRadius = 0.5*circleView.frame.size.width

        //displayContainer.layer.cornerRadius = 0.25*circleView.layer.cornerRadius
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        // Visualization
//        if false {
//            let plot = AKNodeFFTPlot(conductor.reverbMixer, frame: CGRect(x: 100, y: 0, width: 5000, height: 200))
//            plot.shouldFill = true
//            plot.shouldMirror = true
//            plot.shouldCenterYAxis = true
//            plot.color = #colorLiteral(red: 0, green: 0.9808154702, blue: 0.3959429264, alpha: 1)
//            plot.backgroundColor = #colorLiteral(red: 0.2431372549, green: 0.2431372549, blue: 0.262745098, alpha: 0)
//            plot.gain = 0.12
//            displayContainer.addSubview(plot)
//            plot.inputView?.autoPinEdgesToSuperviewEdges()
//        }
        
        
        // Sound detection#
        if true {
            AKSettings.audioInputEnabled = true
            mic = AKMicrophone()
            lowPass = AKLowPassFilter(mic)
            lowPass.cutoffFrequency = 500
            frequencyTracker = AKFrequencyTracker(lowPass)
            
            
            let micCopy = AKBooster(mic)
            let amplitudeTracker = AKAmplitudeTracker(micCopy)
            embeddedDisplayViewController.plotAmplitude(trackedAmplitude: amplitudeTracker)
            
            let fftTap = AKFFTTap.init(micCopy)
            embeddedDisplayViewController.plotFFT(fftTap: fftTap, amplitudeTracker: amplitudeTracker)
            
            AudioKit.output = self.silence
            do {
                try AudioKit.start()
            } catch {
                AKLog("AudioKit did not start!")
            }
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
    }
    
    
    fileprivate func enableAudio() {
//                AudioKit.output = self.silence
//                do {
//                    try AudioKit.start()
//                } catch {
//                    AKLog("AudioKit did not start!")
//                }
    }
    
    fileprivate func disableAudio() {
        audioActive = false
        handleMicrophoneButton()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    
    @objc func updateUI() {
        
        if frequencyTracker.amplitude > 0.05 {
            
            let frequency = Float(frequencyTracker.frequency)
            
            // Header
            frequencyLabel.frequency = frequency
            // Gauge
            embeddedGaugeViewController.displayFrequency(frequency: frequency)
            embeddedVolumeMeterController.displayVolume(volume: frequencyTracker.amplitude)
            
            embeddedDeviationMeterController.displayDeviation(frequency: frequency)
        } else {
            embeddedVolumeMeterController.displayVolume(volume: 0.1)
            embeddedGaugeViewController.resetGauge()
        }
    }
    
    
    @IBAction func microphoneButtonTouched(_ sender: Any) {
        audioActive = !audioActive
        UIApplication.shared.isIdleTimerDisabled = audioActive
        handleMicrophoneButton()
    }
    
    fileprivate func handleMicrophoneButton() {
        let buttonImage = audioActive == true ? UIImage(named: "microphoneOff") : UIImage(named: "microphoneOn")
        microphoneButton.setImage(buttonImage, for: .normal)
        
        if audioActive == true {
            self.timer = Timer.scheduledTimer(timeInterval: 0.1,
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
    
    func setDefaults() {

        conductor.useSound("TX Brass")
        conductor.sampler1.masterVolume = 1.0
        conductor.masterVolume.volume = 2.0
        conductor.reverb.feedback = 0.0
        conductor.multiDelay.time = 0.0
        conductor.filterSection.cutoffFrequency = 1000
        conductor.filterSection.resonance = 0.0
        conductor.filterSection.lfoAmplitude = 0.0
        conductor.filterSection.lfoRate = 0.0
        conductor.tremolo.depth = 2.0
        conductor.tremolo.frequency = 0
        conductor.decimator.rounding = 0.0
        conductor.decimator.mix = 0.0
        conductor.decimator.decimation = 0
     }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}


// **********************************************************
// MARK: - Keyboard Delegate Note on/off
// **********************************************************

extension InstrumentViewController: AKKeyboardDelegate {
    
    public func noteOn(note: MIDINoteNumber) {
        self.embeddedVolumeMeterController.displayVolume(volume: 0.1)
        conductor.playNote(note: note, velocity: MIDIVelocity(127), channel: midiChannelIn)

        let frequency = Constants().getFrequencyFromNote(number: Int(note))
        frequencyLabel.frequency = frequency
        embeddedGaugeViewController.displayFrequency(frequency: frequency)
        embeddedDeviationMeterController.displayExactMatch(on: true)

        startObservingVolumeChanges()
    }
    
    public func noteOff(note: MIDINoteNumber) {
        DispatchQueue.main.async {
            self.conductor.stopNote(note: note, channel: self.midiChannelIn)
            self.embeddedVolumeMeterController.displayVolume(volume: 0.1)
            self.embeddedDeviationMeterController.displayExactMatch(on: false)
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
                print("Volume: \(volume)")
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
