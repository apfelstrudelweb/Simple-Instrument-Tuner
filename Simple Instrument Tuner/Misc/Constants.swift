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

// In App Purchase
var KEYCHAIN_IAP_SERVICE        = "ch.vormbrock.simpleinstrumenttuner.iapService"

var IDENTIFIER_IAP_CALIBRATION    = "ch.vormbrock.simpleinstrumenttuner.calibration"  // Tier 1
var IDENTIFIER_IAP_GUITAR         = "ch.vormbrock.simpleinstrumenttuner.guitar"       // Tier 1
var IDENTIFIER_IAP_BANJO          = "ch.vormbrock.simpleinstrumenttuner.banjo"        // Tier 1
var IDENTIFIER_IAP_UKULELE        = "ch.vormbrock.simpleinstrumenttuner.ukulele"      // Tier 1
var IDENTIFIER_IAP_MANDOLIN       = "ch.vormbrock.simpleinstrumenttuner.mandolin"     // Tier 1
var IDENTIFIER_IAP_BALALAIKA      = "ch.vormbrock.simpleinstrumenttuner.balalaika"    // Tier 1
var IDENTIFIER_IAP_PREMIUM        = "ch.vormbrock.simpleinstrumenttuner.premium"      // Tier 4

// TODO: create constants
var iapIdentifierDict = [IDENTIFIER_IAP_CALIBRATION : "Calibration",
    IDENTIFIER_IAP_GUITAR : "Guitar",
    IDENTIFIER_IAP_BANJO : "Banjo",
    IDENTIFIER_IAP_UKULELE : "Ukulele",
    IDENTIFIER_IAP_MANDOLIN : "Mandolin",
    IDENTIFIER_IAP_BALALAIKA : "Balalaika",
    IDENTIFIER_IAP_PREMIUM : "Premium"
    ]

let productIds = [IDENTIFIER_IAP_CALIBRATION, IDENTIFIER_IAP_GUITAR, IDENTIFIER_IAP_BANJO, IDENTIFIER_IAP_UKULELE, IDENTIFIER_IAP_MANDOLIN, IDENTIFIER_IAP_BALALAIKA, IDENTIFIER_IAP_PREMIUM]

var KEYCHAIN_CURRENT_INSTRUMENT_ID  = "currentInstrumentId"
var KEYCHAIN_CURRENT_TUNING_ID      = "currentTuningId"
var KEYCHAIN_CURRENT_CALIBRATION    = "currentCalibration"


var INSTRUMENTS_PLIST_FILE = "Instruments"

var mode : Mode = .silent
var displayMode : DisplayMode = .fft

let maxNumberOfStrings: Int = 6

let notesArray: [String] = String(Locale.preferredLanguages[0].prefix(2)) == "de" ? ["C", "C♯", "D", "E♭", "E", "F", "F♯", "G", "A♭", "A", "H♭", "H"] : ["C", "C♯", "D", "E♭", "E", "F", "F♯", "G", "A♭", "A", "B♭", "B"]
let freqArray: [Float] = [16.35, 17.32, 18.35, 19.45, 20.60, 21.83, 23.12, 24.50, 25.96, 27.50, 29.14, 30.87]

let notesDict: NSDictionary = ["C" : 16.35, "C♯" : 17.32, "D" : 18.35, "D♯" : 19.45, "E" : 20.60 , "F" : 21.83, "F♯" : 23.12, "G" : 24.50, "G♯" : 25.96, "A" : 27.50, "A♯" : 29.14, "B" : 30.87]

let chambertone: Float = 440.0
let freqMultFact: Float = 1.0595
