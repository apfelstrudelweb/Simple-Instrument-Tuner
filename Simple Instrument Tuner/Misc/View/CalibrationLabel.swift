//
//  CalibrationLabel.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 12.04.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit

@IBDesignable
class CalibrationLabel: UILabel {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        updateValueFromKeychain()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        updateValueFromKeychain()
    }
    
    func updateValueFromKeychain() {
        
        let calibration: Int = Int(Utils().getCurrentCalibration())
        self.text = "\(calibration) Hz"
    }
}
