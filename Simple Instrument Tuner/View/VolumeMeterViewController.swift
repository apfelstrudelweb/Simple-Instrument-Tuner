//
//  VolumeMeterViewController.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 23.03.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit
import CoreImage
import PureLayout

class VolumeMeterViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var meterView: UIView!
    
    let maskView = UIView()
    let redLine = UIView()
    
    let colors = [UIColor.blue, UIColor.green, UIColor.yellow, UIColor.red]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundView.backgroundColor = UIColor.init(patternImage: UIImage(named: "volumeMeterPattern")!)
        
        backgroundView.layer.borderColor = UIColor.black.withAlphaComponent(0.85).cgColor
        backgroundView.layer.shadowColor = UIColor.lightGray.cgColor
        backgroundView.layer.shadowOpacity = 1
        
        meterView.showGradientColors(colors)
        maskView.removeFromSuperview()
        maskView.backgroundColor = .white
        meterView.addSubview(maskView)
        meterView.mask = maskView
        
        // red vertical line
        redLine.removeFromSuperview()
        redLine.backgroundColor = UIColor.red
        meterView.addSubview(redLine)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        backgroundView.layer.cornerRadius = 0.5*backgroundView.frame.size.height
        meterView.layer.cornerRadius = backgroundView.layer.cornerRadius
        
        backgroundView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        backgroundView.layer.shadowOffset = CGSize(width: 0, height: 3)
        backgroundView.layer.shadowOpacity = 1.0
        backgroundView.layer.shadowRadius = 5.0
        backgroundView.layer.masksToBounds = false

        displayVolume(volume: 0.1)
    }
    
    func displayVolume(volume: Double) {
        
        let w = Double(view.frame.size.width)
        let h = Double(self.meterView.bounds.size.height)
 
        UIView.animate(withDuration: 0.2) {
            self.maskView.frame = CGRect(x: 0.0, y: 0.0, width: 3 * volume * w, height: h)
            self.redLine.frame = self.maskView.bounds.offsetBy(dx: self.maskView.bounds.size.width-2, dy: 0)
        }
        
    }
    
}

extension UIView {

    enum GradientColorDirection {
        case vertical
        case horizontal
    }

    func showGradientColors(_ colors: [UIColor], opacity: Float = 0.8, direction: GradientColorDirection = .horizontal) {
    
        let gradientLayer = CAGradientLayer()
        gradientLayer.opacity = opacity
        gradientLayer.colors = colors.map { $0.cgColor }

        if case .horizontal = direction {
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        }
        
        gradientLayer.locations = [0.0, 0.2, 0.3, 0.4]

        gradientLayer.bounds = self.bounds  //CGRect(x: 0, y: 0, width: 100, height: 20)//self.bounds
        gradientLayer.anchorPoint = CGPoint.zero
        gradientLayer.cornerRadius = self.layer.cornerRadius
        self.layer.addSublayer(gradientLayer)
    }

}
