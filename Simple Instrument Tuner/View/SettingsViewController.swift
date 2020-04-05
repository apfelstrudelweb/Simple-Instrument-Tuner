//
//  SettingsViewController.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 05.04.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit
import iOSDropDown

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var dropDown: DropDown!
    
    var backgroundColor = UIColor.black {
        didSet {
            self.view.backgroundColor = backgroundColor
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dropDown.optionArray = ["Guitar", "Banjo", "Ukulele", "Mandolin", "Violin", "Balalaika"]
        dropDown.optionIds = [1,2,3,4,5,6]
        

        dropDown.optionImageArray = ["guitarSymbol", "banjoSymbol", "ukuleleSymbol", "mandolinSymbol", "violinSymbol", "balalaikaSymbol"]
        dropDown.didSelect{(selectedText , index ,id) in
            print("Selected String: \(selectedText) \n index: \(index)")
        }
        
    }
    

    @IBAction func closeButtonTouched(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
