//
//  CalibrationViewController.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 19.04.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit

protocol CalibrationSliderDelegate: AnyObject {
    
    func didChangeCalibration()
}

class CalibrationViewController: UIViewController {
    
    @IBOutlet weak var calibrationLabel: UILabel!
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var shoppingCartButton: UIButton!
    
    @IBOutlet weak var slider: CalibrationSlider!
    
    weak var calibrationDelegate: CalibrationSliderDelegate?
    
    var interval: Int = 1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calibrationLabel.text = NSLocalizedString("Label.calibration", comment: "")
        
        shoppingCartButton.isEnabled = Utils().getInstrument() == nil ? false : true
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "settingsPattern.png")!)
        frequencyLabel.textColor = UIColor(displayP3Red: 105/225, green: 221/225, blue: 52/225, alpha: 1)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didPerformIAP), name: .didPerformIAP, object: nil)
        
        handleGuiElements()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        handleGuiElements()
    }
    
    fileprivate func handleGuiElements() {
        
        #if BANJO
            slider.isEnabled = IAPHandler().isOpenSignal() == true
            frequencyLabel.isHidden = IAPHandler().isOpenSignal() == false
            shoppingCartButton.isHidden = IAPHandler().isOpenSignal() == true
        #endif
        
        #if INSTRUMENT
            slider.isEnabled = IAPHandler().isOpenCalibration() == true
            frequencyLabel.isHidden = IAPHandler().isOpenCalibration() == false
            shoppingCartButton.isHidden = IAPHandler().isOpenCalibration() == true
        #endif
        
        setValueFromKeychain()
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        
        let newValue =  (sender.value / Float(interval)).rounded() * Float(interval)
        frequencyLabel.text = String(format: NSLocalizedString("Label.hertz %d", comment: ""), Int(newValue))
        
        let data = Data(from: Int(newValue))
        let _ = KeyChain.save(key: KEYCHAIN_CURRENT_CALIBRATION, data: data)
        
        self.calibrationDelegate?.didChangeCalibration()
    }
    
    private func setValueFromKeychain() {
        if let receivedData = KeyChain.load(key: KEYCHAIN_CURRENT_CALIBRATION) {
            let currentCalibration = receivedData.to(type: Int.self)
            slider.value = Float(currentCalibration)
        } else {
            let data = Data(from: Int(chambertone))
            let _ = KeyChain.save(key: KEYCHAIN_CURRENT_CALIBRATION, data: data)
            slider.value = Float(chambertone)
        }
        frequencyLabel.text = String(format: NSLocalizedString("Label.hertz %d", comment: ""), Int(slider.value))
    }
    
    @objc func didPerformIAP(_ notification: Notification) {
        
        DispatchQueue.main.async {
            self.handleGuiElements()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
