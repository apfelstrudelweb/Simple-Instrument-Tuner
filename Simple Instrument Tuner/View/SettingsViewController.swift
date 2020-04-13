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
        
        guard let path = Bundle.main.path(forResource: INSTRUMENTS_PLIST_FILE, ofType: "plist"), let array = NSArray(contentsOfFile: path) else { return }
        
        // Instruments
        for instrument in array.enumerated() {
            let dict = instrument.element as! NSDictionary
            
            guard let name = dict.value(forKey: "name") as? String, let image = dict.value(forKey: "image") as? String, let id = dict.value(forKey: "id") as? Int else { continue }
            
            instrumentDropDown.optionIds?.append(id)
            instrumentDropDown.optionArray.append(name)
            instrumentDropDown.optionImageArray.append(image)
        }
        
        if let receivedData = KeyChain.load(key: KEYCHAIN_CURRENT_INSTRUMENT_ID) {
            let currentInstrumentId = receivedData.to(type: Int.self)
            instrumentDropDown.selectedIndex = currentInstrumentId
            instrumentDropDown.text = instrumentDropDown.optionArray[instrumentDropDown.selectedIndex ?? 0]
        }
        
        instrumentDropDown.didSelect{(selectedText , index ,id) in
            print("Selected String: \(selectedText) \n index: \(index)")
            
            let data = Data(from: index)
            let _ = KeyChain.save(key: KEYCHAIN_CURRENT_INSTRUMENT_ID, data: data)
            
            self.settingsDelegate?.didChangeInstrument()
            self.populateTuningDropDown()
            //self.dismiss(animated: true, completion: nil)
        }
        
        // Tuning
        populateTuningDropDown()
        
        var currentTuningId = 0
        
        if let receivedData = KeyChain.load(key: KEYCHAIN_CURRENT_TUNING_ID) {
            currentTuningId = receivedData.to(type: Int.self)
        }
        
        if  currentTuningId > tuningDropDown.optionArray.count {
            currentTuningId = 0
        }
        
        tuningDropDown.selectedIndex = currentTuningId
        let text = tuningDropDown.optionArray[tuningDropDown.selectedIndex ?? 0]
        tuningDropDown.text = text.components(separatedBy: "---").first
        
        tuningDropDown.didSelect{(selectedText , index ,id) in
            print("Selected String: \(selectedText) \n index: \(index)")
            
            let data = Data(from: index)
            let _ = KeyChain.save(key: KEYCHAIN_CURRENT_TUNING_ID, data: data)
            
            self.settingsDelegate?.didChangeTuning()
            //self.dismiss(animated: true, completion: nil)
        }
        
        
        // IAP
        
        PKIAPHandler.shared.setProductIds(ids: ["ch.vormbrock.simpleukuleletuner.alluke", "ch.vormbrock.simpleukuleletuner.premium", "ch.vormbrock.simpleukuleletuner.signalplus"])
        PKIAPHandler.shared.fetchAvailableProducts { [weak self](products)   in
            
            DispatchQueue.main.async {
                self?.productsArray = products
                self?.productTableView.reloadData()
            }
        }
        
    }
    
    func populateTuningDropDown() {
        
        guard let instrument = Utils().getInstrument(), let tunings = instrument.tunings else { return }
        
        tuningDropDown.optionArray = []
        
        for tuning in tunings {
            guard let name = tuning.name else { continue }
            guard let notes = tuning.notes else { continue }
            
            var noteString = ""
            for (index, note) in notes.enumerated() {
                
                if index < notes.count - 1 {
                    noteString += "\(note) - "
                } else {
                    noteString += "\(note)"
                }
                
            }
            
            let string = "\(name) ---\(noteString)"
            tuningDropDown.optionArray.append(string)
        }
        
        tuningDropDown.selectedIndex = 0
        let text = tuningDropDown.optionArray[tuningDropDown.selectedIndex ?? 0]
        tuningDropDown.text = text.components(separatedBy: "---").first
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
