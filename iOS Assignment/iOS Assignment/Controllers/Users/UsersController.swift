//
//  UsersController.swift
//  iOS Assignment
//
//  Created by Dai on 15/09/2020.
//  Copyright © 2020 Dai. All rights reserved.
//

import UIKit

class UsersController: UIViewController {
    
    /// load users from where
    enum UsersControllerState {
        case api
        case favourite
    }
    
    
    // MARK: -  outlet
    @IBOutlet weak var vwCoverStickers: FillHeaderView!
    @IBOutlet weak var stackStickers: UIStackView!
    
    // MARK: -  properties
    var originalStickerPoint:CGPoint = .zero // original position animation view
    let spacingStickers:CGFloat = 5 // space for each sticker
    let scales:[CGFloat] = [1.0,0.95,0.9,0.85] // scale per sticker
    let alphas:[CGFloat] = [1.0,0.95,0.9,0.0] // alpha per sticker
    let maximumCard:Int = 4 // maximum card to display
    var standardSpacing:CGFloat = 0
    
    var page:Int = 1
    let pageSize:Int = 7
    var shouldLoadMore:Bool = true // check should load more pages
    
    var users:[User] = [] // list users
    var usersResponse:UsersResponse? // response from api
    
    var state:UsersControllerState = .api {
        didSet {
            switch state {
            case .api:
                title = "Users"
            case .favourite:
                title = "Favourite Users"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        config()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // check internet connection
        if NetworkManager.sharedInstance.isConnected {
            // load users from api
            loadUsers(isRefresh: true)
        } else {
            // load users from local
            loadFavouriteUsers()
        }
    }
    
    /// setup controller
    private func config() {
        
        // set background
        title = "Users"
        view.backgroundColor = .smokeGray
        navigationController?.view.backgroundColor = .smokeGray
        
        // set action for uiibarbuttonitems
        let leftBarItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_refresh_128").withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(actionLeftBarButton(_:)))
        let rightBarItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_heart_128").withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(actionRightBarButton(_:)))
        navigationItem.setLeftBarButton(leftBarItem, animated: false)
        navigationItem.setRightBarButton(rightBarItem, animated: false)
    }
    
    // action
    @objc func actionLeftBarButton(_ sender:Any) {
        loadUsers(isRefresh: true)
    }
    
    @objc func actionRightBarButton(_ sender:Any) {
        
        if state == .favourite {return} // prevent load from local
        
        reset()
        loadFavouriteUsers()
    }
    /// get users from server
    /// - Parameter isRefresh: false if go on load more pages
    private func loadUsers(isRefresh:Bool = false) {
        
        state = .api
        
        if isRefresh { // reset page, UI
            self.view.startLoading()
            
            page = 1
            reset()
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
    
    private func loadFavouriteUsers() {
        
        state = .favourite
        
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
    private func appendNewUsers(users:[User]) {
        self.users.append(contentsOf: users)
        if page == 1 { // setup stickers in first request or reset
            setUpStickers()
        }
        
        self.view.showMessage(msg: self.users.count > 0 ? nil : "There is no user.")
    }
    
    /// save user to local
    /// - Parameter user: User
    private func addUserToFavourite(user:User) {
        UserDO.save(user: user, nil)
    }
}

// MARK: -  handle UI
private extension UsersController {
    
    /// remove all stickers and effect
    private func reset() {
        
        usersResponse = nil
        users.removeAll()
        
        stackStickers.arrangedSubviews.forEach({$0.removeFromSuperview()})
        vwCoverStickers.subDistance = 0
    }
    
    /// setup list user stickers with data
    private func setUpStickers() {
        
        // check should load more users from server
        if shouldLoadMore && users.count < 6 && state == .api {
            page += 1
            loadUsers()
        }
        
        // set max stickers display
        var max = 0
        if users.count >= maximumCard {
            max = maximumCard
        } else {
            max = users.count
        }
        
        // add User stick
        if max == 0 {return} // nothing to show
        
        for tag in (1...max) {
            if stackStickers.viewWithTag(tag + 1000) == nil { // if a sticker is removed it should added again
                let stickerView = UserStickerView(frame: .zero)
                stickerView.tag = tag + 1000
                stackStickers.addArrangedSubview(stickerView)
            }
        }
        
        // if subviews > 4, first subview should be hidden
        if max >= maximumCard {
            stackStickers.arrangedSubviews.first?.alpha = 0
        }
        
        // set scale and user for sticker
        stackStickers.arrangedSubviews.reversed().enumerated().forEach { (e) in
            e.element.transform = CGAffineTransform.identity.scaledBy(x: self.scales[e.offset], y: 1)
            e.element.alpha = self.alphas[e.offset]
            if e.offset < 3 {
                (e.element as? UserStickerView)?.show(user: users[e.offset])
            }
        }
        
        // add pangesture for last subview
        if let lasted = stackStickers.arrangedSubviews.last {
            let pan = UIPanGestureRecognizer(target: self, action: #selector(swipe(_:)))
            lasted.addGestureRecognizer(pan)
        }
        
        vwCoverStickers.subDistance = CGFloat(stackStickers.arrangedSubviews.filter({$0.alpha != 0}).count * 10) // 10 is constant leading beetwen stack vs cover
        
        if standardSpacing == 0 {
            standardSpacing = -(self.stackStickers.arrangedSubviews.first?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height ?? 0) - spacingStickers*2
            stackStickers.spacing = standardSpacing
        }
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
            if stackStickers.arrangedSubviews.count >= maximumCard {
                stackStickers.arrangedSubviews.first?.alpha = percent
            }
            
            // move stack y = last subview
            //            stackStickers.transform = CGAffineTransform.identity.translatedBy(x: 0, y: -(spacingStickers * percent))
            
            // set scale again for subviews except last subviews
            stackStickers.arrangedSubviews.reversed().suffix(stackStickers.arrangedSubviews.count - 1).enumerated().forEach { (e) in
                UIView.animate(withDuration: 0.1) {
                    e.element.transform = CGAffineTransform.identity.scaledBy(x: self.scales[e.offset], y: 1)
                    e.element.alpha = self.alphas[e.offset]
                }
            }
            
        } else if gesture.state == .ended || gesture.state == .cancelled {
            let velocity = gesture.velocity(in: gesture.view)
            
            if percent > 0.7 || velocity.y > 1000 { // complete process
                
                if shouldAddFavourite {
                    // save to local with user get from api
                    if let user = (view as? UserStickerView)?.getUser(),
                       state == .api {
                        addUserToFavourite(user: user)
                    }
                } else {
                    
                    // remove local user with favourite user
                    if state == .favourite,
                       let user = (view as? UserStickerView)?.getUser() {
                        UserDO.clearData(email: user.email, nil)
                    }
                }
                
                let destinationX = shouldAddFavourite ? view.frame.width : -view.frame.width
                UIView.animate(withDuration: 0.2, animations: {
                    //                    self.stackStickers.transform = CGAffineTransform.identity.translatedBy(x: 0, y: -(self.spacingStickers))
                    view.frame.origin = CGPoint(x: destinationX*2, y: self.originalStickerPoint.y + (self.spacingStickers))
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
                    view.frame.origin = self.originalStickerPoint
                    
                    self.stackStickers.arrangedSubviews.first?.alpha = 0
                    
                    self.stackStickers.arrangedSubviews.reversed().enumerated().forEach { (e) in
                        e.element.transform = CGAffineTransform.identity.scaledBy(x: self.scales[e.offset], y: 1)
                        e.element.alpha = self.alphas[e.offset]
                    }
                }
            }
        }
    }
}
