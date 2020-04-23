//
//  IAPHandler.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 19.04.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit
import KeychainAccess

typealias isOpenGuitar = () -> Bool
typealias isOpenBanjo = () -> Bool
typealias isOpenUkulele = () -> Bool
typealias isOpenMandolin = () -> Bool
typealias isOpenBalalaika = () -> Bool

typealias isPremium = () -> Bool


let arrayString = ["get different tunings for your balalaika", "removal of ads"]

let balalaikaDict =     ["Balalaika" :  ["get different tunings for your balalaika", "removal of ads"]]
let banjaDict =         ["Banjo" :  ["get different tunings for your banjo", "removal of ads"]]
let guitarDict =        ["Guitar" :  ["get different tunings for your guitar", "removal of ads"]]
let mandolinDict =      ["Mandolin" :  ["get different tunings for your mandolin", "removal of ads"]]
let ukuleleDict =       ["Ukulele" :  ["get different tunings for your ukulele", "removal of ads"]]
let calibrationDict =   ["Calibration" :  ["tune your instruments from 430-450 Hz", "removal of ads"]]
let premiumDict =       ["Premium" :  ["get different tunings for all your instruments", "tune your instruments from 430-450 Hz", "removal of ads"]]

let iapOptionsArray = [balalaikaDict, banjaDict, guitarDict, mandolinDict, ukuleleDict, calibrationDict, premiumDict]


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

let keychain = Keychain(service: KEYCHAIN_IAP_SERVICE)
let PURCHASED = "purchased"

class IAPHandler: NSObject {
    
    override init() {
        dictGuitar["Guitar"] = isOpenGuitar
        dictBanjo["Banjo"] = isOpenBanjo
        dictUkulele["Ukulele"] = isOpenUkulele
        dictMandolin["Mandolin"] = isOpenMandolin
        dictBalalaika["Balalaika"] = isOpenBalalaika
        dictPremium["Premium"] = premium
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
