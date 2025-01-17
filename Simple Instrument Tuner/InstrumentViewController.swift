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

public var defaultHeaderColor = #colorLiteral(red: 0.6890257001, green: 0.2662356496, blue: 0.2310875654, alpha: 1)
public var defaultMainViewColor = #colorLiteral(red: 0.179690044, green: 0.2031518249, blue: 0.2304651412, alpha: 1)

class InstrumentViewController: UIViewController, SettingsViewControllerDelegate, CalibrationSliderDelegate, DeviationDelegate, EasyTipViewDelegate, GADBannerViewDelegate {
    
    let indexOfLastInfo = 13
    var activeInfo = 0
    
    var headerColor: UIColor = defaultHeaderColor {
        didSet {
            self.headerView.backgroundColor = headerColor
        }
    }
    
    var backgroundColor: UIColor = defaultMainViewColor {
        didSet {
            if UIDevice.current.userInterfaceIdiom == .pad {
                self.mainContainerView.backgroundColor = backgroundColor
            } else {
                self.view.backgroundColor = backgroundColor
            }
        }
    }
    
    
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
    @IBOutlet weak var displayContainer: UIView!
    @IBOutlet weak var goldGradientView: UIImageView!
    @IBOutlet weak var goldGradientHeaderView: UIImageView!
    
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
    
    
    var tipViewPreferences = EasyTipView.Preferences()
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func initTooltips() {
        
        let fact1: CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? 0.04 : 0.02
        let arrowSize = fact1 * self.view.bounds.size.width
        let fact2: CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? 0.6 : 0.4
        
        tipViewPreferences.drawing.font = calibrationLabel.font
        tipViewPreferences.drawing.foregroundColor = .white
        tipViewPreferences.drawing.backgroundColor = headerColor.darker(by: 10) ?? defaultHeaderColor
        tipViewPreferences.drawing.shadowColor = .darkGray
        tipViewPreferences.drawing.shadowOpacity = 0.3
        tipViewPreferences.drawing.arrowPosition = EasyTipView.ArrowPosition.any
        tipViewPreferences.drawing.arrowHeight = arrowSize
        tipViewPreferences.drawing.arrowWidth = arrowSize
        tipViewPreferences.positioning.maxWidth = fact2 * self.view.bounds.size.width
        tipViewPreferences.animating.showDuration = 1.5
        tipViewPreferences.animating.dismissDuration = 1.5
        EasyTipView.globalPreferences = tipViewPreferences
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerColor = defaultHeaderColor
        backgroundColor = defaultMainViewColor
        
        let defaults = UserDefaults.standard
        if let _headerColor = defaults.colorForKey(key: "headerColor") {
            headerColor = _headerColor
        }
        if let mainViewColor = defaults.colorForKey(key: "mainViewColor") {
            backgroundColor = mainViewColor
            displayContainer.backgroundColor = mainViewColor.withSaturationOffset(offset: -0.5)
        }

        setMainViewColor()
        
        // for Banjo and Ukulele Tuner
        if Utils().getInstrumentsArray().ids?.count == 1 {
            Utils().saveInstrument(index: 0)
            didChangeInstrument()
            
            if Utils().getCurrentTuningName().count == 0 {
                Utils().saveStandardTuning()
                didChangeTuning()
            }
        }
        
        SwiftRater.check()
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        initTooltips()
        
        let instrument = Utils().getInstrument()
        
        octaveLabel.text = String(format: NSLocalizedString("Label.octave %d", comment: ""), 0)
        frequencyLabel.text = String(format: NSLocalizedString("Label.hertz %.2f", comment: ""), 0.0)
        
        #if BANJO
        if IAPHandler().isOpenSignal() == false {
            frequencyLabel.alpha = 0.5
        }
        #endif
        #if UKULELE
        if IAPHandler().isOpenSignal() == false {
            frequencyLabel.alpha = 0.5
        }
        #endif
        #if INSTRUMENT
        if IAPHandler().isOpenSignal() == false {
            frequencyLabel.alpha = 0.5
        }
        #endif
        
        //if true {
        if instrument == nil {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "settingsSegue", sender: nil)
                
                EasyTipView.show(forView: self.infoButton,
                                 withinSuperview: self.view,
                                 text: NSLocalizedString("Info.intro", comment: ""),
                                 preferences: self.tipViewPreferences,
                                 delegate: self)
            }
        } else {
            let image = instrument?.symbol
            instrumentButton.setImage(image, for: .normal)
        }
        
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            mainContainerView.layer.cornerRadius = 0.05*mainContainerView.bounds.size.width
            headerView.roundCorners([.topLeft, .topRight], radius: mainContainerView.layer.cornerRadius)
            goldGradientView.roundCorners([.topLeft, .topRight, .bottomLeft, .bottomRight], radius: mainContainerView.layer.cornerRadius)
            
            mainContainerView.dropShadow()
        }
        
        circleView.layer.cornerRadius = 0.5*circleView.frame.size.width
        displayView.roundCorners([.bottomLeft, .bottomRight], radius: 0.15*circleView.layer.cornerRadius)
        
        fftButton.text = NSLocalizedString("Label.fft", comment: "")
        amplitudeButton.text = NSLocalizedString("Label.amplitude", comment: "")
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didChangeHeaderColor), name: NSNotification.Name(rawValue: "didChangeHeaderColor"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didChangeMainViewColor), name: NSNotification.Name(rawValue: "didChangeMainViewColor"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didChangeGold), name: NSNotification.Name(rawValue: "didChangeGold"), object: nil)
        
        setAudioMode()
        
        handleAd()
    }
    
    @objc func didChangeHeaderColor(_ notification: Notification) {
        
        if let color = notification.userInfo?["color"] as? UIColor {
            headerColor = color
            initTooltips()
        }
    }
    
    @objc func didChangeMainViewColor(_ notification: Notification) {
        
        if let color = notification.userInfo?["color"] as? UIColor {
            backgroundColor = color
            displayContainer.backgroundColor = color.withSaturationOffset(offset: -0.5)
        }
    }
    
    fileprivate func setMainViewColor() {
        
        if UserDefaults.standard.bool(forKey: "gold") == true {
            goldGradientView.alpha = 1.0
            goldGradientHeaderView.alpha = 1.0
            
            displayContainer.backgroundColor = UIColor(patternImage: UIImage(named: "goldGradient")!)// #colorLiteral(red: 0.688590575, green: 0.4986970604, blue: 0.1653240368, alpha: 1)
        } else {
            goldGradientView.alpha = 0.0
            goldGradientHeaderView.alpha = 0.0
            
            if let mainViewColor = UserDefaults.standard.colorForKey(key: "mainViewColor") {
                displayContainer.backgroundColor = mainViewColor.withSaturationOffset(offset: -0.5)
            }
        }
    }
    
    @objc func didChangeGold(_ notification: Notification) {
        
        setMainViewColor()
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
            if bannerView != nil {
                bannerView.removeFromSuperview()
            }
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
        bannerView.delegate = self
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    
    func adView(_ bannerView: GADBannerView,    didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
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
            
            #if BANJO
            if IAPHandler().isOpenSignal() == true {
                embeddedDisplayViewController.plotAmplitude(trackedAmplitude: self.amplitudeTracker)
                embeddedDisplayViewController.plotFFT(fftTap: fftTap, amplitudeTracker: amplitudeTracker)
            }
            #endif
            #if UKULELE
            if IAPHandler().isOpenSignal() == true {
                embeddedDisplayViewController.plotAmplitude(trackedAmplitude: self.amplitudeTracker)
                embeddedDisplayViewController.plotFFT(fftTap: fftTap, amplitudeTracker: amplitudeTracker)
            }
            #endif
            #if INSTRUMENT
            if IAPHandler().isOpenSignal() == true {
                embeddedDisplayViewController.plotAmplitude(trackedAmplitude: self.amplitudeTracker)
                embeddedDisplayViewController.plotFFT(fftTap: fftTap, amplitudeTracker: amplitudeTracker)
            }
            #endif
            
            
            
        } else if mode == .silent {
            
            return
        }
        
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
    }
    
    //    func signalTracker(didReceivedBuffer buffer: AVAudioPCMBuffer, atTime time: AVAudioTime){
    //
    //        let elements = UnsafeBufferPointer(start: buffer.floatChannelData?[0], count:8192)
    //
    //        var sample = [Float]()
    //
    //        for i in 0..<8192 {
    //            sample.append(elements[i])
    //        }
    //
    //        print (sample)
    //        print(sample.count)
    //
    //    }
    
    
    
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
            settingsViewController.backgroundColor = backgroundColor
            settingsViewController.headerColor = headerColor
            settingsViewController.settingsDelegate = self
            settingsViewController.embeddedCalibrationViewController.calibrationDelegate = self
            Utils().dismisAllTooltips(view: self.view)
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
            #if BANJO
            if IAPHandler().isOpenSignal() == true {
                frequencyLabel.frequency = frequency
            }
            #endif
            #if UKULELE
            if IAPHandler().isOpenSignal() == true {
                frequencyLabel.frequency = frequency
            }
            #endif
            #if INSTRUMENT
                   if IAPHandler().isOpenSignal() == true {
                       frequencyLabel.frequency = frequency
                   }
                   #endif
            octaveLabel.text = String(format: NSLocalizedString("Label.octave %d", comment: ""), Utils().getOctaveFrom(frequency: frequency))
            embeddedGaugeViewController.displayFrequency(frequency: frequency, soundGenerator: false)
            embeddedVolumeMeterController.displayVolume(volume: frequencyTracker.amplitude)
            embeddedDeviationMeterController.displayDeviation(frequency: frequency)
            
        } else {
            embeddedVolumeMeterController.displayVolume(volume: 0.1)
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        #if BANJO
        if identifier == "iapSegue" && IAPHandler().isOpenSignal() == true {
            return false
        }
        return true
        #endif
        #if UKULELE
        if identifier == "iapSegue" && IAPHandler().isOpenSignal() == true {
            return false
        }
        return true
        #endif
        #if INSTRUMENT
        if identifier == "iapSegue" && IAPHandler().isOpenSignal() == true {
            return false
        }
        return true
        #endif
    }
    
    
    @IBAction func fftButtonTouched(_ sender: Any) {
        
        fftButton.setImage(UIImage(named: "btnActive"), for: .normal)
        amplitudeButton.setImage(UIImage(named: "btnPassive"), for: .normal)
        embeddedDisplayViewController.setDisplayMode(mode: .fft)
        embeddedDisplayViewController.mode = .fft
    }
    
    @IBAction func amplitudeButtonTouched(_ sender: Any) {
        
        amplitudeButton.setImage(UIImage(named: "btnActive"), for: .normal)
        fftButton.setImage(UIImage(named: "btnPassive"), for: .normal)
        embeddedDisplayViewController.setDisplayMode(mode: .amplitude)
        embeddedDisplayViewController.mode = .amplitude
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
        
        embeddedDisplayViewController.clear()
        
        setAudioMode()
        UIApplication.shared.isIdleTimerDisabled = mode == .record
        handleMicrophoneButton()
    }
    
    fileprivate func handleMicrophoneButton() {
        
        // TODO: put this logic into the button class
        let buttonImage = mode == .record ? UIImage(named: "microphoneOff") : UIImage(named: "microphoneOn")
        microphoneButton.setImage(buttonImage, for: .normal)
        microphoneButton.isEnabled = (mode == .silent || mode == .record)
        
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
        
        Utils().dismisAllTooltips(view: self.view)
        
        if activeInfo > indexOfLastInfo {
            activeInfo = 0
        } else {
            showTipView(index: activeInfo)
            activeInfo += 1
        }
    }
    
    
    func easyTipViewDidDismiss(_ tipView: EasyTipView) {
        //print(tipView)
    }
    
    fileprivate func showTipView(index: Int) {
        
        switch index {
        case 0:        EasyTipView.show(forView: instrumentButton,
                                        withinSuperview: self.view,
                                        text: NSLocalizedString("Info.instrumentButton", comment: ""),
                                        preferences: tipViewPreferences,
                                        delegate: self)
            break
        case 1:  EasyTipView.show(forView: frequencyLabel,
                                  withinSuperview: self.view,
                                  text: NSLocalizedString("Info.frequencyLabel", comment: ""),
                                  preferences: tipViewPreferences,
                                  delegate: self)
            break
        case 2: EasyTipView.show(forView: calibrationLabel,
                                 withinSuperview: self.view,
                                 text: NSLocalizedString("Info.calibrationLabel", comment: ""),
                                 preferences: tipViewPreferences,
                                 delegate: self)
            break
        case 3:      EasyTipView.show(forView: fftButton,
                                      withinSuperview: self.view,
                                      text: NSLocalizedString("Info.fftButton", comment: ""),
                                      preferences: tipViewPreferences,
                                      delegate: self)
            break
            
        case 4:       EasyTipView.show(forView: amplitudeButton,
                                       withinSuperview: self.view,
                                       text: NSLocalizedString("Info.amplitudeButton", comment: ""),
                                       preferences: tipViewPreferences,
                                       delegate: self)
            break
        case 5:        EasyTipView.show(forView: embeddedBridgeViewController.buttonCollection.first!,
                                        withinSuperview: self.view,
                                        text: NSLocalizedString("Info.toneButton", comment: ""),
                                        preferences: tipViewPreferences,
                                        delegate: self)
            break
        case 6:   EasyTipView.show(forView: tuningForkButton,
                                   withinSuperview: self.view,
                                   text: NSLocalizedString("Info.tuningForkButton", comment: ""),
                                   preferences: tipViewPreferences,
                                   delegate: self)
            break
        case 7:         EasyTipView.show(forView: tuningLabel,
                                         withinSuperview: self.view,
                                         text: NSLocalizedString("Info.tuningLabel", comment: ""),
                                         preferences: tipViewPreferences,
                                         delegate: self)
        case 8:    EasyTipView.show(forView: embeddedVolumeMeterController.view,
                                    withinSuperview: self.view,
                                    text: NSLocalizedString("Info.volumeView", comment: ""),
                                    preferences: tipViewPreferences,
                                    delegate: self)
            break
            
        case 9:         EasyTipView.show(forView: embeddedDeviationMeterController.view,
                                         withinSuperview: self.view,
                                         text: NSLocalizedString("Info.deviationView", comment: ""),
                                         preferences: tipViewPreferences,
                                         delegate: self)
            break
        case 10:        EasyTipView.show(forView: octaveLabel,
                                         withinSuperview: self.view,
                                         text: NSLocalizedString("Info.octaveLabel", comment: ""),
                                         preferences: tipViewPreferences,
                                         delegate: self)
            break
        case 11:         EasyTipView.show(forView: embeddedGaugeViewController.view,
                                          withinSuperview: self.view,
                                          text: NSLocalizedString("Info.gaugeView", comment: ""),
                                          preferences: tipViewPreferences,
                                          delegate: self)
            break
        case 12:  EasyTipView.show(forView: microphoneButton,
                                   withinSuperview: self.view,
                                   text: NSLocalizedString("Info.microphoneButton", comment: ""),
                                   preferences: tipViewPreferences,
                                   delegate: self)
            break
        case 13:  EasyTipView.show(forView: settingsButton,
                                   withinSuperview: self.view,
                                   text: NSLocalizedString("Info.settingsButton", comment: ""),
                                   preferences: tipViewPreferences,
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
        
        
        #if BANJO
        if IAPHandler().isOpenSignal() == true {
            frequencyLabel.frequency = frequency
        }
        #endif
        #if UKULELE
        if IAPHandler().isOpenSignal() == true {
            frequencyLabel.frequency = frequency
        }
        #endif
        #if INSTRUMENT
        if IAPHandler().isOpenSignal() == true {
            frequencyLabel.frequency = frequency
        }
        #endif

        frequencyLabel.frequency = frequency
        octaveLabel.text = String(format: NSLocalizedString("Label.octave %d", comment: ""), Utils().getOctaveFrom(frequency: frequency))
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


extension UIColor {

    var complement: UIColor {
        return self.withHueOffset(offset: 0.5)
    }

    var splitComplement0: UIColor {
        return self.withHueOffset(offset: 150 / 360)
    }

    var splitComplement1: UIColor {
        return self.withHueOffset(offset: 210 / 360)
    }

    var triadic0: UIColor {
        return self.withHueOffset(offset: 120 / 360)
    }

    var triadic1: UIColor {
        return self.withHueOffset(offset: 240 / 360)
    }

    var tetradic0: UIColor {
        return self.withHueOffset(offset: 0.25)
    }

    var tetradic1: UIColor {
        return self.complement
    }

    var tetradic2: UIColor {
        return self.withHueOffset(offset: 0.75)
    }

    var analagous0: UIColor {
        return self.withHueOffset(offset: -1 / 12)
    }

    var analagous1: UIColor {
        return self.withHueOffset(offset: 1 / 12)
    }

    func withHueOffset(offset: CGFloat) -> UIColor {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: fmod(h + offset, 1), saturation: s, brightness: b, alpha: a)
    }
    
    func withSaturationOffset(offset: CGFloat) -> UIColor {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: fmod(s + offset, 1), brightness: b, alpha: a)
    }
}
