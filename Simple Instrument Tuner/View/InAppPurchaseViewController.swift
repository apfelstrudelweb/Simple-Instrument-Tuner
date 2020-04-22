//
//  InAppPurchaseViewController.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 19.04.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit
import StoreKit



class InAppPurchaseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet var productTableView: UITableView!
    
    var instrument: Instrument?
    var productsArray = [SKProduct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // In App Purchase
        PKIAPHandler.shared.setProductIds(ids: productIds)
        PKIAPHandler.shared.fetchAvailableProducts { [weak self](products)   in
            
            DispatchQueue.main.async {
                self?.productsArray = products.sorted(by: { $0.price.decimalValue < $1.price.decimalValue })
                self?.productTableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: IAPTableViewCell = tableView.dequeueReusableCell(withIdentifier: "iapCell", for: indexPath) as! IAPTableViewCell
 
        let nib:Array = Bundle.main.loadNibNamed("IAPTableViewCell", owner: self, options: nil)!
        cell = (nib[0] as? IAPTableViewCell)!
        
        let product = productsArray[indexPath.row]

        cell.productLabel.text = product.localizedTitle
        cell.descriptionTextView.text = "Rookie ist frech und schwul"
        cell.priceLabel.text = "\(product.price.stringValue) \(product.priceLocale.currencySymbol ?? "$")"
        
        let imageName = "\(product.localizedTitle.lowercased())Symbol"
        cell.symbolImageView.image = UIImage(named: imageName)
        cell.symbolImageView.transform = cell.symbolImageView.transform.rotated(by: -.pi/5)
        
        return cell
    }
    
}
