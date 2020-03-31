//
//  BridgeViewController.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 25.03.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit
import PureLayout
import AudioKit


/// Delegate for keyboard events
public protocol AKKeyboardDelegate: class {
    /// Note on evenets
    func noteOn(note: MIDINoteNumber)
    /// Note off events
    func noteOff(note: MIDINoteNumber)
    
    func stopAllNotes()
}

class BridgeViewController: UIViewController, AKMIDIListener {

    @IBOutlet weak var ledStackView: UIStackView!
    
    @IBOutlet var buttonCollection: [NoteButton]! {
        didSet {
            buttonCollection.sort { $0.tag < $1.tag }
            buttonCollection.forEach {
                $0.note = guitarNotesArray[$0.tag]
            }
        }
    }
    
    open weak var keyboardDelegate: AKKeyboardDelegate?
    
    @IBOutlet var stringCollection: [UIImageView]! {
        didSet {
            stringCollection.sort { $0.tag < $1.tag }
            stringCollection.forEach {
                $0.autoSetDimension(.width, toSize: CGFloat(10*exp(-0.2*(Float($0.tag)))))
            }
        }
    }
    
    var activeSoundTag = -1
    open weak var delegate: AKKeyboardDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func buttonTouched(_ sender: Any) {
        let noteButton : NoteButton = sender as! NoteButton
        
        delegate?.stopAllNotes()
        buttonCollection.forEach {
            if $0.tag != noteButton.tag {
                $0.isActive = false
            }
        }

        noteButton.isActive = !noteButton.isActive
        
        if noteButton.isActive == true {
            delegate?.noteOn(note: noteButton.note.number)
        } else {
            delegate?.noteOff(note: noteButton.note.number)
        }
    }
}
