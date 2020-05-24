//
//  IAPTableViewCell.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 22.04.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit

class IAPTableViewCell: UITableViewCell {
    
    var title: String? {
        didSet {
            productLabel.text = NSLocalizedString(title ?? "", comment: "")
        }
    }
    var descriptionText: [String]? {
        didSet {
            descriptionTextView.attributedText = Utils().generateBulletList(stringList: descriptionText ?? [], font: descriptionTextView.font!, bullet: " ⮕")
        }
    }
    
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var symbolImageView: UIImageView!
    @IBOutlet weak var glassView: UIView!
    
    
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
