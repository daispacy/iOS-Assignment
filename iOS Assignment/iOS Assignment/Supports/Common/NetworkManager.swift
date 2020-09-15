//
//  NetworkManager.swift
//  GlobeDr
//
//  Created by dai on 11/17/18.
//  Copyright © 2018 GlobeDr. All rights reserved.
//

import Foundation

class NetworkManager: NSObject {
    let reachabilityManager = NetworkReachabilityManager(host: "www.apple.com")
    
    // Create a singleton instance
    static let sharedInstance: NetworkManager = { return NetworkManager() }()
    var onNetworkStatusChanged:((Bool)->Void)?
    
    override init() {
        super.init()
        // Initialise reachability
    }
    
    var isConnected: Bool {
        return reachabilityManager?.isReachable ?? false
    }
    
    func startNetworkReachabilityObserver() {
        reachabilityManager?.listener = {[weak self] status in
            guard let _self = self else {return}
            switch status {
                
            case .notReachable:
                #if DEBUG
                print("The network is not reachable")
                #endif
                _self.onNetworkStatusChanged?(false)
            case .unknown :
                #if DEBUG
                print("It is unknown whether the network is reachable")
                #endif
                _self.onNetworkStatusChanged?(true)
            case .reachable(.ethernetOrWiFi):
                #if DEBUG
                print("The network is reachable over the WiFi connection")
                #endif
                _self.onNetworkStatusChanged?(true)
            case .reachable(.wwan):
                #if DEBUG
                print("The network is reachable over the WWAN connection")
                #endif
                _self.onNetworkStatusChanged?(true)
            }
        }
        reachabilityManager?.startListening()
    }
    
    func startNotifier() -> Void {
        
        startNetworkReachabilityObserver()
    }
    
    func stopNotifier() -> Void {
        reachabilityManager?.stopListening()
    }
}
