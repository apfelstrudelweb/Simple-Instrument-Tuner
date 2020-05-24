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


var INSTRUMENTS_PLIST_FILE = "Instruments"

var mode : Mode = .silent
var displayMode : DisplayMode = .fft

let maxNumberOfStrings: Int = 6

let freqArray: [Float] = [16.35, 17.32, 18.35, 19.45, 20.60, 21.83, 23.12, 24.50, 25.96, 27.50, 29.14, 30.87]

let notesDict: NSDictionary = ["C" : 16.35, "C♯" : 17.32, "D" : 18.35, "D♯" : 19.45, "E" : 20.60 , "F" : 21.83, "F♯" : 23.12, "G" : 24.50, "G♯" : 25.96, "A" : 27.50, "A♯" : 29.14, "B" : 30.87]

let chambertone: Float = 440.0
let freqMultFact: Float = 1.0595

let notesArray: [String] = {
    
    let countryCode = String(Locale.preferredLanguages[0].prefix(2))
    
    if countryCode == "de" {
        return ["C", "C♯", "D", "E♭", "E", "F", "F♯", "G", "A♭", "A", "H♭", "H"]
    } else if countryCode == "ru" {
        return ["До" ,"До♯","Ре", "Ми♭", "Ми" ,"Фа", "Фа♯", "Соль" ,"Ля♭", "Ля", "Си♭", "Си"]
    } else if countryCode == "es" || countryCode == "fr" || countryCode == "it" || countryCode == "pt" {
        return ["Do", "Do♯", "Re", "Mi♭", "Mi", "Fa", "Fa♯", "Sol", "La♭", "La", "Si♭", "Si"]
    } else if countryCode == "ja" {
        return ["ド", "ド♯", "レ", "ミ♭", "ミ", "ファ", "ファ♯", "ソ", "ラ♭", "ラ", "シ♭", "シ"]
    } else if countryCode == "ar" {
        return ["سي", "سي#" ,"دي", "إي♭", "إي", "إف", "إف#", "جي", "جي#", "إيه", "بي♭", "بي"]
    } else {
        return ["C", "C♯", "D", "E♭", "E", "F", "F♯", "G", "A♭", "A", "B♭", "B"]
    }
}()

