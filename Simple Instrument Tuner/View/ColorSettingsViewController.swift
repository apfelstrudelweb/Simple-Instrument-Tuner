//
//  ColorSettingsViewController.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 23.05.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit




class ColorSettingsViewController: UIViewController, SetColorDelegate {
    
    func colorSelected(area: ColorAreas, color: UIColor) {
        
        if area == .header {
            colorHeaderButton.backgroundColor = color
        }
        if area == .mainView {
            mainViewColorButton.backgroundColor = color
        }
    }
    
    var headerColor = UIColor.red {
        didSet {
            if colorHeaderButton != nil {
                colorHeaderButton.backgroundColor = headerColor
            }
        }
    }
    
    var backgroundColor = UIColor.black {
        didSet {
            if mainViewColorButton != nil {
                mainViewColorButton.backgroundColor = backgroundColor
            }
        }
    }

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    
    @IBOutlet weak var colorHeaderButton: UIButton! {
        didSet {
            colorHeaderButton.backgroundColor = headerColor
 
        }
    }
    @IBOutlet weak var mainViewColorButton: UIButton! {
        didSet {
            mainViewColorButton.backgroundColor = backgroundColor
            //mainViewColorButton.roundCorners([.bottomLeft, .bottomRight], radius: 70)
        }
    }
    
    
    override func viewDidLoad() {
        
        closeButton.layer.cornerRadius = 10
        resetButton.layer.cornerRadius = 10
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
         if let vc = segue.destination as? CustomizeColorViewController {
             
            vc.setColorDelegate = self
            
            if segue.identifier == "headerSegue" {
                vc.colorArea = .header
                vc.headerColor = colorHeaderButton.backgroundColor ?? .red
            }
            
            if segue.identifier == "mainViewSegue" {
                vc.colorArea = .mainView
                vc.mainViewColor = mainViewColorButton.backgroundColor ?? .darkGray
            }
         }
     }
    
    @IBAction func closeButtonTouched(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func defaultButtonTouched(_ sender: Any) {
        
        headerColor = defaultHeaderColor
        backgroundColor = defaultMainViewColor
        
        let defaults = UserDefaults.standard
        
        defaults.setColor(color: defaultHeaderColor, forKey: "headerColor")
        defaults.setColor(color: defaultMainViewColor, forKey: "mainViewColor")
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didChangeHeaderColor"), object: nil, userInfo: ["color" : headerColor])
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didChangeMainViewColor"), object: nil, userInfo: ["color" : backgroundColor])
    }
    
}
