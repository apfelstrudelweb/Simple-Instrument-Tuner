//
//  SnappableSlider.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 11.04.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit
import PureLayout

protocol CalibrationSliderDelegate: AnyObject {

    func didChangeCalibration()
}

@IBDesignable
class CalibrationSlider: UISlider {
    
    var label1: UILabel?
    var label2: UILabel?

    let fontSize: CGFloat = 22.0
    let color440Hz = UIColor(red: 0, green: 0.7373, blue: 0.3451, alpha: 1.0)
    
    weak var calibrationDelegate: CalibrationSliderDelegate?

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let point = CGPoint(x: bounds.minX, y: bounds.midY)
        return CGRect(origin: point, size: CGSize(width: bounds.width, height: 10))
    }

    @IBInspectable
    var interval: Int = 1

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpSlider()
        setValueFromKeychain()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpSlider()
        setValueFromKeychain()
    }

    private func setUpSlider() {
        
        //self.backgroundColor = UIColor(patternImage: UIImage(named: "settingsPatternDark.png")!)
        
        let verticalView = UIView()
        verticalView.backgroundColor = .lightGray
        self.addSubview(verticalView)
        
        verticalView.autoAlignAxis(.vertical, toSameAxisOf: self)
        verticalView.autoAlignAxis(.horizontal, toSameAxisOf: self)
        verticalView.autoSetDimension(.width, toSize: 2)
        verticalView.autoSetDimension(.height, toSize: 60)
        
        label1 = UILabel()
        label1?.textColor = .white
        label1?.font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
        label1?.text = "Calibration"
        self.addSubview(label1!)
        label1?.autoPinEdge(.left, to: .left, of: self)
        label1?.autoMatch(.width, to: .width, of: self, withMultiplier: 0.5)
        label1?.autoMatch(.height, to: .height, of: self)
        label1?.autoPinEdge(.bottom, to: .top, of: self, withOffset: -10.0)
        
        if IAPHandler().isOpenCalibration() == false {
            let shoppingCartImageView = UIImageView(image: UIImage(named: "shoppingCart2"))
            self.addSubview(shoppingCartImageView)
            shoppingCartImageView.autoPinEdge(.right, to: .right, of: self)
            shoppingCartImageView.autoPinEdge(.top, to: .top, of: label1 ?? self)
            shoppingCartImageView.autoMatch(.width, to: .width, of: self, withMultiplier: 0.25)
            let aspectRatioConstraint = NSLayoutConstraint(item: shoppingCartImageView, attribute: .height, relatedBy: .equal, toItem: shoppingCartImageView, attribute: .width, multiplier: 80/184, constant: 0)
            shoppingCartImageView.addConstraint(aspectRatioConstraint)
        } else {
            label2 = UILabel()
            label2?.textColor = .white
            label2?.font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
            label2?.textAlignment = .right
            self.addSubview(label2!)
            label2?.autoPinEdge(.right, to: .right, of: self)
            label2?.autoMatch(.width, to: .width, of: self, withMultiplier: 0.5)
            label2?.autoMatch(.height, to: .height, of: self)
            label2?.autoAlignAxis(.horizontal, toSameAxisOf: label1!)
        }
        

        
        addTarget(self, action: #selector(handleValueChange(sender:)), for: .valueChanged)
    }
    
    private func setValueFromKeychain() {
        if let receivedData = KeyChain.load(key: KEYCHAIN_CURRENT_CALIBRATION) {
            let currentCalibration = receivedData.to(type: Int.self)
            self.value = Float(currentCalibration)
        } else {
            let data = Data(from: Int(440))
            let _ = KeyChain.save(key: KEYCHAIN_CURRENT_CALIBRATION, data: data)
            self.value = Float(440)
        }
        setLabel()
    }

    @objc func handleValueChange(sender: UISlider) {
        let newValue =  (sender.value / Float(interval)).rounded() * Float(interval)
        setValue(Float(newValue), animated: false)

        let data = Data(from: Int(self.value))
        let _ = KeyChain.save(key: KEYCHAIN_CURRENT_CALIBRATION, data: data)
        
        setLabel()
        
        self.calibrationDelegate?.didChangeCalibration()
    }
    
    private func setLabel() {
        label2?.text = "\(Int(self.value)) Hz"
        label2?.textColor = self.value == 440 ? color440Hz : self.tintColor
        label2?.font = self.value == 440 ? UIFont.systemFont(ofSize: fontSize, weight: .medium) : UIFont.systemFont(ofSize: fontSize, weight: .bold)
    }
    
}
