//
//  DisplayViewController.swift
//  Simple Instrument Tuner
//
//  Created by Ullrich Vormbrock on 31.03.20.
//  Copyright © 2020 Ullrich Vormbrock. All rights reserved.
//

import UIKit
import PureLayout
import AudioKit
import AudioKitUI
import GoogleMobileAds

class DisplayViewController: UIViewController {
    
    @IBOutlet weak var bezierView: BezierView!
    
    let binCount = 50
    var timer: Timer?
    
    var mode: DisplayMode?
    
    var nodeOutputPlot: AKNodeOutputPlot = AKNodeOutputPlot()
    var nodeFFTPlot: AKNodeFFTPlot?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bezierView.dataSource = self
        
        self.view.addSubview(nodeOutputPlot)
        nodeOutputPlot.inputView?.autoPinEdgesToSuperviewEdges()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    
    var dataPoints = [Double]()
    
    var xAxisPoints : [Double] {
        var points = [Double]()
        for i in 0..<dataPoints.count {
            let val = (Double(i)/binCount) * Double(self.bezierView.bounds.size.width)
            points.append(val)
        }
        
        return points
    }
    
    var yAxisPoints: [Double] {
        var points = [Double]()
        for i in dataPoints {
            let val = (Double(i)/255) * Double(self.bezierView.bounds.size.height)
            points.append(val)
        }
        
        return points
    }
    
    var graphPoints : [CGPoint] {
        var points = [CGPoint]()
        for i in 0..<dataPoints.count {
            let val = CGPoint(x: self.xAxisPoints[i], y: self.yAxisPoints[i])
            points.append(val)
        }
        
        return points
    }
    
    func plotFFT(fftTap: AKFFTTap, amplitudeTracker: AKAmplitudeTracker) {

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (timer) in
            
            self.dataPoints = [Double]()
            
            var max: Double = 0;
            var yArray = [Double]()
            
            for x in 0...self.binCount {
                let y = fftTap.fftData[x]
                yArray.append(y)
                if y > max {
                    max = y
                }
            }
            if max == 0 { return }
            for y in yArray {
                //self.dataPoints.append(255.0*(1.0-0.5*y/max))
                self.dataPoints.append(255.0*(1.0-15*amplitudeTracker.amplitude*y/max))
            }
            
            self.bezierView.layoutSubviews()
        })
    }
    
    func plotAmplitude(trackedAmplitude: AKAmplitudeTracker) {
        
        nodeOutputPlot.node = trackedAmplitude
        nodeOutputPlot.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        nodeOutputPlot.shouldFill = true
        nodeOutputPlot.shouldMirror = true
        nodeOutputPlot.shouldCenterYAxis = true
        nodeOutputPlot.color = #colorLiteral(red: 0, green: 0.9808154702, blue: 0.3959429264, alpha: 1)
        nodeOutputPlot.backgroundColor = #colorLiteral(red: 0.2431372549, green: 0.2431372549, blue: 0.262745098, alpha: 0)
        nodeOutputPlot.gain = 2.0
    }
    
    func plotFFTFromSound(reverbMixer: AKDryWetMixer) {
        
        nodeFFTPlot?.alpha = 1.0
        if nodeFFTPlot?.isConnected == true { return }
        
        nodeFFTPlot = AKNodeFFTPlot(reverbMixer, frame: CGRect(x: 0, y: 0, width: 10*self.view.bounds.size.width, height: self.view.bounds.size.height))
        nodeFFTPlot?.shouldFill = true
        nodeFFTPlot?.shouldMirror = true
        nodeFFTPlot?.shouldCenterYAxis = true
        nodeFFTPlot?.color = #colorLiteral(red: 0, green: 0.9808154702, blue: 0.3959429264, alpha: 1)
        nodeFFTPlot?.backgroundColor = #colorLiteral(red: 0.2431372549, green: 0.2431372549, blue: 0.262745098, alpha: 0)
        nodeFFTPlot?.gain = 1.0
        
        
        guard let nodeFFTPlot = nodeFFTPlot else { return }
        self.view.addSubview(nodeFFTPlot)
        nodeFFTPlot.inputView?.autoPinEdgesToSuperviewEdges()
    }
    
    
    func clear() {
        
        timer?.invalidate()
        self.dataPoints = [Double]()
        self.bezierView.layoutSubviews()

        nodeFFTPlot?.alpha = 0.0
        nodeOutputPlot.alpha = 0.0
        //nodeFFTPlot?.clear()
    }
    
    func setDisplayMode(mode: DisplayMode) {
        
        if mode == .fft {
            bezierView.alpha = 1.0
            nodeOutputPlot.alpha = 0.0
        } else {
            bezierView.alpha = 0.0
            nodeOutputPlot.alpha = 1.0
        }
    }
}


extension DisplayViewController: BezierViewDataSource {
    
    func bezierViewDataPoints(bezierView: BezierView) -> [CGPoint] {
        
        return graphPoints
    }
}
