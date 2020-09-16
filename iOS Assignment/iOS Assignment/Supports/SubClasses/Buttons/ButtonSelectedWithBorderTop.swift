//
//  ButtonBorderTop.swift
//  iOS Assignment
//
//  Created by Dai on 15/09/2020.
//  Copyright © 2020 Dai. All rights reserved.
//

import UIKit

class ButtonSelectedWithBorderTop: UIButton {

    @IBInspectable var lineColor: UIColor = .greenBorder {
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var lineWidth: CGFloat = 2 {
        didSet {
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // remove line
        layer.sublayers?.forEach({($0 as? CAShapeLayer)?.removeFromSuperlayer()})
        
        let startingPoint   = CGPoint(x: bounds.minX, y: bounds.minY)
        let endingPoint     = CGPoint(x: bounds.maxX, y: bounds.minY)
        
        // add line to top button
        let path = UIBezierPath()
        path.move(to: startingPoint)
        path.addLine(to: endingPoint)
        let subLayer = CAShapeLayer()
        subLayer.path = path.cgPath
        subLayer.frame = bounds
        
        // only show when at state selected
        subLayer.strokeColor = isSelected ? lineColor.cgColor : UIColor.clear.cgColor
        subLayer.lineWidth = isSelected ? lineWidth : 0
        
        layer.addSublayer(subLayer)
    }
}
