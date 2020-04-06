//
//  SettingsViewController.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 05.04.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit
import StoreKit
import iOSDropDown

protocol SettingsViewControllerDelegate: AnyObject {

    func didChangeInstrument()
}

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var dropDown: DropDown!
    @IBOutlet weak var productTableView: UITableView!
    
    var productsArray = [SKProduct]()
    
    var backgroundColor = UIColor.black {
        didSet {
            self.view.backgroundColor = backgroundColor
        }
    }
    
    weak var settingsDelegate: SettingsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let path = Bundle.main.path(forResource: "Instruments", ofType: "plist"), let array = NSArray(contentsOfFile: path) else { return }
        
        for instrument in array.enumerated() {
            let dict = instrument.element as! NSDictionary
    
            guard let name = dict.value(forKey: "name") as? String, let image = dict.value(forKey: "image") as? String, let id = dict.value(forKey: "id") as? Int else { continue }
            
            dropDown.optionIds?.append(id)
            dropDown.optionArray.append(name)
            dropDown.optionImageArray.append(image)
        }

        
        dropDown.selectedIndex = 0
        dropDown.text = dropDown.optionArray[dropDown.selectedIndex ?? 0]
        
        dropDown.didSelect{(selectedText , index ,id) in
            print("Selected String: \(selectedText) \n index: \(index)")
            
            self.settingsDelegate?.didChangeInstrument()
        }

        PKIAPHandler.shared.setProductIds(ids: ["ch.vormbrock.simpleukuleletuner.alluke", "ch.vormbrock.simpleukuleletuner.premium", "ch.vormbrock.simpleukuleletuner.signalplus"])
        PKIAPHandler.shared.fetchAvailableProducts { [weak self](products)   in
            
            DispatchQueue.main.async {
                self?.productsArray = products
                self?.productTableView.reloadData()
            }
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
