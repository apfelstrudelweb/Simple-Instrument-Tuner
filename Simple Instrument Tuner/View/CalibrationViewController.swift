//
//  CalibrationViewController.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 19.04.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit

class CalibrationViewController: UIViewController {

    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var shoppingCartButton: UIButton!
    
    @IBOutlet weak var slider: CalibrationSlider!
    
    var interval: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "settingsPattern.png")!)
        frequencyLabel.textColor = UIColor(displayP3Red: 105/225, green: 221/225, blue: 52/225, alpha: 1)
        
        setValueFromKeychain()
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        
        let newValue =  (sender.value / Float(interval)).rounded() * Float(interval)
//        setValue(Float(newValue), animated: false)
//
//        let data = Data(from: Int(self.value))
//        let _ = KeyChain.save(key: KEYCHAIN_CURRENT_CALIBRATION, data: data)
        
        frequencyLabel.text = "\(Int(newValue)) Hz"
        
        //self.calibrationDelegate?.didChangeCalibration()
        
    }
    
    private func setValueFromKeychain() {
        if let receivedData = KeyChain.load(key: KEYCHAIN_CURRENT_CALIBRATION) {
            let currentCalibration = receivedData.to(type: Int.self)
            slider.value = Float(currentCalibration)
        } else {
            let data = Data(from: Int(440))
            let _ = KeyChain.save(key: KEYCHAIN_CURRENT_CALIBRATION, data: data)
            slider.value = Float(440)
        }
        frequencyLabel.text = "\(Int(slider.value)) Hz"
    }
    

}
