//
//  ColorPickerViewController.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 23.05.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit


enum ColorAreas {
    case header
    case mainView
}

protocol SetColorDelegate: class {
    
    func colorSelected(area: ColorAreas, color: UIColor)
}

class CustomizeColorViewController: UIViewController {
    
    weak var setColorDelegate: SetColorDelegate?
    
    public var colorArea = ColorAreas.header
    
    public var headerColor = #colorLiteral(red: 0.6890257001, green: 0.2662356496, blue: 0.2310875654, alpha: 1)
    public var mainViewColor = #colorLiteral(red: 0.179690044, green: 0.2031518249, blue: 0.2304651412, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.backgroundColor = #colorLiteral(red: 0.179690044, green: 0.2031518249, blue: 0.2304651412, alpha: 1)
        
        self.view.backgroundColor = .clear

//        if colorArea == .header {
//            selectedColor = headerColor
//        }
//        if colorArea == .mainView {
//            selectedColor = mainViewColor
//        }
//
//        self.delegate = self
    }
    
    
}

//extension CustomizeColorViewController: ColorPickerDelegate {
//
//    func colorPicker(_: ColorPickerController, selectedColor: UIColor, usingControl: ColorControl) {
//
//        let defaults = UserDefaults.standard
//
//        if colorArea == .header {
//            headerColor = selectedColor
//            setColorDelegate?.colorSelected(area: colorArea, color: headerColor)
//            defaults.setColor(color: selectedColor, forKey: "headerColor")
//
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didChangeHeaderColor"), object: nil, userInfo: ["color" : headerColor])
//        }
//        if colorArea == .mainView {
//            mainViewColor = selectedColor
//            setColorDelegate?.colorSelected(area: colorArea, color: mainViewColor)
//            defaults.setColor(color: selectedColor, forKey: "mainViewColor")
//
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didChangeMainViewColor"), object: nil, userInfo: ["color" : mainViewColor])
//        }
//
//    }
//
//    func colorPicker(_: ColorPickerController, confirmedColor: UIColor, usingControl: ColorControl) {
//        dismiss(animated: true, completion: nil)
//    }
//}


extension UserDefaults {
    
    func colorForKey(key: String) -> UIColor? {
        var color: UIColor?
        if let colorData = data(forKey: key) {
            color = try! NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData)
        }
        return color
    }
    
    func setColor(color: UIColor?, forKey key: String) {
        var colorData: NSData?
        if let color = color {
            colorData = try! NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false) as NSData
        }
        set(colorData, forKey: key)
    }
    
}
