//
//  IAPHandler.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 19.04.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit
import KeychainAccess

typealias isOpenCalibration = () -> Bool
typealias isOpenGuitar = () -> Bool
typealias isOpenBanjo = () -> Bool
typealias isOpenUkulele = () -> Bool
typealias isOpenMandolin = () -> Bool
typealias isOpenBalalaika = () -> Bool
typealias isPremium = () -> Bool


let balalaikaDict =     ["Balalaika" :  [NSLocalizedString("Balalaika.iap1", comment: ""), NSLocalizedString("Balalaika.iap2", comment: "")]]
let banjoDict =         ["Banjo" :  [NSLocalizedString("Banjo.iap1", comment: ""), NSLocalizedString("Banjo.iap2", comment: "")]]
let guitarDict =        ["Guitar" :  [NSLocalizedString("Guitar.iap1", comment: ""), NSLocalizedString("Guitar.iap2", comment: "")]]
let mandolinDict =      ["Mandolin" :  [NSLocalizedString("Mandolin.iap1", comment: ""), NSLocalizedString("Mandolin.iap2", comment: "")]]
let ukuleleDict =       ["Ukulele" :  [NSLocalizedString("Ukulele.iap1", comment: ""), NSLocalizedString("Ukulele.iap2", comment: "")]]
let calibrationDict =   ["Calibration" :  [NSLocalizedString("Calibration.iap1", comment: ""), NSLocalizedString("Calibration.iap2", comment: "")]]
let premiumDict =       ["Premium" :  [NSLocalizedString("Premium.iap1", comment: ""), NSLocalizedString("Premium.iap2", comment: ""), NSLocalizedString("Premium.iap3", comment: "")]]

let iapOptionsArray = [balalaikaDict, banjoDict, guitarDict, mandolinDict, ukuleleDict, calibrationDict, premiumDict]


var dictCalibration: Dictionary = [String : isOpenCalibration]()
var dictGuitar: Dictionary = [String : isOpenGuitar]()
var dictBanjo: Dictionary = [String : isOpenBanjo]()
var dictUkulele: Dictionary = [String : isOpenUkulele]()
var dictMandolin: Dictionary = [String : isOpenMandolin]()
var dictBalalaika: Dictionary = [String : isOpenBalalaika]()
var dictPremium: Dictionary = [String : isPremium]()


var dictIAP : Dictionary = ["Calibration": dictCalibration,
                            "Guitar" : dictGuitar,
                            "Banjo" : dictBanjo,
                            "Ukulele" : dictUkulele,
                            "Mandolin" : dictMandolin,
                            "Balalaika" : dictBalalaika,
                            "Premium" : dictPremium]

let keychain = Keychain(service: KEYCHAIN_IAP_SERVICE)
let PURCHASED = "purchased"

class IAPHandler: NSObject {
    
    var dictUnlockMethods : Dictionary<String, ()->()> = [ : ]
    
    override init() {
        super.init()
        
        dictUnlockMethods = ["Calibration": unlockCalibration,
                             "Guitar" : unlockGuitar,
                             "Banjo" : unlockBanjo,
                             "Ukulele" : unlockUkulele,
                             "Mandolin" : unlockMandolin,
                             "Balalaika" : unlockBalalaika,
                             "Premium" : unlockPremium]
        
        
        dictCalibration["Calibration"] = self.isOpenCalibration
        dictGuitar["Guitar"] = self.isOpenGuitar
        dictBanjo["Banjo"] = self.isOpenBanjo
        dictUkulele["Ukulele"] = self.isOpenUkulele
        dictMandolin["Mandolin"] = self.isOpenMandolin
        dictBalalaika["Balalaika"] = self.isOpenBalalaika
        dictPremium["Premium"] = self.premium
        
    }
    
    
    
    var productsArray: [Product]?
    
    private static var sharedIAPHandler: IAPHandler = {
        let iapManager = IAPHandler()
        
        dictCalibration["Calibration"] = iapManager.isOpenCalibration
        dictGuitar["Guitar"] = iapManager.isOpenGuitar
        dictBanjo["Banjo"] = iapManager.isOpenBanjo
        dictUkulele["Ukulele"] = iapManager.isOpenUkulele
        dictMandolin["Mandolin"] = iapManager.isOpenMandolin
        dictBalalaika["Balalaika"] = iapManager.isOpenBalalaika
        dictPremium["Premium"] = iapManager.premium
        
        return iapManager
    }()
    
    class func shared() -> IAPHandler {
        return sharedIAPHandler
    }
    
    
    // Getter
    
    func displayAd() -> Bool {
        
        if let _ = try? keychain.get(IDENTIFIER_IAP_CALIBRATION){
            return false
        }
        if let _ = try? keychain.get(IDENTIFIER_IAP_GUITAR) {
            return false
        }
        if let _ = try? keychain.get(IDENTIFIER_IAP_BANJO) {
            return false
        }
        if let _ = try? keychain.get(IDENTIFIER_IAP_UKULELE) {
            return false
        }
        if let _ = try? keychain.get(IDENTIFIER_IAP_MANDOLIN) {
            return false
        }
        if let _ = try? keychain.get(IDENTIFIER_IAP_BALALAIKA) {
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
        if isOpenCalibration() && isOpenBanjo() && isOpenGuitar() && isOpenUkulele() && isOpenMandolin() && isOpenBalalaika() {
            return true
        }
        
        return false
    }
    
    func isOpenCalibration() -> Bool {
        
        if let _ = try? keychain.get(IDENTIFIER_IAP_CALIBRATION) {
            return true
        }
        if let _ = try? keychain.get(IDENTIFIER_IAP_PREMIUM) {
            return true
        }
        return false
    }
    
    let isOpenGuitar : isOpenGuitar = {
        
        if let _ = try? keychain.get(IDENTIFIER_IAP_GUITAR) {
            return true
        }
        if let _ = try? keychain.get(IDENTIFIER_IAP_PREMIUM) {
            return true
        }
        return false
    }
    
    let isOpenBanjo : isOpenBanjo = {
        
        if let _ = try? keychain.get(IDENTIFIER_IAP_BANJO) {
            return true
        }
        if let _ = try? keychain.get(IDENTIFIER_IAP_PREMIUM) {
            return true
        }
        return false
    }
    
    let isOpenUkulele : isOpenUkulele = {
        
        if let _ = try? keychain.get(IDENTIFIER_IAP_UKULELE) {
            return true
        }
        if let _ = try? keychain.get(IDENTIFIER_IAP_PREMIUM) {
            return true
        }
        return false
    }
    
    let isOpenMandolin : isOpenMandolin = {
        
        if let _ = try? keychain.get(IDENTIFIER_IAP_MANDOLIN) {
            return true
        }
        if let _ = try? keychain.get(IDENTIFIER_IAP_PREMIUM) {
            return true
        }
        return false
    }
    
    let isOpenBalalaika : isOpenBalalaika = {
        
        if let _ = try? keychain.get(IDENTIFIER_IAP_BALALAIKA) {
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
    
    func unlockCalibration() {
        do {
            try keychain.set(PURCHASED, key: IDENTIFIER_IAP_CALIBRATION)
        } catch let error {
            print("setting keychain to purchased failed")
            print(error)
        }
    }
    
    func unlockGuitar() {
        do {
            try keychain.set(PURCHASED, key: IDENTIFIER_IAP_GUITAR)
        } catch let error {
            print("setting keychain to purchased failed")
            print(error)
        }
    }
    
    func unlockBanjo() {
        do {
            try keychain.set(PURCHASED, key: IDENTIFIER_IAP_BANJO)
        } catch let error {
            print("setting keychain to purchased failed")
            print(error)
        }
    }
    
    func unlockUkulele() {
        do {
            try keychain.set(PURCHASED, key: IDENTIFIER_IAP_UKULELE)
        } catch let error {
            print("setting keychain to purchased failed")
            print(error)
        }
    }
    
    func unlockMandolin() {
        do {
            try keychain.set(PURCHASED, key: IDENTIFIER_IAP_MANDOLIN)
        } catch let error {
            print("setting keychain to purchased failed")
            print(error)
        }
    }
    
    func unlockBalalaika() {
        do {
            try keychain.set(PURCHASED, key: IDENTIFIER_IAP_BALALAIKA)
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
        
        unlockCalibration()
        unlockGuitar()
        unlockBanjo()
        unlockUkulele()
        unlockMandolin()
        unlockBalalaika()
        //unlockPremium()
    }
    
    func lockAll() {
        
        do {
            try keychain.remove(IDENTIFIER_IAP_CALIBRATION)
            try keychain.remove(IDENTIFIER_IAP_GUITAR)
            try keychain.remove(IDENTIFIER_IAP_BANJO)
            try keychain.remove(IDENTIFIER_IAP_UKULELE)
            try keychain.remove(IDENTIFIER_IAP_MANDOLIN)
            try keychain.remove(IDENTIFIER_IAP_BALALAIKA)
            try keychain.remove(IDENTIFIER_IAP_PREMIUM)
        } catch let error {
            print("setting keychain to purchased failed")
            print(error)
        }
    }
    
}
