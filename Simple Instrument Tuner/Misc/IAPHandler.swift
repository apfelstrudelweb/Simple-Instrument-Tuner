//
//  IAPHandler.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 19.04.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit

typealias isOpenGuitar = () -> Bool
typealias isOpenBanjo = () -> Bool
typealias isOpenUkulele = () -> Bool
typealias isOpenMandolin = () -> Bool
typealias isOpenBalalaika = () -> Bool

typealias isPremium = () -> Bool


var dictGuitar : Dictionary = [String : isOpenGuitar]()
var dictBanjo : Dictionary = [String : isOpenBanjo]()
var dictUkulele : Dictionary = [String : isOpenUkulele]()
var dictMandolin : Dictionary = [String : isOpenMandolin]()
var dictBalalaika : Dictionary = [String : isOpenBalalaika]()
var dictPremium : Dictionary = [String : isPremium]()

var dictIAP : Dictionary = ["Guitar" : dictGuitar,
                            "Banjo" : dictBanjo,
                            "Ukulele" : dictUkulele,
                            "Mandolin" : dictMandolin,
                            "Balalaika" : dictBalalaika,
                            "Premium" : dictPremium]

class IAPHandler: NSObject {
    
    override init() {
        dictGuitar["Guitar"] = openGuitar
        dictBanjo["Banjo"] = openBanjo
        dictUkulele["Ukulele"] = openUkulele
        dictMandolin["Mandolin"] = openMandolin
        dictBalalaika["Balalaika"] = openBalalaika
        dictPremium["Premium"] = premium
    }
    
    // Getter
    
    func displayAd() -> Bool {
        
        if let _ = KeyChain.load(key: KEYCHAIN_IAP_CALIBRATION) {
            return false
        }
        if let _ = KeyChain.load(key: KEYCHAIN_IAP_GUITAR) {
            return false
        }
        if let _ = KeyChain.load(key: KEYCHAIN_IAP_BANJO) {
            return false
        }
        if let _ = KeyChain.load(key: KEYCHAIN_IAP_UKULELE) {
            return false
        }
        if let _ = KeyChain.load(key: KEYCHAIN_IAP_MANDOLIN) {
            return false
        }
        if let _ = KeyChain.load(key: KEYCHAIN_IAP_BALALAIKA) {
            return false
        }
        if let _ = KeyChain.load(key: KEYCHAIN_IAP_PREMIUM) {
            return false
        }
        return true
    }
    
    func isOpenCalibration() -> Bool {
        if let _ = KeyChain.load(key: KEYCHAIN_IAP_CALIBRATION) {
            return true
        }
        if let _ = KeyChain.load(key: KEYCHAIN_IAP_PREMIUM) {
            return true
        }
        return false
    }
    
    let openGuitar : isOpenGuitar = {
        if let _ = KeyChain.load(key: KEYCHAIN_IAP_GUITAR) {
            return true
        }
        if let _ = KeyChain.load(key: KEYCHAIN_IAP_PREMIUM) {
            return true
        }
        return false
    }
    
    let openBanjo : isOpenBanjo = {
        if let _ = KeyChain.load(key: KEYCHAIN_IAP_BANJO) {
            return true
        }
        if let _ = KeyChain.load(key: KEYCHAIN_IAP_PREMIUM) {
            return true
        }
        return false
    }
    
    let openUkulele : isOpenUkulele = {
        if let _ = KeyChain.load(key: KEYCHAIN_IAP_UKULELE) {
            return true
        }
        if let _ = KeyChain.load(key: KEYCHAIN_IAP_PREMIUM) {
            return true
        }
        return false
    }
    
    let openMandolin : isOpenMandolin = {
        if let _ = KeyChain.load(key: KEYCHAIN_IAP_MANDOLIN) {
            return true
        }
        if let _ = KeyChain.load(key: KEYCHAIN_IAP_PREMIUM) {
            return true
        }
        return false
    }
    
    let openBalalaika : isOpenBalalaika = {
        if let _ = KeyChain.load(key: KEYCHAIN_IAP_BALALAIKA) {
            return true
        }
        if let _ = KeyChain.load(key: KEYCHAIN_IAP_PREMIUM) {
            return true
        }
        return false
    }
    
    
    let premium : isPremium = {
        if let _ = KeyChain.load(key: KEYCHAIN_IAP_PREMIUM) {
            return true
        }
        return false
    }
    
    
    
    // Setter
    
    func unlockCalibration() {
        let _ = KeyChain.save(key: KEYCHAIN_IAP_CALIBRATION, data: Data(from: true))
    }
    
    func unlockGuitar() {
        let _ = KeyChain.save(key: KEYCHAIN_IAP_GUITAR, data: Data(from: true))
    }
    
    func unlockBanjo() {
        let _ = KeyChain.save(key: KEYCHAIN_IAP_BANJO, data: Data(from: true))
    }
    
    func unlockUkulele() {
        let _ = KeyChain.save(key: KEYCHAIN_IAP_UKULELE, data: Data(from: true))
    }
    
    func unlockMandolin() {
        let _ = KeyChain.save(key: KEYCHAIN_IAP_MANDOLIN, data: Data(from: true))
    }
    
    func unlockBalalaika() {
        let _ = KeyChain.save(key: KEYCHAIN_IAP_BALALAIKA, data: Data(from: true))
    }
    
    func unlockPremium() {
        let _ = KeyChain.save(key: KEYCHAIN_IAP_PREMIUM, data: Data(from: true))
    }
}
