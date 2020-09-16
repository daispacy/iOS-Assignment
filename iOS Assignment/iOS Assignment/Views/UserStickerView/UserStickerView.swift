//
//  UserStickerView.swift
//  iOS Assignment
//
//  Created by Dai on 15/09/2020.
//  Copyright © 2020 Dai. All rights reserved.
//

import UIKit
import CoreLocation

// MARK: -  api
extension UserStickerView {
    func show(user:User) {
        self.user = user
        showData()
    }
    
    func getUser() -> User? {
        return self.user
    }
}

// MARK: -  internal
class UserStickerView: BaseView {

    // MARK: -  outlet
    @IBOutlet weak var btnProfile: ButtonSelectedWithBorderTop!
    @IBOutlet weak var btnAddress: ButtonSelectedWithBorderTop!
    @IBOutlet weak var btnDob: ButtonSelectedWithBorderTop!
    @IBOutlet weak var btnPhone: ButtonSelectedWithBorderTop!
    @IBOutlet weak var btnAccount: ButtonSelectedWithBorderTop!
    @IBOutlet var buttonMenus: [ButtonSelectedWithBorderTop]!
    
    
    @IBOutlet weak var scrollViewContent: UIScrollView!
    @IBOutlet weak var stackContainer: UIStackView!
    
    // profile
    @IBOutlet weak var avatarImageView: RoundImageView!
    @IBOutlet weak var vwCoverAvatar: RoundWithBorderView!
    @IBOutlet weak var lblSubName: UILabel!
    @IBOutlet weak var lblName: UILabel!
    
    // dob
    @IBOutlet weak var lblDob: UILabel!
    @IBOutlet weak var lblAge: UILabel!
    
    // address
    @IBOutlet weak var lblSubAddress: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    
    // phone
    @IBOutlet weak var lblCell: UILabel!
    @IBOutlet weak var lblPhone: UILabel!
    
    // account
    @IBOutlet weak var lblSubUsername: UILabel!
    @IBOutlet weak var lblUsername: UILabel!
    
    // common
    let sizeIconButton: CGSize = CGSize(width: 25, height: 25)
    
    // MARK: - properties
    private var user:User? {
        didSet {
            if user?.isMale == true {
                btnProfile.setImage(#imageLiteral(resourceName: "ic_male_128").resizeImageWith(newSize: sizeIconButton).tint(with: .smokeGray), for: .normal)
                btnProfile.setImage(#imageLiteral(resourceName: "ic_male_128").resizeImageWith(newSize: sizeIconButton).tint(with: .greenBorder), for: .selected)
            } else {
                btnProfile.setImage(#imageLiteral(resourceName: "ic_female_128").resizeImageWith(newSize: sizeIconButton).tint(with: .smokeGray), for: .normal)
                btnProfile.setImage(#imageLiteral(resourceName: "ic_female_128").resizeImageWith(newSize: sizeIconButton).tint(with: .greenBorder), for: .selected)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // remove line
        layer.sublayers?.forEach({($0 as? CAShapeLayer)?.removeFromSuperlayer()})
        
        let startingPoint   = CGPoint(x: bounds.minX, y: bounds.maxY*0.25)
        let secondPoint   = CGPoint(x: bounds.minX, y: bounds.minY)
        let threePoint   = CGPoint(x: bounds.maxX, y: bounds.minY)
        let endingPoint     = CGPoint(x: bounds.maxX, y: bounds.maxY*0.25)
        
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
        subLayer.fillColor = UIColor.clear.cgColor
        
        layer.addSublayer(subLayer)
    }
    
    override func config() {
        
        // bring avartar to front
        stackContainer.bringSubviewToFront(vwCoverAvatar.superview!)
     
        // set default tab
        selectMenu(btnProfile)
        
        // setup buttons
        btnProfile.tag = 0
        btnDob.tag = 1
        btnAddress.tag = 2
        btnPhone.tag = 3
        btnAccount.tag = 4

        btnProfile.setImage(#imageLiteral(resourceName: "ic_male_128").resizeImageWith(newSize: sizeIconButton).tint(with: .smokeGray), for: .normal)
        btnProfile.setImage(#imageLiteral(resourceName: "ic_male_128").resizeImageWith(newSize: sizeIconButton).tint(with: .greenBorder), for: .selected)
        
        btnDob.setImage(#imageLiteral(resourceName: "ic_calendar_128").resizeImageWith(newSize: sizeIconButton).tint(with: .smokeGray), for: .normal)
        btnDob.setImage(#imageLiteral(resourceName: "ic_calendar_128").resizeImageWith(newSize: sizeIconButton).tint(with: .greenBorder), for: .selected)
        
        btnAddress.setImage(#imageLiteral(resourceName: "ic_location_128").resizeImageWith(newSize: sizeIconButton).tint(with: .smokeGray), for: .normal)
        btnAddress.setImage(#imageLiteral(resourceName: "ic_location_128").resizeImageWith(newSize: sizeIconButton).tint(with: .greenBorder), for: .selected)
        
        btnPhone.setImage(#imageLiteral(resourceName: "ic_phone_128").resizeImageWith(newSize: sizeIconButton).tint(with: .smokeGray), for: .normal)
        btnPhone.setImage(#imageLiteral(resourceName: "ic_phone_128").resizeImageWith(newSize: sizeIconButton).tint(with: .greenBorder), for: .selected)
        
        btnAccount.setImage(#imageLiteral(resourceName: "ic_private_128").resizeImageWith(newSize: sizeIconButton).tint(with: .smokeGray), for: .normal)
        btnAccount.setImage(#imageLiteral(resourceName: "ic_private_128").resizeImageWith(newSize: sizeIconButton).tint(with: .greenBorder), for: .selected)
        
        lblSubName.font = UIFont.systemFont(ofSize: 18)
        lblSubName.textColor = .smokeGray
        lblSubName.text = "My name is"
        
        lblName.font = UIFont.boldSystemFont(ofSize: 20)
        lblName.textColor = .blackSecond
        
        lblSubAddress.font = UIFont.systemFont(ofSize: 18)
        lblSubAddress.textColor = .smokeGray
        lblSubAddress.text = "My address is"
        
        lblAddress.font = UIFont.boldSystemFont(ofSize: 20)
        lblAddress.textColor = .blackSecond
        
        lblSubUsername.font = UIFont.systemFont(ofSize: 18)
        lblSubUsername.textColor = .smokeGray
        lblSubUsername.text = "My username is"
        
        lblUsername.font = UIFont.boldSystemFont(ofSize: 20)
        lblUsername.textColor = .blackSecond
    }
    
    @IBAction func selectMenu(_ sender: UIButton) {
        if sender.isSelected {return}
        
        buttonMenus.forEach({$0.isSelected = false})
        sender.isSelected = true
        
        // scroll
        scrollViewContent.scrollRectToVisible(CGRect(x: scrollViewContent.frame.width*CGFloat(sender.tag),
                                                     y: scrollViewContent.frame.origin.y,
                                                     width: scrollViewContent.frame.width,
                                                     height: scrollViewContent.frame.height), animated: false)
    }
    
    deinit {
        user = nil
        #if DEBUG
        print("\(#function)")
        #endif
    }
}

// MARK: -  handle data
private extension UserStickerView {
    func showData() {
        guard let user = self.user else {return}
        
        // avatar
        avatarImageView.loadImageUsingCacheWithURLString(user.picture?.large)
        
        // name
        lblName.text = user.getFullName()
        
        // dob
        let mutableAge = NSMutableAttributedString(string: "Age: ",
                                                   attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18),
                                                                NSAttributedString.Key.foregroundColor: UIColor.smokeGray])
        let age = user.dob?.age
        mutableAge.append(NSAttributedString(string: age == nil ? "" : "\(age!)",
                                             attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20),
                                                          NSAttributedString.Key.foregroundColor: UIColor.blackSecond]))
        lblAge.attributedText = mutableAge
        
        let mutableDob = NSMutableAttributedString(string: "DOB: ",
                                                   attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18),
                                                                NSAttributedString.Key.foregroundColor: UIColor.smokeGray])
        mutableDob.append(NSAttributedString(string: user.dob?.date?.UTCToLocal(format: "MM/dd/yyyy") ?? "",
                                             attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20),
                                                          NSAttributedString.Key.foregroundColor: UIColor.blackSecond]))
        lblDob.attributedText = mutableDob
        
        // address
        lblAddress.text = user.getFullAddress()
        
        // phone
        let mutableCell = NSMutableAttributedString(string: "Cell: ",
                                                   attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18),
                                                                NSAttributedString.Key.foregroundColor: UIColor.smokeGray])
        mutableCell.append(NSAttributedString(string: user.cell ?? "",
                                             attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20),
                                                          NSAttributedString.Key.foregroundColor: UIColor.blackSecond]))
        lblCell.attributedText = mutableCell
        
        let mutablePhone = NSMutableAttributedString(string: "Phone: ",
                                                   attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18),
                                                                NSAttributedString.Key.foregroundColor: UIColor.smokeGray])
        mutablePhone.append(NSAttributedString(string: user.phone ?? "",
                                             attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20),
                                                          NSAttributedString.Key.foregroundColor: UIColor.blackSecond]))
        lblPhone.attributedText = mutablePhone
        
        //username
        lblUsername.text = user.login?.username
    }
}
