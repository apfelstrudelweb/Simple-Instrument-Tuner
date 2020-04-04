//
//  DeviationMeterViewController.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 24.03.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit
import PureLayout

let alpha_on: CGFloat = 1.0
let alpha_off: CGFloat = 0.3

class DeviationMeterViewController: UIViewController {
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var stackview: UIStackView!
        {
        didSet {

            
        }
    }
    @IBOutlet var ledViewCollection: [UIView]! {
        didSet {
            ledViewCollection.sort { $0.tag < $1.tag }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundView.backgroundColor = UIColor.init(patternImage: UIImage(named: "volumeMeterPattern")!)
            
        backgroundView.layer.borderColor = UIColor.black.withAlphaComponent(0.85).cgColor
        backgroundView.layer.shadowColor = UIColor.lightGray.cgColor
        backgroundView.layer.shadowOpacity = 1
    }
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        backgroundView.layer.cornerRadius = 0.5*backgroundView.frame.size.height
        stackview.layer.cornerRadius = backgroundView.layer.cornerRadius
        
        let offset = 0.08*self.view.bounds.size.height
        
        backgroundView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        backgroundView.layer.shadowOffset = CGSize(width: 0, height: offset)
        backgroundView.layer.shadowOpacity = 1.0
        backgroundView.layer.shadowRadius = 2*offset
        backgroundView.layer.masksToBounds = false
        
        ledViewCollection.forEach {
            
            let w = 0.7*backgroundView.frame.size.height
            
            $0.autoSetDimension(.height, toSize: w)
            $0.autoSetDimension(.width, toSize: w)
            $0.layer.cornerRadius = 0.25 * w
            
            $0.layer.borderColor = UIColor.black.withAlphaComponent(0.85).cgColor
            $0.layer.borderWidth = 0.075*w
            
            $0.alpha = alpha_off
        }
        
        stackview.spacing = 0.06*backgroundView.frame.size.width
    }
    
    func displayExactMatch(on: Bool) {
        
        for ledView in ledViewCollection {
            ledView.alpha = alpha_off
        }
        ledByTag(tag: 0).alpha = on==true ? alpha_on : alpha_off
    }
    
    func displayDeviation(frequency: Float) {
        
        var diff: Float = 1000.0
        var foundNominalFreq: Float = 0.0
        
        guitarNotesArray.forEach {
            if diff > abs($0.frequency - frequency) {
                diff = abs($0.frequency - frequency)
                foundNominalFreq = $0.frequency
            }
        }
        
        let deviation = frequency - foundNominalFreq

        let leftLimit = 1.5 * (foundNominalFreq - foundNominalFreq / freqMultFact)
        let rightLimit = 1.5 * (foundNominalFreq * freqMultFact - foundNominalFreq)

        // green LED
        if deviation > -0.2*leftLimit && deviation < 0.2*rightLimit {
            ledByTag(tag: 0).alpha = alpha_on
        } else {
            ledByTag(tag: 0).alpha = alpha_off
        }
        
        // first red LEDs
        if deviation > -leftLimit && deviation < -0.1*leftLimit {
            ledByTag(tag: -1).alpha = alpha_on
            ledByTag(tag: 0).alpha = 0.75 * alpha_on
        } else {
            ledByTag(tag: -1).alpha = alpha_off
        }
        if deviation > 0.1*rightLimit && deviation < rightLimit {
            ledByTag(tag: 1).alpha = alpha_on
            ledByTag(tag: 0).alpha = 0.75 * alpha_on
        } else {
            ledByTag(tag: 1).alpha = alpha_off
        }
        
        // second red LEDs
        if deviation > -leftLimit && deviation < -0.5*leftLimit {
            ledByTag(tag: -2).alpha = alpha_on
            ledByTag(tag: 0).alpha = alpha_off
        } else {
            ledByTag(tag: -2).alpha = alpha_off
        }
        if deviation > 0.5*rightLimit && deviation < rightLimit {
            ledByTag(tag: 2).alpha = alpha_on
        } else {
            ledByTag(tag: 2).alpha = alpha_off
        }
        
        // third red LEDs
        if deviation > -leftLimit && deviation < -0.8*leftLimit {
            ledByTag(tag: -3).alpha = alpha_on
            ledByTag(tag: 0).alpha = alpha_off
        } else {
            ledByTag(tag: -3).alpha = alpha_off
        }
        if deviation > 0.8*rightLimit && deviation < rightLimit {
            ledByTag(tag: 3).alpha = alpha_on
        } else {
            ledByTag(tag: 3).alpha = alpha_off
        }
    }
    
    func ledByTag(tag: Int) -> UIView {
        
        return ledViewCollection.first(where: { $0.tag == tag }) ?? ledViewCollection[3]
    }

}
