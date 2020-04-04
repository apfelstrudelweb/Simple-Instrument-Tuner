//
//  NoteButton.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 28.03.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit
import PureLayout

class NoteButton: UIButton {

    var isActive = false {
        didSet {
            let backgroundImage = isActive == true ? UIImage(named: "noteButtonActive") : UIImage(named: "noteButtonPassive")
            self.setImage(backgroundImage, for: .normal)
        }
    }
    
    var note = Note(noteName: "", frequency: 0, number: 0) {
        didSet {
            
            self.setNeedsLayout()
            self.layoutIfNeeded()
            
            let noteLabel = UILabel()
            let fact: CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? 0.5 : 0.9
            noteLabel.font = UIFont.boldSystemFont(ofSize: fact*self.bounds.size.height)
            noteLabel.text = note.noteName
            self.addSubview(noteLabel)
            noteLabel.autoCenterInSuperview()
        }
    }

}