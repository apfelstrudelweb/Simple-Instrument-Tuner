//
//  ViewController.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 21.03.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit
import AudioKit


class InstrumentViewController: UIViewController {
    
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var frequencyLabel: UILabel!
    
    var mic: AKMicrophone!
    var frequencyTracker: AKFrequencyTracker!
    var silence: AKBooster!
    var timer: Timer?
    
    var audioActive = false
    
    private var embeddedGaugeViewController: GaugeViewController!
    private var embeddedVolumeMeterController: VolumeMeterViewController!
    private var embeddedDeviationMeterController: DeviationMeterViewController!
    
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
    }
    
    
    fileprivate func enableAudio() {
        AudioKit.output = self.silence
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    fileprivate func disableAudio() {
        self.timer?.invalidate()
        //AudioKit.disconnectAllInputs()
        do {
            try AudioKit.stop()
        } catch {
            AKLog("AudioKit did not stop!")
        }
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { (notification) in
            print("app did become active")
            
            self.enableAudio()
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { (notification) in
            print("app did enter background")
            
            self.disableAudio()
        }
        
        circleView.layer.cornerRadius = 0.5*circleView.frame.size.width
        
        // Sound detection
        AKSettings.audioInputEnabled = true
        mic = AKMicrophone()
        frequencyTracker = AKFrequencyTracker(mic)
        silence = AKBooster(frequencyTracker, gain: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    @objc func updateUI() {
        
        if frequencyTracker.amplitude > 0.05 {
            
            let frequency = Float(frequencyTracker.frequency)
            
            // Header
            frequencyLabel.text = String(format: "%.2f Hz", frequency)
            // Gauge
            embeddedGaugeViewController.displayFrequency(frequency: frequency)
            embeddedVolumeMeterController.displayVolume(volume: frequencyTracker.amplitude)
            
            embeddedDeviationMeterController.displayDeviation(frequency: frequency)
        } else {
            embeddedVolumeMeterController.displayVolume(volume: 0.1)
        }
    }
    
    @IBAction func microphoneButtonTouched(_ sender: Any) {
        audioActive = !audioActive
        
        let button = sender as! UIButton
        let buttonImage = audioActive == true ? UIImage(named: "microphoneOff") : UIImage(named: "microphoneOn")
        button.setImage(buttonImage, for: .normal)
        
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
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

