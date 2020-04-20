//
//  SettingsViewController.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 05.04.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit
import StoreKit

import fluid_slider
import PureLayout

protocol SettingsViewControllerDelegate: AnyObject {
    
    func didChangeInstrument()
    func didChangeTuning()
}


class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TuningTableViewControllerDelegate {
    
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var instrumentDropDown: DropDown!
    @IBOutlet weak var embeddedCalibrationView: UIView!
    @IBOutlet weak var iapButtonView: UIView!
    
    
    private var embeddedTuningViewController: TuningTableViewController!
    var embeddedCalibrationViewController: CalibrationViewController!
    
    var productsArray = [SKProduct]()
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        //        // In App Purchase
        //        // TODO - put them into constants
        //        PKIAPHandler.shared.setProductIds(ids: ["ch.vormbrock.simpleukuleletuner.alluke", "ch.vormbrock.simpleukuleletuner.premium", "ch.vormbrock.simpleukuleletuner.signalplus"])
        //        PKIAPHandler.shared.fetchAvailableProducts { [weak self](products)   in
        //
        //            DispatchQueue.main.async {
        //                self?.productsArray = products
        //                self?.productTableView.reloadData()
        //            }
        //        }
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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath)
        cell.textLabel?.text = productsArray[indexPath.row].localizedTitle
        cell.textLabel?.textColor = .white
        return cell
    }

    
    @IBAction func closeButtonTouched(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func upgradeButtonTouched(_ sender: Any) {
        //performSegue(withIdentifier: "iapSegue", sender: self)
    }
    
    @IBAction func restoreButtonTouched(_ sender: Any) {
        
    }
    
}
