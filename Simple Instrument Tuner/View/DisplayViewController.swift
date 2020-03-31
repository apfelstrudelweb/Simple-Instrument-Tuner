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

class DisplayViewController: UIViewController {

    @IBOutlet weak var bezierView: BezierView!
    
    let binCount = 50
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bezierView.dataSource = self
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
        
        func plotAmplitude(trackedAmplitude: AKAmplitudeTracker) {
            
            let plot = AKNodeOutputPlot(trackedAmplitude, frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
            plot.shouldFill = true
            plot.shouldMirror = true
            plot.shouldCenterYAxis = true
            plot.color = #colorLiteral(red: 0, green: 0.9808154702, blue: 0.3959429264, alpha: 1)
            plot.backgroundColor = #colorLiteral(red: 0.2431372549, green: 0.2431372549, blue: 0.262745098, alpha: 0)
            plot.gain = 2.0
            self.view.addSubview(plot)
            plot.inputView?.autoPinEdgesToSuperviewEdges()
        }
        
    func plotFFT(fftTap: AKFFTTap, amplitudeTracker: AKAmplitudeTracker) {
        
            let _ = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (timer) in

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
                for y in yArray {
                    self.dataPoints.append(255.0*(1.0-15*amplitudeTracker.amplitude*y/max))
                }
                
                self.bezierView.layoutSubviews()
            })
        }
    }


    extension DisplayViewController: BezierViewDataSource {
        
        func bezierViewDataPoints(bezierView: BezierView) -> [CGPoint] {
            
            return graphPoints
        }
    }
