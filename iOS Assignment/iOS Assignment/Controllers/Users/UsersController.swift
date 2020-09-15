//
//  UsersController.swift
//  iOS Assignment
//
//  Created by Dai on 15/09/2020.
//  Copyright © 2020 Dai. All rights reserved.
//

import UIKit

class UsersController: UIViewController {

    // MARK: -  outlet
    @IBOutlet weak var stackStickers: UIStackView!
    
    // MARK: -  properties
    var originalStickerPoint:CGPoint = .zero // original position animation view
    var spacingStickers:CGFloat = 5 // space for each sticker
    var scales:[CGFloat] = [1.0,0.95,0.9,0.85] // scale per sticker
    var page:Int = 1
    var pageSize:Int = 7
    var shouldLoadMore:Bool = true // check should load more pages
    
    var users:[User] = [] // list users
    var usersResponse:UsersResponse? // response from api
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // check internet connection
        if NetworkManager.sharedInstance.isConnected {
            // load users from api
            loadUsers(isRefresh: true)
        } else {
            // load users from local
            loadFavouriteUsers()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        stackStickers.spacing = -(stackStickers.arrangedSubviews.last?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height ?? 0) + spacingStickers
    }
    
    
    /// get users from server
    /// - Parameter isRefresh: false if go on load more pages
    func loadUsers(isRefresh:Bool = false) {
        
        if isRefresh { // reset page, UI
            self.view.startLoading()
            
            page = 1
            usersResponse = nil
            users.removeAll()
            stackStickers.arrangedSubviews.forEach({$0.removeFromSuperview()})
        }
        
        Request.getUsers(page: page,
                         pageSize: pageSize,
                         seed: usersResponse?.info?.seed)
        {[weak self] (response, error) in
            guard let _self = self else {return}
            DispatchQueue.main.async {
                
                _self.view.stopLoading()
                
                guard let res = response else {
                    // show error & load data local
                    _self.shouldLoadMore = false
                    _self.loadFavouriteUsers()
                    return
                }
                if _self.usersResponse == nil { // store user response to get seed load more pages
                    _self.usersResponse = response
                }
                
                // mark should load more
                _self.shouldLoadMore = response?.results?.count ?? 0 >= _self.pageSize
                
                if let users = res.results {
                    _self.appendNewUsers(users: users)
                }
            }
        }
    }
    
    func loadFavouriteUsers() {
        self.view.startLoading()
        UserDO.getFavouriteUsers {[weak self] (users) in
            guard let _self = self else {return}
            DispatchQueue.main.async {
                _self.view.stopLoading()
                _self.appendNewUsers(users: users)
            }
        }
    }
    
    /// append new users to local users
    /// - Parameter users: list new users
    func appendNewUsers(users:[User]) {
        self.users.append(contentsOf: users)
        if page == 1 { // setup stickers in first request or reset
            setUpStickers()
        }
    }
    
    /// save user to local
    /// - Parameter user: User
    func addUserToFavourite(user:User) {
        UserDO.save(user: user, nil)
    }
}

// MARK: -  handle UI
private extension UsersController {
    /// setup list user stickers with data
    private func setUpStickers() {
        
        // check should load more users from server
        if shouldLoadMore && users.count < 6 {
            page += 1
            loadUsers()
        }
        
        // set max stickers display
        var max = 0
        if users.count >= 4 {
            max = 4
        } else {
            max = users.count
        }

        // add User stick
        if max == 0 {return} // nothing to show
        
        for tag in (1...max) {
            if stackStickers.viewWithTag(tag) == nil { // if a sticker is removed it should added again
                let stickerView = UserStickerView(frame: .zero)
                stickerView.tag = tag
                stackStickers.addArrangedSubview(stickerView)
            }
        }
        
        // if subviews > 4, first subview should be hidden
        if max >= 4 {
            stackStickers.arrangedSubviews.first?.alpha = 0
        }
        
        // set scale and user for sticker
        stackStickers.arrangedSubviews.reversed().enumerated().forEach { (e) in
            e.element.transform = CGAffineTransform.identity.scaledBy(x: self.scales[e.offset], y: 1)
            (e.element as? UserStickerView)?.show(user: users[e.offset])
        }
        
        // add pangesture for last subview
        if let lasted = stackStickers.arrangedSubviews.last {
            let pan = UIPanGestureRecognizer(target: self, action: #selector(swipe(_:)))
            lasted.addGestureRecognizer(pan)
        }
        
        // reset transform
        self.stackStickers.transform = .identity
    }
    
    /// handle swipe left or right for user sticker view
    /// - Parameter gesture: pan gesture
    @objc func swipe(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else {return}
        let translate = gesture.translation(in: view)
        let ratio = translate.x / (view.frame.width)
        let shouldAddFavourite = ratio > 0
        let percent = abs(ratio)
        
        if gesture.state == .began {
            originalStickerPoint = view.frame.origin
        } else if gesture.state == .changed {
            // move user sticker
            view.frame.origin = CGPoint(x: translate.x, y: originalStickerPoint.y + (spacingStickers * percent))
            
            // change alpha first subview
            if stackStickers.arrangedSubviews.count > 3 {
                stackStickers.arrangedSubviews.first?.alpha = percent
            }
            
            // move stack y = last subview
            stackStickers.transform = CGAffineTransform.identity.translatedBy(x: 0, y: -(spacingStickers * percent))
            
            // set scale again for subviews except last subviews
            stackStickers.arrangedSubviews.reversed().suffix(stackStickers.arrangedSubviews.count - 1).enumerated().forEach { (e) in
                UIView.animate(withDuration: 0.1) {
                    e.element.transform = CGAffineTransform.identity.scaledBy(x: self.scales[e.offset], y: 1)
                }
            }
            
        } else if gesture.state == .ended || gesture.state == .cancelled {
            let velocity = gesture.velocity(in: gesture.view)
            
            if percent > 0.7 || velocity.y > 1000 { // complete process

                if shouldAddFavourite {
                    // save to local
                    if let user = (view as? UserStickerView)?.getUser() {
                        addUserToFavourite(user: user)
                    }
                }
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.stackStickers.transform = CGAffineTransform.identity.translatedBy(x: 0, y: -(self.spacingStickers))
                    view.frame.origin = CGPoint(x: view.frame.width, y: self.originalStickerPoint.y + (self.spacingStickers))
                }) { (bool) in
                    // remove
                    view.removeGestureRecognizer(gesture)
                    view.removeFromSuperview()
                    self.users.removeFirst()
                    
                    self.setUpStickers()
                }
                
            } else { // cancel process
                
                // reset 
                UIView.animate(withDuration: 0.3) {
                    self.stackStickers.arrangedSubviews.first?.alpha = 0
                    view.frame.origin = self.originalStickerPoint
                    self.stackStickers.transform = .identity
                    
                    // set scale
                    self.stackStickers.arrangedSubviews.reversed().enumerated().forEach { (e) in
                        e.element.transform = CGAffineTransform.identity.scaledBy(x: self.scales[e.offset], y: 1)
                    }
                }
            }
        }
    }
}
