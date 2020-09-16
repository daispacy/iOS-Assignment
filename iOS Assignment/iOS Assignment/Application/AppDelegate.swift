//
//  AppDelegate.swift
//  iOS Assignment
//
//  Created by Dai on 15/09/2020.
//  Copyright © 2020 Dai. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // prepare network
        _ = NetworkManager.sharedInstance
        
        // init window
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // setup navigation bar
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().barTintColor = nil
        UINavigationBar.appearance().setBackgroundImage(UIColor.smokeGray.imageRepresentation, for: UIBarMetrics.default)
        
        let usersController = UsersController()
        let navigationController = UINavigationController(rootViewController:usersController)
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        return true
    }
}

