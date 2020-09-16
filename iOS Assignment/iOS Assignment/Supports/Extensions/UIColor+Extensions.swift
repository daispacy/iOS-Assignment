//
//  UIColor+Extensions.swift
//  iOS Assignment
//
//  Created by Dai on 16/09/2020.
//  Copyright © 2020 Dai. All rights reserved.
//

import UIKit

extension UIColor {
    
    var imageRepresentation : UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(self.withAlphaComponent(1).cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func forDarkMode(_ color:UIColor?) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { trait in
                return trait.userInterfaceStyle == .dark ? (color ?? self) : self
            }
        } else {
            return self
        }
    }
    
    static var greenBorder:UIColor {
        return #colorLiteral(red: 0.8, green: 0.9058823529, blue: 0.3607843137, alpha: 1).forDarkMode(#colorLiteral(red: 0.8, green: 0.9058823529, blue: 0.3607843137, alpha: 1))
    }
    
    static var smokeGray:UIColor {
        return #colorLiteral(red: 0.8705882353, green: 0.8705882353, blue: 0.8705882353, alpha: 1).forDarkMode(#colorLiteral(red: 0.8705882353, green: 0.8705882353, blue: 0.8705882353, alpha: 1))
    }
    
    static var blackSecond:UIColor {
        return #colorLiteral(red: 0.137254902, green: 0.1215686275, blue: 0.1254901961, alpha: 1).forDarkMode(#colorLiteral(red: 0.7882352941, green: 0.7882352941, blue: 0.7882352941, alpha: 1))
    }
}
