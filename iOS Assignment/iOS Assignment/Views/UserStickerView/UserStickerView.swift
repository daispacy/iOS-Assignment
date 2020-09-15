//
//  UserStickerView.swift
//  iOS Assignment
//
//  Created by Dai on 15/09/2020.
//  Copyright © 2020 Dai. All rights reserved.
//

import UIKit


// MARK: -  api
extension UserStickerView {
    func show(user:User) {
        self.user = user
    }
    
    func getUser() -> User? {
        return self.user
    }
}

// MARK: -  internal
class UserStickerView: BaseView {

    // MARK: -  outlet
    @IBOutlet weak var btnProfile: ButtonSelectedWithBorderTop!
    @IBOutlet weak var btnLocation: ButtonSelectedWithBorderTop!
    @IBOutlet weak var btnCalendar: ButtonSelectedWithBorderTop!
    @IBOutlet weak var btnPhone: ButtonSelectedWithBorderTop!
    @IBOutlet weak var btnPrivate: ButtonSelectedWithBorderTop!
    @IBOutlet var buttonMenus: [ButtonSelectedWithBorderTop]!
    
    @IBOutlet weak var lblName: UILabel!
    
    // MARK: - properties
    private var user:User?
    
    override func config() {
        
    }

    @IBAction func selectMenu(_ sender: UIButton) {
        buttonMenus.forEach({$0.isSelected = false})
        sender.isSelected = true
        
        switch sender {
        case btnProfile:
            break
        case btnCalendar:
            break
        case btnLocation:
            break
        case btnPhone:
            break
        case btnPrivate:
            break
        default:break
        }
    }
    
}
