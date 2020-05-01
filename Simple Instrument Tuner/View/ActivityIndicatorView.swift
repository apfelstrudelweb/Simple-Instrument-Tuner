//
//  ActivityIndicatorView.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 01.05.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit
import Foundation
import NVActivityIndicatorView

@IBDesignable
class ActivityIndicatorView: UIView {

    @IBOutlet weak var animatorView: NVActivityIndicatorView!
    @IBOutlet weak var animatorLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        let xibView = Bundle.main.loadNibNamed("ActivityIndicatorView", owner: self, options: nil)!.first as! UIView
        xibView.frame = self.bounds
        xibView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(xibView)

        self.backgroundColor = #colorLiteral(red: 0.4932231928, green: 0.1962741951, blue: 0.1731642657, alpha: 1).withAlphaComponent(0.9)
        self.animatorView.type = .ballSpinFadeLoader
        self.animatorLabel.text = "... waiting for the AppStore"
        
        self.animatorView.startAnimating()
    }
    
}
