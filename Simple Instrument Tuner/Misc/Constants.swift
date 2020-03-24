//
//  Constants.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 24.03.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit

let notesArray: [String] = String(Locale.preferredLanguages[0].prefix(2)) == "de" ? ["C", "C♯", "D", "E♭", "E", "F", "F♯", "G", "A♭", "A", "H♭", "H"] : ["C", "C♯", "D", "E♭", "E", "F", "F♯", "G", "A♭", "A", "B♭", "B"]
let freqArray: [Float] = [16.35, 17.32, 18.35, 19.45, 20.60, 21.83, 23.12, 24.50, 25.96, 27.50, 29.14, 30.87]

let freqMultFact: Float = 1.0595

class Constants: NSObject {

}
