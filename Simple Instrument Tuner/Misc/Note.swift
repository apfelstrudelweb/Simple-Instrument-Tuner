//
//  Note.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 28.03.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit
import AudioKit

public class Note: NSObject {
    
    var noteName : String = ""
    var frequency : Float = 0.0
    var number : MIDINoteNumber = MIDINoteNumber(0)
    
     init(noteName: String, frequency: Float) {
        
        if frequency == 0 { return }
            
           self.noteName = noteName
           self.frequency = frequency
           let n = Int(round(12 * log2(2 * frequency / chambertone))) + 69
           self.number = MIDINoteNumber(n)
     }

}
