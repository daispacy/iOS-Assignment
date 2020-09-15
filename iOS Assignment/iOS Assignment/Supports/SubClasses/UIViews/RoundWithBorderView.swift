//
//  RoundView.swift
//  iOS Assignment
//
//  Created by Dai on 15/09/2020.
//  Copyright © 2020 Dai. All rights reserved.
//

import UIKit


/// Round View with border color
class RoundWithBorderView: RoundView {

    @IBInspectable var color:UIColor = UIColor.groupTableViewBackground {
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var borderWidth:CGFloat = 1 {
        didSet {
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = frame.size.height/2
        layer.masksToBounds = true
        
        layer.borderColor = color.cgColor
        layer.borderWidth = borderWidth
    }

}
