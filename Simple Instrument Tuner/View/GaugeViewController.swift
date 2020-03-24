//
//  GaugeViewController.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 21.03.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit
import PureLayout


class GaugeViewController: UIViewController {

    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var upperShadowView: UIView!
    @IBOutlet weak var overlayView: UIImageView!
    @IBOutlet weak var scrollContentView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    
    let notesArray: [String] = String(Locale.preferredLanguages[0].prefix(2)) == "de" ? ["C", "C♯", "D", "E♭", "E", "F", "F♯", "G", "A♭", "A", "H♭", "H"] : ["C", "C♯", "D", "E♭", "E", "F", "F♯", "G", "A♭", "A", "B♭", "B"]
    let freqArray: [Float] = [16.35, 17.32, 18.35, 19.45, 20.60, 21.83, 23.12, 24.50, 25.96, 27.50, 29.14, 30.87]
    
    var smoothArray = [Float]()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundView.backgroundColor = UIColor.init(patternImage: UIImage(named: "gaugePattern")!)

        backgroundView.layer.borderColor = UIColor.black.withAlphaComponent(0.85).cgColor
        overlayView.layer.borderColor = backgroundView.layer.borderColor
        backgroundView.layer.shadowColor = UIColor.lightGray.cgColor
        backgroundView.layer.shadowOpacity = 1
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        backgroundView.layer.cornerRadius = 0.5*backgroundView.frame.size.height
        upperShadowView.layer.cornerRadius = backgroundView.layer.cornerRadius
        overlayView.layer.cornerRadius = backgroundView.layer.cornerRadius
        
        backgroundView.layer.borderWidth = 0.13*backgroundView.frame.size.height
        overlayView.layer.borderWidth = backgroundView.layer.borderWidth
        
        let shadowSize = 0.01*backgroundView.frame.size.height
        backgroundView.layer.shadowOffset = CGSize(width: shadowSize, height: shadowSize)
        backgroundView.layer.shadowRadius = shadowSize
        
        populateGauge()
    }
    
    private func populateGauge() {
        
        // avoid multiple overlays when app reappears from background
        for subview in stackView.arrangedSubviews {
            subview.removeFromSuperview()
        }
        
        let h = 0.45*self.view.frame.size.height
        
        for _ in 0...2 {
            for note in notesArray {
                
                let scaleView = UIImageView(image: UIImage(named: "gaugeScale"))
                
                let noteLabel = UILabel()
                noteLabel.textAlignment = .center
                noteLabel.font = UIFont.systemFont(ofSize: 0.6*h)
                noteLabel.text = "\(note)"
                
                let noteView = UIView()
                noteView.addSubview(scaleView)
                noteView.addSubview(noteLabel)
                //noteView.autoSetDimension(.width, toSize: 70.0)
                
                scaleView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: h, right: 0))
                noteLabel.autoPinEdge(.bottom, to: .bottom, of: noteView, withOffset: -0.1*h)
                noteLabel.autoMatch(.width, to: .width, of: noteView)

                stackView.addArrangedSubview(noteView)
            }
        }

    }
    
    func displayFrequency(frequency: Float) {
        
        smoothArray.append(frequency)
        
        if smoothArray.count > 10 {
            smoothArray.remove(at: 0)
        } 
        
        var freq = smoothArray.average
        
        while freq > Float(freqArray[freqArray.count - 1]) {
            freq /= 2.0
        }
        while freq < Float(freqArray[0]) {
            freq *= 2.0
        }
        
        // project frequencies 16.35...30.87 to 1...12
        let x = 12 * log2(freq/freqArray.first!)
        
        let segmentWidth = stackView.arrangedSubviews.first?.frame.size.width ?? 66.5
        let xOffset = 15.0 - 0.5 * (view.frame.size.width - 350.0)
        let p = segmentWidth * CGFloat(x + 10.0)  + xOffset

        self.scrollView.setContentOffset(CGPoint(x: p, y: 0), animated: true)
    }
}

extension Collection where Element: Numeric {
    /// Returns the total sum of all elements in the array
    var total: Element { reduce(0, +) }
}

extension Collection where Element: BinaryInteger {
    /// Returns the average of all elements in the array
    var average: Double { isEmpty ? 0 : Double(total) / Double(count) }
}

extension Collection where Element: BinaryFloatingPoint {
    /// Returns the average of all elements in the array
    var average: Element { isEmpty ? 0 : total / Element(count) }
}
