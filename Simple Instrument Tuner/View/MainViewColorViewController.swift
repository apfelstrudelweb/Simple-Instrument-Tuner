//
//  MainViewColorViewController.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 29.05.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit
import Pikko


class MainViewColorViewController: UIViewController {
    
    var containerFrame: CGRect?
    var pikko: Pikko?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpPikko()
    }
    
    
    private func setUpPikko() {
        
        let defaults = UserDefaults.standard
        if let mainViewColor = defaults.colorForKey(key: "mainViewColor") {
            self.view.backgroundColor = mainViewColor
        }
        
        let h = UIDevice.current.userInterfaceIdiom == .pad  ? 0.5 * containerFrame!.size.height : 0.8 * containerFrame!.size.width
        let pikko = Pikko(dimension: Int(h), setToColor: self.view.backgroundColor!)
        pikko.delegate = self
        
        self.view.addSubview(pikko)
        
        pikko.center.x = 0.45 * (containerFrame?.size.width)!
        pikko.center.y = 0.5 * (containerFrame?.size.height)!
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            pikko.center.x = 0.4 * (containerFrame?.size.width)!
            pikko.center.y = 0.6 * (containerFrame?.size.height)!
        }
        
        _ = pikko.getColor()
    }
    
}


extension MainViewColorViewController: PikkoDelegate {
    
    func writeBackColor(color: UIColor) {
        
        self.view.backgroundColor = color
        
        let defaults = UserDefaults.standard
        defaults.setColor(color: color, forKey: "mainViewColor")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didChangeMainViewColor"), object: nil, userInfo: ["color" : color])
    }
}
