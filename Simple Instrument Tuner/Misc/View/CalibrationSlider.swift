//
//  SnappableSlider.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 11.04.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit
import PureLayout



@IBDesignable
class CalibrationSlider: UISlider {
    

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let point = CGPoint(x: bounds.minX, y: bounds.midY)
        return CGRect(origin: point, size: CGSize(width: bounds.width, height: 10))
    }

    @IBInspectable
    var interval: Int = 1

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpSlider()
        setValueFromKeychain()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpSlider()
        setValueFromKeychain()
    }

    private func setUpSlider() {
        
        addTarget(self, action: #selector(handleValueChange(sender:)), for: .valueChanged)
    }
    
    private func setValueFromKeychain() {
        if let receivedData = KeyChain.load(key: KEYCHAIN_CURRENT_CALIBRATION) {
            let currentCalibration = receivedData.to(type: Int.self)
            self.value = Float(currentCalibration)
        } else {
            let data = Data(from: Int(chambertone))
            let _ = KeyChain.save(key: KEYCHAIN_CURRENT_CALIBRATION, data: data)
            self.value = Float(chambertone)
        }
        //setLabel()
    }

    @objc func handleValueChange(sender: UISlider) {
        let newValue =  (sender.value / Float(interval)).rounded() * Float(interval)
        setValue(Float(newValue), animated: false)

        let data = Data(from: Int(self.value))
        let _ = KeyChain.save(key: KEYCHAIN_CURRENT_CALIBRATION, data: data)

    }
    
}
