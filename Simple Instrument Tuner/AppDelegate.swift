//
//  AppDelegate.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 21.03.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit
import GoogleMobileAds
import SwiftRater
import StoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var productsArray = [Product]()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        SwiftRater.daysUntilPrompt = 7
        SwiftRater.usesUntilPrompt = 10
        SwiftRater.significantUsesUntilPrompt = 3
        SwiftRater.daysBeforeReminding = 1
        SwiftRater.showLaterButton = true
        SwiftRater.debugMode = false
        SwiftRater.appLaunched()
        
        // TODO: IMPORTANT: comment out when submitting to the AppStore
        IAPHandler().unlockAll()
//        IAPHandler().lockAll()
//        IAPHandler().unlockBanjo()
//        IAPHandler().unlockGuitar()
//        IAPHandler().unlockUkulele()
//        IAPHandler().unlockMandolin()
//        IAPHandler().unlockBalalaika()
//        IAPHandler().unlockCalibration()
        
        // In App Purchase
        PKIAPHandler.shared.setProductIds(ids: productIds)
        PKIAPHandler.shared.fetchAvailableProducts { [weak self](products)   in
            
            for option in iapOptionsArray {
                let name = option.keys.first
                if let skProduct = products.first(where: {$0.localizedTitle == name}) {
                    let price =  "\(skProduct.price.stringValue) \(skProduct.priceLocale.currencySymbol ?? "$")"
                    let product = Product(title: name, description: option.values.first, price: price, symbol: UIImage(named: name?.lowercased() ?? ""), skProduct: skProduct)
                    self?.productsArray.append(product)
                }
            }
            IAPHandler.shared().productsArray = self?.productsArray
        }
 
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}

