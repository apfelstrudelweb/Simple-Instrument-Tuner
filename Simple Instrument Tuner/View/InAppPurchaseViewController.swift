//
//  InAppPurchaseViewController.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 19.04.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit

class InAppPurchaseViewController: UIViewController {
    
    var instrument: Instrument?

    override func viewDidLoad() {
        super.viewDidLoad()

        print(instrument?.name)
    }
    

}
