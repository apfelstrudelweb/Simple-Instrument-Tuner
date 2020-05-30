//
//  ColorSettingsViewController.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 23.05.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit


class ColorSettingsViewController: UIViewController {
    
    
    public var headerColor = #colorLiteral(red: 0.6890257001, green: 0.2662356496, blue: 0.2310875654, alpha: 1)
    public var backgroundColor = #colorLiteral(red: 0.179690044, green: 0.2031518249, blue: 0.2304651412, alpha: 1)
    
    @IBOutlet weak var headerContainerView: UIView!
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    @IBOutlet weak var headerColorView: HeaderColorView!{
        didSet {
            let defaults = UserDefaults.standard
            if let headerColor = defaults.colorForKey(key: "headerColor") {
                headerColorView.backgroundColor = headerColor
            }
        }
    }
    
    @IBOutlet weak var mainColorView: MainColorView! {
        didSet {
            let defaults = UserDefaults.standard
            if let mainViewColor = defaults.colorForKey(key: "mainViewColor") {
                mainColorView.backgroundColor = mainViewColor
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? HeaderColorViewController,
            segue.identifier == "headerSegue" {
            
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            
            vc.containerFrame = headerContainerView.bounds
        }
        if let vc = segue.destination as? MainViewColorViewController,
            segue.identifier == "mainViewSegue" {
            
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            
            vc.containerFrame = mainColorView.bounds
        }
    }
    
    
    override func viewDidLoad() {
        
        closeButton.layer.cornerRadius = 10
        resetButton.layer.cornerRadius = 10
    }
    
    
    
    @IBAction func closeButtonTouched(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func defaultButtonTouched(_ sender: Any) {
        
        headerColor = defaultHeaderColor
        backgroundColor = defaultMainViewColor
        headerColorView.backgroundColor = headerColor
        mainColorView.backgroundColor = backgroundColor
        
        let defaults = UserDefaults.standard
        
        defaults.setColor(color: defaultHeaderColor, forKey: "headerColor")
        defaults.setColor(color: defaultMainViewColor, forKey: "mainViewColor")
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didChangeHeaderColor"), object: nil, userInfo: ["color" : headerColor])
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didChangeMainViewColor"), object: nil, userInfo: ["color" : backgroundColor])
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
}
