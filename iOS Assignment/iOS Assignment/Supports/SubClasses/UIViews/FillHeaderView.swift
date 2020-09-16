//
//  FillHeaderView.swift
//  iOS Assignment
//
//  Created by Dai on 16/09/2020.
//  Copyright © 2020 Dai. All rights reserved.
//

import UIKit

class FillHeaderView:UIView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // remove line
        layer.sublayers?.forEach({($0 as? CAShapeLayer)?.removeFromSuperlayer()})
        
        if subviews.count == 0 {return}
        
        let startingPoint   = CGPoint(x: bounds.minX, y: (bounds.maxY - 10)*0.18)
        let secondPoint   = CGPoint(x: bounds.minX, y: bounds.minY - 10)
        let threePoint   = CGPoint(x: bounds.maxX, y: bounds.minY - 10)
        let endingPoint     = CGPoint(x: bounds.maxX, y: (bounds.maxY - 10)*0.18)
        
        // add line to top button
        let path = UIBezierPath()
        path.move(to: startingPoint)
        path.addLine(to: secondPoint)
        path.addLine(to: threePoint)
        path.addLine(to: endingPoint)
        let subLayer = CAShapeLayer()
        subLayer.path = path.cgPath
        subLayer.frame = bounds
        
        // only show when at state selected
        subLayer.strokeColor = UIColor.black.cgColor
        subLayer.lineWidth = 1
        subLayer.fillColor = UIColor.black.cgColor
        
        layer.insertSublayer(subLayer, at: 0)
    }
}
