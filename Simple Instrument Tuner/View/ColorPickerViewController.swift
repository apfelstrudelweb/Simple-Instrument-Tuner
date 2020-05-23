//
//  ColorPickerViewController.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 23.05.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit

import FlexColorPicker

var pickedColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)

class CustomizeColorViewController: DefaultColorPickerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = #colorLiteral(red: 0.179690044, green: 0.2031518249, blue: 0.2304651412, alpha: 1)

        selectedColor = pickedColor
        self.delegate = self
    }
    

}

extension ColorSettingsViewController: ColorPickerDelegate {
    func colorPicker(_: ColorPickerController, selectedColor: UIColor, usingControl: ColorControl) {
        pickedColor = selectedColor
    }

    func colorPicker(_: ColorPickerController, confirmedColor: UIColor, usingControl: ColorControl) {
        dismiss(animated: true, completion: nil)
    }
}
