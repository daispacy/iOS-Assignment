//
//  FillHeaderView.swift
//  iOS Assignment
//
//  Created by Dai on 16/09/2020.
//  Copyright © 2020 Dai. All rights reserved.
//

import UIKit

class FillHeaderView:UIView {
    
    var subDistance:CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // remove line
        layer.sublayers?.forEach({($0 as? CAShapeLayer)?.removeFromSuperlayer()})
        
        if subDistance == 0 {return}
        
        let startingPoint   = CGPoint(x: bounds.minX, y: (bounds.maxY - subDistance)*0.18)
        let secondPoint   = CGPoint(x: bounds.minX, y: bounds.minY - subDistance)
        let threePoint   = CGPoint(x: bounds.maxX, y: bounds.minY - subDistance)
        let endingPoint     = CGPoint(x: bounds.maxX, y: (bounds.maxY - subDistance)*0.18)
        
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
