//
//  SettingsViewController.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 05.04.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit

import fluid_slider
import PureLayout
import StoreKit
import EasyTipView

protocol SettingsViewControllerDelegate: class {
    
    func didChangeInstrument()
    func didChangeTuning()
}


class SettingsViewController: UIViewController, TuningTableViewControllerDelegate, PKIAPHandlerDelegate, EasyTipViewDelegate {

    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var instrumentDropDown: DropDown!
    @IBOutlet weak var embeddedCalibrationView: UIView!
    @IBOutlet weak var iapButtonView: UIView!
    @IBOutlet weak var upgradeButton: UIButton!
    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var instrumentDropdownLabel: UILabel!
    
    
    private var embeddedTuningViewController: TuningTableViewController!
    var embeddedCalibrationViewController: CalibrationViewController!
    
    
    var backgroundColor = UIColor.black {
        didSet {
            self.view.backgroundColor = backgroundColor
        }
    }
    
    weak var settingsDelegate: SettingsViewControllerDelegate?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TuningTableViewController,
            segue.identifier == "tuningSegue" {
            embeddedTuningViewController = vc
            embeddedTuningViewController.tuningDelegate = self
        }
        if let vc = segue.destination as? CalibrationViewController,
            segue.identifier == "calibrationSegue" {
            embeddedCalibrationViewController = vc
        }
    }
    
    
    fileprivate func showTooltip() {

        EasyTipView.show(forView: self.instrumentDropDown,
                         withinSuperview: self.view,
                         text: NSLocalizedString("Info.selectInstrument", comment: ""),
                         preferences: EasyTipView.globalPreferences,
                         delegate: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PKIAPHandler.shared.pkiDelegate = self
        
        closeButton.isEnabled = Utils().getInstrument() == nil ? false : true
        upgradeButton.isEnabled = closeButton.isEnabled
        restoreButton.isEnabled = closeButton.isEnabled
        
        handleInstrumentsList()
        handleTuningsList()
        
        embeddedTuningViewController.tableView.layer.borderColor = #colorLiteral(red: 0.1529633105, green: 0.1679426432, blue: 0.1874132752, alpha: 1)
        embeddedTuningViewController.tableView.layer.borderWidth = 2.0
        embeddedTuningViewController.tableView.layer.masksToBounds = true
        embeddedTuningViewController.tableView.layer.cornerRadius = 4
        
        instrumentDropDown.layer.borderColor = embeddedTuningViewController.tableView.layer.borderColor
        instrumentDropDown.layer.borderWidth = embeddedTuningViewController.tableView.layer.borderWidth
        instrumentDropDown.layer.masksToBounds = embeddedTuningViewController.tableView.layer.masksToBounds
        instrumentDropDown.layer.cornerRadius = embeddedTuningViewController.tableView.layer.cornerRadius
        
        embeddedCalibrationView.layer.borderColor = embeddedTuningViewController.tableView.layer.borderColor
        embeddedCalibrationView.layer.borderWidth = embeddedTuningViewController.tableView.layer.borderWidth
        embeddedCalibrationView.layer.masksToBounds = embeddedTuningViewController.tableView.layer.masksToBounds
        embeddedCalibrationView.layer.cornerRadius = embeddedTuningViewController.tableView.layer.cornerRadius
        
        iapButtonView.layer.borderColor = embeddedTuningViewController.tableView.layer.borderColor
        iapButtonView.layer.borderWidth = embeddedTuningViewController.tableView.layer.borderWidth
        iapButtonView.layer.masksToBounds = embeddedTuningViewController.tableView.layer.masksToBounds
        iapButtonView.layer.cornerRadius = embeddedTuningViewController.tableView.layer.cornerRadius
        
        iapButtonView.backgroundColor = UIColor(patternImage: UIImage(named: "settingsPattern.png")!)
        
        if IAPHandler().isOpenPremium() == true {
            upgradeButton.isEnabled = false
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didPerformIAP), name: .didPerformIAP, object: nil)
        
        if Utils().getInstrument() == nil {
            showTooltip()
        }
    }
    
    
    fileprivate func handleInstrumentsList() {
        
        let options = Utils().getInstrumentsArray()
        
        instrumentDropDown.optionIds = options.ids
        instrumentDropDown.optionArray = options.names!
        instrumentDropDown.optionImageArray = options.images!
        
        if let receivedData = KeyChain.load(key: KEYCHAIN_CURRENT_INSTRUMENT_ID) {
            let currentInstrumentId = receivedData.to(type: Int.self)
            instrumentDropDown.selectedIndex = currentInstrumentId
            instrumentDropDown.text = instrumentDropDown.optionArray[instrumentDropDown.selectedIndex ?? 0]
        }
        
        instrumentDropDown.didSelect{(selectedText , index ,id) in
            
            self.closeButton.isEnabled = true
            Utils().dismisAllTooltips(view: self.view)
            
            Utils().saveInstrument(index: index)
            self.settingsDelegate?.didChangeInstrument()
            self.handleTuningsList()
            
            let index = Utils().getTuningId()
            
            Utils().saveTuning(index: index)
            self.settingsDelegate?.didChangeTuning()
        }
    }
    
    fileprivate func handleTuningsList() {
        
        embeddedTuningViewController.instrument = Utils().getInstrument()
        embeddedTuningViewController.tunings = Utils().getInstrument()?.tunings
        embeddedTuningViewController.tableView.reloadData()
    }
    
    // MARK: TuningTableViewControllerDelegate
    func didChangeTuning() {
        self.settingsDelegate?.didChangeTuning()
    }
    
    
    @IBAction func closeButtonTouched(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func upgradeButtonTouched(_ sender: Any) {
        //performSegue(withIdentifier: "iapSegue", sender: self)
    }
    
    @IBAction func restoreButtonTouched(_ sender: Any) {
        PKIAPHandler.shared.restorePurchase()
    }
    
    // MARK
    func productsRestored(products: [String]) {
        
        if products.count == 0 {
            self.showAlert(title:"Info", msg: " You've made no in-app purchases yet. Thus no item can be restored.")
            return
        }
        
        var alertText = "The follwing products have been restored:"
        
        for product in products {
            if let productTitle = iapIdentifierDict[product] {
                alertText += "\n- \(productTitle)"
                
                IAPHandler().dictUnlockMethods[productTitle]!()
            }
        }
        
        NotificationCenter.default.post(name: .didPerformIAP, object: nil)
        
        self.showAlert(title:"Success", msg: alertText)
        
        if IAPHandler().isOpenPremium() == true {
            upgradeButton.isEnabled = false
        }
    }
    
    @objc func didPerformIAP(_ notification: Notification) {
        
        if IAPHandler().isOpenPremium() == true {
            upgradeButton.isEnabled = false
        }
    }
    
    func easyTipViewDidDismiss(_ tipView: EasyTipView) {
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
