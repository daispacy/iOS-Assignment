//
//  UIView+Extensions.swift
//  iOS Assignment
//
//  Created by Dai on 15/09/2020.
//  Copyright © 2020 Dai. All rights reserved.
//

import UIKit

let tagLoading:Int = 100001
let tagContentLoading:Int = 100002
let tagMsgLoading:Int = 100003
let tagStackLoading:Int = 100004

extension UIView {
    
    enum Position:Int {
        case top
        case center
        case bottom
    }
    
    func makeCorner(radius:CGFloat, maskToBound:Bool = false) {
        layer.cornerRadius = radius
        layer.masksToBounds = maskToBound
    }
    
    func startLoading(_ backgroundColor:UIColor = UIColor.black.withAlphaComponent(0.7),
                      _ type:UIActivityIndicatorView.Style = .white,
                      _ isDisableUserInteractive:Bool = false,
                      _ position:Position = .center,
                      msg:String? = nil) {
        guard let lContent = self.viewWithTag(tagContentLoading),
            let stack = lContent.viewWithTag(tagStackLoading) as? UIStackView else {
                let lContent = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
                lContent.tag = tagContentLoading
                addSubview(lContent)
                lContent.translatesAutoresizingMaskIntoConstraints = false
                if isDisableUserInteractive {
                    lContent.makeCorner(radius: 0)
                    if position == .center {
                        lContent.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
                        lContent.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
                        self.bottomAnchor.constraint(equalTo: lContent.bottomAnchor).isActive = true
                        self.trailingAnchor.constraint(equalTo: lContent.trailingAnchor).isActive = true
                    } else if position == .top {
                        lContent.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
                        lContent.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
                        self.trailingAnchor.constraint(equalTo: lContent.trailingAnchor).isActive = true
                    } else if position == .bottom {
                        lContent.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
                        self.bottomAnchor.constraint(equalTo: lContent.bottomAnchor).isActive = true
                        self.trailingAnchor.constraint(equalTo: lContent.trailingAnchor).isActive = true
                    }
                } else {
                    lContent.makeCorner(radius: 10)
                    lContent.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
                    if position == .center {
                        lContent.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -50).isActive = true
                    } else if position == .top {
                        lContent.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
                    } else if position == .bottom {
                        self.bottomAnchor.constraint(equalTo: lContent.bottomAnchor).isActive = true
                    }
                }
                
                lContent.backgroundColor = backgroundColor
                
                var stack = lContent.viewWithTag(tagStackLoading) as? UIStackView
                if stack == nil {
                    stack = UIStackView(frame: .zero)
                    stack?.tag = tagStackLoading
                    stack?.alignment = .center
                    stack?.axis = .vertical
                    stack?.spacing = 5
                    lContent.addSubview(stack!)
                    stack?.translatesAutoresizingMaskIntoConstraints = false
                    let top = stack!.topAnchor.constraint(equalTo: lContent.topAnchor,constant: 10)
                    top.priority = UILayoutPriority(rawValue: 999)
                    lContent.addConstraint(top)
                    
                    let leading = stack!.leadingAnchor.constraint(equalTo: lContent.leadingAnchor,constant: 10)
                    leading.priority = UILayoutPriority(rawValue: 999)
                    lContent.addConstraint(leading)
                    
                    let trailing = lContent.trailingAnchor.constraint(equalTo: stack!.trailingAnchor,constant: 10)
                    trailing.priority = UILayoutPriority(rawValue: 999)
                    lContent.addConstraint(trailing)
                    
                    let bottom = lContent.bottomAnchor.constraint(equalTo: stack!.bottomAnchor,constant: 10)
                    bottom.priority = UILayoutPriority(rawValue: 999)
                    lContent.addConstraint(bottom)
                }
                
                var msgLabel = stack?.viewWithTag(tagMsgLoading) as? UILabel
                if msgLabel == nil {
                    msgLabel = UILabel(frame: .zero)
                    msgLabel?.tag = tagMsgLoading
                    msgLabel?.font = UIFont.systemFont(ofSize: 14)
                    msgLabel?.textColor = backgroundColor != UIColor.clear ? UIColor.white : .black
                    stack?.addArrangedSubview(msgLabel!)
                    msgLabel?.text = msg
                    msgLabel?.isHidden = msg == nil
                }
                
                var indicator = stack?.viewWithTag(tagLoading) as? UIActivityIndicatorView
                if indicator == nil {
                    indicator = UIActivityIndicatorView(style: .white)
                    indicator?.tag = tagLoading
                    if #available(iOS 12.0, *) {
                        indicator = UIActivityIndicatorView(style: self.traitCollection.userInterfaceStyle == .dark ? .white : .white)
                        indicator?.color = self.traitCollection.userInterfaceStyle == .dark ? .white : .white
                    } else {
                        indicator?.color = .white
                    }
                    
                    stack?.insertArrangedSubview(indicator!, at: 0)
                    indicator?.startAnimating()
                }
                return
        }
        
        (stack.viewWithTag(tagMsgLoading) as? UILabel)?.text = msg
        (stack.viewWithTag(tagMsgLoading) as? UILabel)?.isHidden = msg == nil
        (stack.viewWithTag(tagLoading) as? UIActivityIndicatorView)?.startAnimating()
     }
    
    func stopLoading() {
        _ = self.subviews.map({
            if $0.tag == tagContentLoading {
                $0.removeFromSuperview()
            }
        })
    }
}
