//
//  InAppPurchaseViewController.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 19.04.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit
import StoreKit

struct Product {
    var title: String?
    var description: [String]?
    var price: String?
    var symbol: UIImage?
}


class InAppPurchaseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet var productTableView: UITableView!
    
    var instrument: Instrument?
    var productsArray = [Product]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // In App Purchase
        PKIAPHandler.shared.setProductIds(ids: productIds)
        PKIAPHandler.shared.fetchAvailableProducts { [weak self](products)   in
            
            DispatchQueue.main.async {
               
                for option in iapOptionsArray {
                    let name = option.keys.first
                    if let skProduct = products.first(where: {$0.localizedTitle == name}) {
                        let price =  "\(skProduct.price.stringValue) \(skProduct.priceLocale.currencySymbol ?? "$")"
                        let product = Product(title: name, description: option.values.first, price: price, symbol: UIImage(named: name?.lowercased() ?? ""))
                        self?.productsArray.append(product)
                    }
                }
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

        cell.productLabel.text = product.title
        cell.descriptionTextView.attributedText = add(stringList: product.description!, font: cell.descriptionTextView.font!, bullet: "")//product.description
        cell.priceLabel.text = product.price
        cell.symbolImageView.image = product.symbol
        
        if indexPath.row % 2 == 1 {
            cell.symbolImageView.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        
        if product.title == "Premium" {
            cell.textViewHeight.constant = 250
        } else  {
            cell.textViewHeight.constant = 200
        }
        
        return cell
    }
    
    func add(stringList: [String],
             font: UIFont,
             bullet: String = "\u{2022}",
             indentation: CGFloat = 20,
             lineSpacing: CGFloat = 2,
             paragraphSpacing: CGFloat = 2,
             textColor: UIColor = .white,
             bulletColor: UIColor = .white) -> NSAttributedString {

        let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: textColor]
        let bulletAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: bulletColor]

        let paragraphStyle = NSMutableParagraphStyle()
        let nonOptions = [NSTextTab.OptionKey: Any]()
        paragraphStyle.tabStops = [
            NSTextTab(textAlignment: .left, location: indentation, options: nonOptions)]
        paragraphStyle.defaultTabInterval = indentation
        //paragraphStyle.firstLineHeadIndent = 0
        //paragraphStyle.headIndent = 20
        //paragraphStyle.tailIndent = 1
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.paragraphSpacing = paragraphSpacing
        paragraphStyle.headIndent = indentation

        let bulletList = NSMutableAttributedString()
        for string in stringList {
            let formattedString = "\(bullet)\t\(string)\n"
            let attributedString = NSMutableAttributedString(string: formattedString)

            attributedString.addAttributes(
                [NSAttributedString.Key.paragraphStyle : paragraphStyle],
                range: NSMakeRange(0, attributedString.length))

            attributedString.addAttributes(
                textAttributes,
                range: NSMakeRange(0, attributedString.length))

            let string:NSString = NSString(string: formattedString)
            let rangeForBullet:NSRange = string.range(of: bullet)
            attributedString.addAttributes(bulletAttributes, range: rangeForBullet)
            bulletList.append(attributedString)
        }

        return bulletList
    }
    
}
