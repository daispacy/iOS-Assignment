//
//  RoundImageView.swift
//  iOS Assignment
//
//  Created by Dai on 15/09/2020.
//  Copyright © 2020 Dai. All rights reserved.
//

import UIKit


/// Round image view
class RoundImageView: UIImageView {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = frame.size.height/2
        layer.masksToBounds = true
    }
}
