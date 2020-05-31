//
//  IAPHandler.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 19.04.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit
import KeychainAccess

// In App Purchase
var KEYCHAIN_IAP_SERVICE        = "ch.vormbrock.simpleukuleletuner.iapService"

var IDENTIFIER_IAP_ALL_UKULELE      = "ch.vormbrock.simpleukuleletuner.alluke"         // Tier 1
var IDENTIFIER_IAP_SIGNALPLUS     = "ch.vormbrock.simpleukuleletuner.signalplus"        // Tier 1
var IDENTIFIER_IAP_PREMIUM        = "ch.vormbrock.simpleukuleletuner.premium"         // Tier 2

// TODO: create constants
var iapIdentifierDict = [IDENTIFIER_IAP_ALL_UKULELE : "All Ukulele",
                         IDENTIFIER_IAP_SIGNALPLUS : "Signal Plus",
                         IDENTIFIER_IAP_PREMIUM : "All In One"
]

let productIds = [IDENTIFIER_IAP_ALL_UKULELE, IDENTIFIER_IAP_SIGNALPLUS, IDENTIFIER_IAP_PREMIUM]

var KEYCHAIN_CURRENT_INSTRUMENT_ID  = "currentInstrumentId"
var KEYCHAIN_CURRENT_TUNING_ID      = "currentTuningId"
var KEYCHAIN_CURRENT_CALIBRATION    = "currentCalibration"


typealias isOpenUkulele = () -> Bool
typealias isOpenSignalPlus = () -> Bool
typealias isPremium = () -> Bool


let ukuleleDict =       ["All Ukulele" :  [NSLocalizedString("Ukulele.iap1", comment: ""), NSLocalizedString("Ukulele.iap2", comment: ""), NSLocalizedString("Ukulele.iap3", comment: "")]]
let signalDict =        ["Signal Plus" :  [NSLocalizedString("Calibration.iap1", comment: ""), NSLocalizedString("Calibration.iap2", comment: "")]]
let premiumDict =       ["All In One" :  [NSLocalizedString("Premium.iap1", comment: ""), NSLocalizedString("Premium.iap2", comment: ""), NSLocalizedString("Premium.iap3", comment: "")]]

let iapOptionsArray = [ukuleleDict, signalDict, premiumDict]


var dictSignal: Dictionary = [String : isOpenSignalPlus]()
var dictUkulele: Dictionary = [String : isOpenUkulele]()
var dictPremium: Dictionary = [String : isPremium]()


var dictIAP : Dictionary = ["Signal Plus": dictSignal,
                            "All Ukulele" : dictUkulele,
                            "All In One" : dictPremium]

let keychain = Keychain(service: KEYCHAIN_IAP_SERVICE)
let PURCHASED = "purchased"

class IAPHandler: NSObject {
    
    var dictUnlockMethods : Dictionary<String, ()->()> = [ : ]
    
    override init() {
        super.init()
        
        dictUnlockMethods = ["Signal Plus": unlockSignal,
                             "All Ukulele" : unlockUkulele,
                             "All In One" : unlockPremium]
        
        
        dictSignal["Signal Plus"] = self.isOpenSignal
        dictUkulele["All Ukulele"] = self.isOpenUkulele
        dictPremium["All In One"] = self.premium
    }
    
    
    
    var productsArray: [Product]?
    
    private static var sharedIAPHandler: IAPHandler = {
        let iapManager = IAPHandler()
        
        dictSignal["Signal Plus"] = iapManager.isOpenSignal
        dictUkulele["All Ukulele"] = iapManager.isOpenUkulele
        dictPremium["All In One"] = iapManager.premium
        
        return iapManager
    }()
    
    class func shared() -> IAPHandler {
        return sharedIAPHandler
    }
    
    
    // Getter
    
    func displayAd() -> Bool {
        
        if let _ = try? keychain.get(IDENTIFIER_IAP_SIGNALPLUS){
            return false
        }
        if let _ = try? keychain.get(IDENTIFIER_IAP_ALL_UKULELE) {
            return false
        }
        if let _ = try? keychain.get(IDENTIFIER_IAP_PREMIUM) {
            return false
        }
        return true
    }
    
    func isOpenPremium() -> Bool {
        if let _ = try? keychain.get(IDENTIFIER_IAP_PREMIUM) {
            return true
        }
        if isOpenSignal() && isOpenUkulele() {
            return true
        }
        
        return false
    }
    
    func isOpenSignal() -> Bool {
        
        if let _ = try? keychain.get(IDENTIFIER_IAP_SIGNALPLUS) {
            return true
        }
        if let _ = try? keychain.get(IDENTIFIER_IAP_PREMIUM) {
            return true
        }
        return false
    }
    
    let isOpenUkulele : isOpenUkulele = {
        
        if let _ = try? keychain.get(IDENTIFIER_IAP_ALL_UKULELE) {
            return true
        }
        if let _ = try? keychain.get(IDENTIFIER_IAP_PREMIUM) {
            return true
        }
        return false
    }
    
    let premium : isPremium = {
        
        if let _ = try? keychain.get(IDENTIFIER_IAP_PREMIUM) {
            return true
        }
        return false
    }
    
    
    
    // Setter
    
    func unlockSignal() {
        do {
            try keychain.set(PURCHASED, key: IDENTIFIER_IAP_SIGNALPLUS)
        } catch let error {
            print("setting keychain to purchased failed")
            print(error)
        }
    }
    
    func unlockUkulele() {
        do {
            try keychain.set(PURCHASED, key: IDENTIFIER_IAP_ALL_UKULELE)
        } catch let error {
            print("setting keychain to purchased failed")
            print(error)
        }
    }
    
    
    func unlockPremium() {
        do {
            try keychain.set(PURCHASED, key: IDENTIFIER_IAP_PREMIUM)
        } catch let error {
            print("setting keychain to purchased failed")
            print(error)
        }
    }
    
    // for testing purposes only
    
    func unlockAll() {
        
        unlockSignal()
        unlockUkulele()
        //unlockPremium()
    }
    
    func lockAll() {
        
        do {
            try keychain.remove(IDENTIFIER_IAP_SIGNALPLUS)
            try keychain.remove(IDENTIFIER_IAP_ALL_UKULELE)
            try keychain.remove(IDENTIFIER_IAP_PREMIUM)
        } catch let error {
            print("setting keychain to purchased failed")
            print(error)
        }
    }
}
