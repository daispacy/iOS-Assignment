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
                title = ""
            case .favourite:
                title = "Favorite Users"
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
            loadFavoriteUsers()
        }
    }
    
    /// setup controller
    private func config() {
        
        // set background
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
        
        if state == .favourite {return} // prevent load again
        
        loadFavoriteUsers()
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
                    _self.loadFavoriteUsers()
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
    
    private func loadFavoriteUsers() {
        
        state = .favourite
        
        // reset UI
        reset()
        
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
    }
    
    /// save user to local
    /// - Parameter user: User
    private func addUserToFavorite(user:User) {
        UserDO.save(user: user, nil)
    }
}

// MARK: -  handle UI
private extension UsersController {
    
    /// remove all stickers and effect
    private func reset() {
        
        usersResponse = nil
        users.removeAll()
        
        vwCoverStickers.subviews.forEach({$0.removeFromSuperview()})
    }
    
    /// setup list user stickers with data
    private func setUpStickers(isInsertNew:Bool = false) {
        
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
        
        self.view.showMessage(msg: max > 0 ? nil : "There is no user.")
        
        // add User stick
        if max == 0 { // nothing to show
            return
        }
        
        if isInsertNew {
            if vwCoverStickers.subviews.count < max {
                let stickerView = UserStickerView(frame: .zero)
                vwCoverStickers.insertSubview(stickerView, at: 0)
                stickerView.translatesAutoresizingMaskIntoConstraints = false
                stickerView.leadingAnchor.constraint(equalTo: vwCoverStickers.leadingAnchor, constant: 10).isActive = true
                vwCoverStickers.trailingAnchor.constraint(equalTo: stickerView.trailingAnchor,constant: 10).isActive = true
            }
        } else {
            for _ in (0..<max) {
                let stickerView = UserStickerView(frame: .zero)
                vwCoverStickers.insertSubview(stickerView, at: 0)
                stickerView.translatesAutoresizingMaskIntoConstraints = false
                stickerView.leadingAnchor.constraint(equalTo: vwCoverStickers.leadingAnchor, constant: 10).isActive = true
                vwCoverStickers.trailingAnchor.constraint(equalTo: stickerView.trailingAnchor,constant: 10).isActive = true
            }
        }
        
        vwCoverStickers.subviews.enumerated().forEach { (e) in
            vwCoverStickers.constraints.first(where: { (constraint) -> Bool in
                return constraint.identifier == "topCover\(e.offset)"
            })?.isActive = false
            let top = e.element.topAnchor.constraint(equalTo: vwCoverStickers.topAnchor, constant: (CGFloat(vwCoverStickers.subviews.count - 1) - CGFloat(e.offset)) * spacingStickers)
            top.identifier = "topCover\(e.offset)"
            vwCoverStickers.addConstraint(top)
        }
        
        vwCoverStickers.constraints.first(where: { (constraint) -> Bool in
            return constraint.identifier == "bottomCover"
        })?.isActive = false
        if let view = vwCoverStickers.subviews.last {
            let bottom = vwCoverStickers.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: CGFloat(vwCoverStickers.subviews.count) * spacingStickers)
            bottom.identifier = "bottomCover"
            vwCoverStickers.addConstraint(bottom)
        }
        
        // set scale and user for sticker
        vwCoverStickers.subviews.reversed().enumerated().forEach { (e) in
            e.element.transform = CGAffineTransform.identity.scaledBy(x: self.scales[e.offset], y: 1)
            e.element.alpha = self.alphas[e.offset]
            if e.offset < 2 {
                (e.element as? UserStickerView)?.show(user: users[e.offset])
            }
        }
        
        // add pangesture for last subview
        if let lasted = vwCoverStickers.subviews.last {
            let pan = UIPanGestureRecognizer(target: self, action: #selector(swipe(_:)))
            lasted.addGestureRecognizer(pan)
        }
        
        UIView.animate(withDuration: 0.2) {
            self.vwCoverStickers.layoutIfNeeded()
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
            if vwCoverStickers.subviews.count >= maximumCard {
                vwCoverStickers.subviews.first?.alpha = percent
            }
            
            // set scale again for subviews except last subviews
            vwCoverStickers.subviews.reversed().suffix(vwCoverStickers.subviews.count - 1).enumerated().forEach { (e) in
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
                        addUserToFavorite(user: user)
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
                    view.frame.origin = CGPoint(x: destinationX*2, y: self.originalStickerPoint.y + (self.spacingStickers))
                }) { (bool) in
                    // remove
                    view.removeGestureRecognizer(gesture)
                    view.removeFromSuperview()
                    self.users.removeFirst()
                    
                    self.setUpStickers(isInsertNew: true)
                }
                
            } else { // cancel process
                
                // reset 
                UIView.animate(withDuration: 0.3) {
                    view.frame.origin = self.originalStickerPoint
                    
                    self.vwCoverStickers.subviews.reversed().enumerated().forEach { (e) in
                        e.element.transform = CGAffineTransform.identity.scaledBy(x: self.scales[e.offset], y: 1)
                        e.element.alpha = self.alphas[e.offset]
                    }
                }
            }
        }
    }
}
