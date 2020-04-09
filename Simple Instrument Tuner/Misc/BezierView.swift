//
//  BezierView.swift
//  Bezier
//
//  Created by Ramsundar Shandilya on 10/14/15.
//  Copyright © 2015 Y Media Labs. All rights reserved.
//

import UIKit
import Foundation

protocol BezierViewDataSource: class {
    func bezierViewDataPoints(bezierView: BezierView) -> [CGPoint]
}

class BezierView: UIView {
   

    //MARK: Public members
    weak var dataSource: BezierViewDataSource?
    
    var lineColor = #colorLiteral(red: 0, green: 0.9808154702, blue: 0.3959429264, alpha: 1)
    
    var animates = false
    
    var pointLayers = [CAShapeLayer]()
    var lineLayer = CAShapeLayer()
    
    //MARK: Private members
    
    private var dataPoints: [CGPoint]? {
		return self.dataSource?.bezierViewDataPoints(bezierView: self)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.sublayers?.forEach({ (layer: CALayer) -> () in
            layer.removeFromSuperlayer()
        })
        pointLayers.removeAll()
        
        drawSmoothLines()
    }
    
    
    private func drawSmoothLines() {
        
        guard let points = dataPoints else {
            return
        }
        
        
        let linePath = UIBezierPath()
        
        var prevPoint: CGPoint?
        var isFirst = true

        for point in points {
            if let prevPoint = prevPoint {
                let midPoint = CGPoint(
                    x: (point.x + prevPoint.x) / 2,
                    y: (point.y + prevPoint.y) / 2
                )
                if isFirst {
                    linePath.addLine(to: midPoint)
                }
                else {
                    linePath.addQuadCurve(to: midPoint, controlPoint: prevPoint)
                }
                isFirst = false
            }
            else {
                linePath.move(to: point)
            }
            prevPoint = point
        }
        if let prevPoint = prevPoint {
            linePath.addLine(to: prevPoint)
        }
		
        lineLayer = CAShapeLayer()
		lineLayer.path = linePath.cgPath
		lineLayer.fillColor = UIColor.clear.cgColor
		lineLayer.strokeColor = lineColor.cgColor
        lineLayer.lineWidth = 2.0
        
		lineLayer.shadowColor = UIColor.black.cgColor
        lineLayer.shadowOffset = CGSize(width: 0, height: 8)
        lineLayer.shadowOpacity = 0.5
        lineLayer.shadowRadius = 6.0
        
        self.layer.addSublayer(lineLayer)
        
        if animates {
            lineLayer.strokeEnd = 0
        }
    }
}
