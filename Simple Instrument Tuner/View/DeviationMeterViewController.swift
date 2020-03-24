//
//  DeviationMeterViewController.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 24.03.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit
import PureLayout

class DeviationMeterViewController: UIViewController {
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var stackview: UIStackView!
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
        
        backgroundView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        backgroundView.layer.shadowOffset = CGSize(width: 0, height: 3)
        backgroundView.layer.shadowOpacity = 1.0
        backgroundView.layer.shadowRadius = 5.0
        backgroundView.layer.masksToBounds = false
        
        ledViewCollection.forEach {
            
            let w = 0.7*backgroundView.frame.size.height
            
            $0.autoSetDimension(.height, toSize: w)
            $0.autoSetDimension(.width, toSize: w)
            $0.layer.cornerRadius = 0.25 * w
            
            $0.layer.borderColor = UIColor.black.withAlphaComponent(0.85).cgColor
            $0.layer.borderWidth = 0.075*w
            
            $0.alpha = 0.5
        }
    }
    
    func displayDeviation(frequency: Float) {
        
        var freq = frequency
        
        while freq > Float(freqArray[freqArray.count - 1]) {
            freq /= 2.0
        }
         while freq < Float(freqArray[0]) {
            freq *= 2.0
        }
        
        var dist: Float = 1000.0
        var foundNominalFreq: Float = 0.0
        
        for (_, element) in freqArray.enumerated() {
            let dev = fabsf(element - freq)
            if dev < dist {
                dist = dev
                foundNominalFreq = element
            }
        }
        
        let deviation = freq - foundNominalFreq

        let leftLimit = 0.5 * (foundNominalFreq - foundNominalFreq / freqMultFact)
        let rightLimit = 0.5 * (foundNominalFreq * freqMultFact - foundNominalFreq)

        // well tuned ...
        if deviation > -0.1*leftLimit && deviation < 0.1*rightLimit {
            ledViewCollection[2].alpha = 1.0
        } else {
            ledViewCollection[2].alpha = 0.5
        }
        
        // not too well tuned
        // left LED
        if deviation > -leftLimit && deviation < -0.1*leftLimit {
            ledViewCollection[1].alpha = 1.0
        } else {
            ledViewCollection[1].alpha = 0.5
        }
        // right LED
        if deviation > 0.1*rightLimit && deviation < rightLimit {
            ledViewCollection[3].alpha = 1.0
        } else {
            ledViewCollection[3].alpha = 0.5
        }
        
        // not well tuned at all
        if deviation > -leftLimit && deviation < -0.5*leftLimit {
            ledViewCollection[0].alpha = 1.0
        } else {
            ledViewCollection[0].alpha = 0.5
        }
        if deviation > 0.5*rightLimit && deviation < rightLimit {
            ledViewCollection[4].alpha = 1.0
        } else {
            ledViewCollection[4].alpha = 0.5
        }
    }

}
