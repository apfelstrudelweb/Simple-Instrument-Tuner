//
//  InAppPurchaseViewController.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 19.04.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit

struct Product {
    var title: String?
    var description: [String]?
    var price: String?
    var symbol: UIImage?
}


class InAppPurchaseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet var productTableView: UITableView!
    
    var instrument: Instrument?
    var productsArray: [Product]? = IAPHandler.shared().productsArray
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        productTableView.rowHeight = UITableView.automaticDimension
        productTableView.estimatedRowHeight = 200
        
        if productsArray?.count == 0 {
            self.showAlert(title:"No In-App-Purchase options found", msg:"Please check your internet connection and try again!")
            return
        }
        
        productTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productsArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: IAPTableViewCell = tableView.dequeueReusableCell(withIdentifier: "iapCell", for: indexPath) as! IAPTableViewCell
        
        let nib:Array = Bundle.main.loadNibNamed("IAPTableViewCell", owner: self, options: nil)!
        cell = (nib[0] as? IAPTableViewCell)!
        
        cell.glassView.isHidden = true
        cell.selectionStyle = .default
        
        let product = productsArray![indexPath.row]
        
        cell.productLabel.text = product.title
        cell.descriptionTextView.attributedText = Utils().generateBulletList(stringList: product.description!, font: cell.descriptionTextView.font!, bullet: "⮕")
        cell.priceLabel.text = product.price
        cell.symbolImageView.image = product.symbol
        
        if indexPath.row % 2 == 1 {
            cell.symbolImageView.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        
        let sizeThatFitsTextView = cell.descriptionTextView.sizeThatFits(CGSize(width: cell.descriptionTextView.frame.size.width, height: CGFloat(MAXFLOAT)))
        let heightOfText = sizeThatFitsTextView.height
        
        let fact: CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? 1 : 0.8
        
        cell.textViewHeight.constant = fact * heightOfText
        cell.descriptionTextView.layer.cornerRadius = UIDevice.current.userInterfaceIdiom == .phone ? 10 : 15
        
        print(product.title)
        
        if let dict = dictIAP[product.title!], let isOpenInstrument = dict[product.title!]  {
            if isOpenInstrument() == true || IAPHandler().isOpenPremium() {
                cell.glassView.isHidden = false
                cell.selectionStyle = .none
            }
        }
        
        if IAPHandler().isOpenPremium() {
            cell.glassView.isHidden = false
            cell.selectionStyle = .none
        }
        
        if product.title == "Calibration" && IAPHandler().isOpenCalibration() {
            cell.glassView.isHidden = false
            cell.selectionStyle = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected")
    }
    
    
}

extension UIViewController {
    func showAlert(title: String, msg: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
