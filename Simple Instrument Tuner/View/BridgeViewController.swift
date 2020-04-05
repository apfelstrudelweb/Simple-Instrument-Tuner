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
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var bridgeImageView: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    
    
    open weak var keyboardDelegate: AKKeyboardDelegate?

    
    var buttonCollection = [NoteButton]()
    
    var activeSoundTag = -1
    open weak var delegate: AKKeyboardDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        let x: CGFloat = CGFloat(guitarNotesArray.count) / CGFloat(maxNumberOfStrings)
        let widthMultiplier = exp(0.5*x-0.5)
        
        bridgeImageView.autoMatch(.width, to: .width, of: self.view, withMultiplier: widthMultiplier)
        bottomView.autoMatch(.height, to: .height, of: self.view, withMultiplier: widthMultiplier*widthMultiplier*0.06)
        
        let sortedFreq = guitarNotesArray.sorted(by: { $0.frequency < $1.frequency })
        let maxFreq: Float = sortedFreq.last?.frequency ?? 0
        
        for (index, guitarNote) in guitarNotesArray.enumerated() {
            
            let frequency = guitarNote.frequency
            let fact = self.view.bounds.size.width / 2000.0
            let stringWidth: CGFloat = CGFloat(Float(fact) * maxFreq / sqrt(2*frequency))
 
            let containerView = UIView()
            containerView.backgroundColor = .clear
            
            let stringView = UIImageView()
            stringView.image = UIImage(named: "string")
            containerView.addSubview(stringView)
            
            let button = NoteButton()
            button.setBackgroundImage(UIImage(named: "noteButtonPassive"), for: .normal)
            button.tag = index
            button.note = guitarNote
            button.addTarget(self, action:#selector(self.buttonTouched), for: .touchUpInside)
            buttonCollection.append(button)
            containerView.addSubview(button)
            
            stringView.autoCenterInSuperview()
            stringView.autoPinEdge(toSuperviewEdge: .top)
            stringView.autoPinEdge(toSuperviewEdge: .bottom)
            stringView.autoSetDimension(.width, toSize: stringWidth)
            
            button.autoPinEdge(toSuperviewEdge: .bottom, withInset: -4)
            button.autoAlignAxis(toSuperviewMarginAxis: .vertical)
            button.autoMatch(.width, to: .width, of: containerView, withMultiplier: widthMultiplier*0.8)
            button.autoMatch(.height, to: .width, of: button)
            
            let noteName = guitarNote.noteName
            let noteLabel = UILabel()
            noteLabel.text = noteName
            let fontSize = min(self.view.bounds.size.width / 30, 26.0)
            noteLabel.font = UIFont.boldSystemFont(ofSize: fontSize)
            button.addSubview(noteLabel)
            
            noteLabel.autoCenterInSuperview()
            
            
            stackView.addArrangedSubview(containerView)
        }
    }
    
    @objc func buttonTouched(_ sender: Any) {
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
