//
//  HeaderColorViewController.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 29.05.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit
import Pikko

class HeaderColorViewController: UIViewController {
    
    var containerFrame: CGRect?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .green
        
        setUpPikko()
    }
    
    
    private func setUpPikko() {
        
        let defaults = UserDefaults.standard
        if let headerColor = defaults.colorForKey(key: "headerColor") {
            self.view.backgroundColor = headerColor
        }
        
        let h = 0.7 * containerFrame!.size.height
        let pikko = Pikko(dimension: Int(h), setToColor: self.view.backgroundColor!)
        pikko.delegate = self
        
        self.view.addSubview(pikko)
        
        pikko.center.x = 0.55 * (containerFrame?.size.width)!
        pikko.center.y = 0.5 * (containerFrame?.size.height)!
        
        _ = pikko.getColor()
    }
    
}


extension HeaderColorViewController: PikkoDelegate {
    
    func writeBackColor(color: UIColor) {
        
        self.view.backgroundColor = color
        
        let defaults = UserDefaults.standard
        defaults.setColor(color: color, forKey: "headerColor")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didChangeHeaderColor"), object: nil, userInfo: ["color" : color])
    }
}
