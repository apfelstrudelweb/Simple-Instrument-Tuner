//
//  Constants.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 24.03.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit

enum Mode {
  case record
  case play
  case silent
}

enum DisplayMode {
  case fft
  case amplitude
}

var mode : Mode = .silent
var displayMode : DisplayMode = .fft

let notesArray: [String] = String(Locale.preferredLanguages[0].prefix(2)) == "de" ? ["C", "C♯", "D", "E♭", "E", "F", "F♯", "G", "A♭", "A", "H♭", "H"] : ["C", "C♯", "D", "E♭", "E", "F", "F♯", "G", "A♭", "A", "B♭", "B"]
let freqArray: [Float] = [16.35, 17.32, 18.35, 19.45, 20.60, 21.83, 23.12, 24.50, 25.96, 27.50, 29.14, 30.87]


let guitarNotesArray : [Note] = [Note(noteName: "E", frequency: 82.41, number: 52),
                                Note(noteName: "A", frequency: 110, number: 57),
                                Note(noteName: "D", frequency: 146.8, number: 62),
                                Note(noteName: "G", frequency: 196, number: 67),
                                Note(noteName: "H", frequency: 246.9, number: 71),
                                Note(noteName: "E'", frequency: 329.6, number: 76),]


let freqMultFact: Float = 1.0595

class Constants: NSObject {

    func getFrequencyFromNote(number: Int) -> Float {
        if let frequency = guitarNotesArray.filter({ $0.number == number }).first?.frequency {
            return frequency
        } else {
            return 0.0
        }
    }
}


extension Array where Element: FloatingPoint {

    func sum() -> Element {
        return self.reduce(0, +)
    }

    func avg() -> Element {
        return self.sum() / Element(self.count)
    }

    func std() -> Element {
        let mean = self.avg()
        let v = self.reduce(0, { $0 + ($1-mean)*($1-mean) })
        return sqrt(v / (Element(self.count) - 1))
    }

}
