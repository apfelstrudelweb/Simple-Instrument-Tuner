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


class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var instrumentDropDown: DropDown!
    @IBOutlet weak var tuningDropDown: DropDown!
    @IBOutlet weak var productTableView: UITableView!
    @IBOutlet weak var calibrationSlider: CalibrationSlider!
    
    var productsArray = [SKProduct]()
    
    var backgroundColor = UIColor.black {
        didSet {
            self.view.backgroundColor = backgroundColor
        }
    }
    
    weak var settingsDelegate: SettingsViewControllerDelegate?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        handleInstrumentsList()
        handleTuningsList()

        // In App Purchase
        // TODO - put them into constants
        PKIAPHandler.shared.setProductIds(ids: ["ch.vormbrock.simpleukuleletuner.alluke", "ch.vormbrock.simpleukuleletuner.premium", "ch.vormbrock.simpleukuleletuner.signalplus"])
        PKIAPHandler.shared.fetchAvailableProducts { [weak self](products)   in
            
            DispatchQueue.main.async {
                self?.productsArray = products
                self?.productTableView.reloadData()
            }
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

            Utils().saveInstrument(index: index)
            self.settingsDelegate?.didChangeInstrument()
            self.handleTuningsList()
            
            let index = Utils().getTuningId()
            
            Utils().saveTuning(index: index)
            self.settingsDelegate?.didChangeTuning()
        }
    }
    
    fileprivate func handleTuningsList() {
        
        tuningDropDown.optionArray = Utils().getTuningsArray()
        
        if tuningDropDown.optionArray.count == 0 { return }
             
        let currentTuningId = Utils().getTuningId()
        tuningDropDown.selectedIndex = currentTuningId
        let text = tuningDropDown.optionArray[currentTuningId]
        tuningDropDown.text = text.components(separatedBy: "---").first
        
        tuningDropDown.didSelect{(selectedText , index ,id) in
            Utils().saveTuning(index: index)
            self.settingsDelegate?.didChangeTuning()
        }
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
    
}
