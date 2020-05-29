//
//  MainColorView.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 29.05.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit
import Pikko

class MainColorView: UIView {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpPikko()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpPikko()
    }
    
    private func setUpPikko() {
        
        let defaults = UserDefaults.standard
        if let headerColor = defaults.colorForKey(key: "mainViewColor") {
            self.backgroundColor = headerColor
        }
        
        // Initialize a new Pikko instance.
        let pikko = Pikko(dimension: Int(0.6 * self.frame.size.width), setToColor: self.backgroundColor!)
        
        pikko.delegate = self
        
        pikko.center.x = 0.45 * self.frame.size.width
        pikko.center.y = 0.5 * self.frame.size.height
        self.addSubview(pikko)
        _ = pikko.getColor()
    }
    
}


extension MainColorView: PikkoDelegate {
    
    func writeBackColor(color: UIColor) {
        backgroundColor = color
        
        let defaults = UserDefaults.standard
        defaults.setColor(color: color, forKey: "mainViewColor")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didChangeMainViewColor"), object: nil, userInfo: ["color" : color])
    }
    
}
