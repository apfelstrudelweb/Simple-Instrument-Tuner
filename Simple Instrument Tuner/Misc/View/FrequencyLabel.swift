//
//  FrequencyLabel.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 29.03.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit

class FrequencyLabel: UILabel {
    
    var frequency: Float = 0.0 {
        didSet {
            self.text = String(format: NSLocalizedString("Label.hertz %.2f", comment: ""), frequency)
            layoutIfNeeded()
        }
    }
}
