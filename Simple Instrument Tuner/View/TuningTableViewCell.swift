//
//  TuningTableViewCell.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 15.04.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit

class TuningTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var switchButton: UIImageView!
    @IBOutlet weak var standardIndicatorView: UIView!
    
    var isLocked: Bool = false
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor(patternImage: UIImage(named: "settingsPattern.png")!)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
