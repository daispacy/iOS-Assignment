//
//  BaseView.swift
//  iOS Assignment
//
//  Created by Dai on 15/09/2020.
//  Copyright © 2020 Dai. All rights reserved.
//

import UIKit


class BaseView: UIView {

    // MARK: - outlet
    @IBOutlet weak var view: UIView!
    
    func config() {

    }
    
    // MARK: -  private
    private func loadNIb() {
        Bundle.main.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNIb()
        config()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNIb()
        config()
    }
    
    init() {
        super.init(frame: CGRect.zero)
        loadNIb()
        config()
    }
    
}

