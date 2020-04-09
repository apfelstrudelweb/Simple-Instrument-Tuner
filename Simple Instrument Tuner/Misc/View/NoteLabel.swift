//
//  NoteLabel.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 07.04.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit

class NoteLabel: UILabel {
    
    var localizedText: String? {
        didSet {
            
            if localizedText?[0] == "B" && String(Locale.preferredLanguages[0].prefix(2)) == "de" {
                var suffix = ""
                if let octave = localizedText?[1] { suffix = octave }
                self.text = "H" + suffix
            } else {
                self.text = localizedText
            }
            
        }
    }

}
