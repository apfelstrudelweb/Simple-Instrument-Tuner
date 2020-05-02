//
//  DisplayModeButton.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 31.03.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit
import PureLayout

class DisplayModeButton: UIButton {
    
    let modeLabel = UILabel()

    var text : String = NSLocalizedString("Label.fft", comment: "") {
        didSet {
            
            self.setNeedsLayout()
            self.layoutIfNeeded()
            
            modeLabel.text = text
            modeLabel.textColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
            modeLabel.font = UIFont.boldSystemFont(ofSize: 0.4*self.bounds.size.height)
            self.addSubview(modeLabel)
            modeLabel.autoCenterInSuperview()
            
            modeLabel.layer.shadowColor = UIColor.lightGray.cgColor
            modeLabel.layer.shadowRadius = 0.5
            modeLabel.layer.shadowOpacity = 1.0
            modeLabel.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
            modeLabel.layer.masksToBounds = false
        }
    }

}

