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
import SwiftGifOrigin

/// Delegate for keyboard events
protocol AKKeyboardDelegate: class {
    /// Note on evenets
    func noteOn(note: Note)
    /// Note off events
    func noteOff(note: Note)
    
    func stopAllNotes()
}

class BridgeViewController: UIViewController, AKMIDIListener {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var bridgeImageView: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    
    
    open weak var keyboardDelegate: AKKeyboardDelegate?
    
    
    var buttonCollection = [NoteButton]()
    var stringCollection = [StringView]()
    
    var activeSoundTag = -1
    open weak var delegate: AKKeyboardDelegate?
    
    var widthConstraint: NSLayoutConstraint?
    var heightConstraint: NSLayoutConstraint?
    var widthMultiplier: CGFloat!
    
    
    var numberOfLoops = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let instrument = Utils().getInstrument()
        if instrument == nil {
            return
        }
        
        self.view.layoutIfNeeded()
        
        loadElements()
    }
    
    func animateString(frequency: Float, flag: Bool) {

        if flag == true {
            
//            stringCollection.forEach {
//                
//                if $0.frequency == frequency {
//                    $0.image = UIImage.gif(name: "string")
//                } else {
//                    $0.image = UIImage(named: "string")
//                }
//            }
            
            buttonCollection.forEach {
                if $0.note.frequency == frequency {
                    $0.isActive = true
                } else {
                    $0.isActive = false
                }
            }
        } else {
            
            stringCollection.forEach {
                $0.image = UIImage(named: "string")
            }
            buttonCollection.forEach {
                $0.isActive = false
            }
        }
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        let frequencies = Utils().getCurrentFrequencies()
        let x: CGFloat = CGFloat(frequencies.count) / CGFloat(maxNumberOfStrings)
        widthMultiplier = exp(0.5*x-0.5)
        
        widthConstraint?.autoRemove()
        heightConstraint?.autoRemove()
        
        heightConstraint = bottomView.autoMatch(.height, to: .height, of: self.view, withMultiplier: widthMultiplier*widthMultiplier*0.06)
        widthConstraint = bridgeImageView.autoMatch(.width, to: .width, of: self.view, withMultiplier: widthMultiplier)
    }
    
    func loadElements() {
        
        stringCollection = [StringView]()
        buttonCollection = [NoteButton]()
        
        self.view.setNeedsUpdateConstraints()
        
        for subview in stackView.arrangedSubviews {
            subview.removeFromSuperview()
        }
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        let frequencies = Utils().getCurrentFrequencies()
        let instrument = Utils().getInstrument()
        let sortedFreq = frequencies.sorted(by: { $0 < $1 })
        let maxFreq: Float = Float(sortedFreq.last!)
        
        let notes: [Note] = Utils().getCurrentNoteObjects()!
        
        for (index, note) in notes.enumerated() {
            
            let frequency = note.frequency
            let fact = UIDevice.current.userInterfaceIdiom == .pad ?  self.view.bounds.size.width / 3500.0 : self.view.bounds.size.width / 2000.0
            var div = sqrt(frequency)
            if div == 0 { div = 80 }
            let stringWidth: CGFloat = CGFloat(Float(fact) * maxFreq / div)
            
            let containerView = UIView()
            containerView.backgroundColor = .clear
            
            let stringView = StringView()
            stringView.image = instrument?.doubleStrings == true ? UIImage(named: "doubleString") : UIImage(named: "string")
            stringView.frequency = note.frequency
            containerView.addSubview(stringView)
 
            let button = NoteButton()
            button.setBackgroundImage(UIImage(named: "noteButtonPassive"), for: .normal)
            button.tag = index
            button.note = note
            button.addTarget(self, action:#selector(self.buttonTouched), for: .touchUpInside)
            buttonCollection.append(button)
            containerView.addSubview(button)
            
            // because disabled buttons are semi-transparent
            let buttonLayerView = UIImageView()
            buttonLayerView.image = UIImage(named: "noteButtonPassive")
            containerView.insertSubview(buttonLayerView, belowSubview: button)
            
            stringView.autoCenterInSuperview()
            stringView.autoPinEdge(toSuperviewEdge: .top)
            stringView.autoPinEdge(toSuperviewEdge: .bottom)
            stringView.autoSetDimension(.width, toSize: stringWidth)
            
            stringCollection.append(stringView)
            
            button.autoPinEdge(toSuperviewEdge: .bottom, withInset: -4)
            button.autoAlignAxis(toSuperviewMarginAxis: .vertical)
            button.autoMatch(.width, to: .width, of: containerView, withMultiplier: widthMultiplier*0.8)
            button.autoMatch(.height, to: .width, of: button)
            
            buttonLayerView.autoPinEdge(.top, to: .top, of: button)
            buttonLayerView.autoPinEdge(.bottom, to: .bottom, of: button)
            buttonLayerView.autoPinEdge(.left, to: .left, of: button)
            buttonLayerView.autoPinEdge(.right, to: .right, of: button)
            
            let noteLabel = NoteLabel()
            noteLabel.localizedText = note.noteName
            button.addSubview(noteLabel)
            
            noteLabel.autoCenterInSuperview()
            
            stackView.addArrangedSubview(containerView)
            
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            
            let minFontSize: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 24.0 : 12.0
            var fontSize = max(noteLabel.bounds.size.width / 1.5, minFontSize)
            if noteLabel.localizedText?.count ?? 3 > 2 {
                fontSize = fontSize/1.5
            }
            noteLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
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
            delegate?.noteOn(note: noteButton.note)
        } else {
            delegate?.noteOff(note: noteButton.note)
        }
    }
}
