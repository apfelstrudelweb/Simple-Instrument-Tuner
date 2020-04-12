//
//  StringView.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 12.04.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit

class StringView: UIImageView {

    var frequency: Float?

}


extension UIView {
    
    func startShake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.0005
        animation.values = [-2.0, 2.0 ]
        animation.repeatCount = Float.infinity
        animation.autoreverses = true
        layer.add(animation, forKey: "shake")
    }
    
    func stopShake() {
        layer.removeAllAnimations()
    }
}
