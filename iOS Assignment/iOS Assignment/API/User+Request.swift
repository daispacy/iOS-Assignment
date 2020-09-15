//
//  User+Request.swift
//  iOS Assignment
//
//  Created by Dai on 15/09/2020.
//  Copyright © 2020 Dai. All rights reserved.
//

import UIKit

extension Request {
    
    /// get users from server
    /// - Parameters:
    ///   - page: page number
    ///   - complete: return userResponse or error if have
    public static func getUsers(page:Int,
                         pageSize:Int,
                         seed:String?,
                         _ complete:@escaping (_ response:UsersResponse?,_ error:Any?)->Void) {
        
        var params:[String:Any] = ["results" : pageSize,
                                   "page":page]
        if let seed = seed {
            params["seed"] = seed
        }
        
        Request.request(method: .get,
                url: "https://randomuser.me/api/",
                params: params)
        { (data, error) in
            guard let data = data as? Data else {
                complete(nil,error)
                return
            }
            do {
                let userReponse = try UsersResponse.init(data: data)
                complete(userReponse,nil)
            } catch let err {
                complete(nil,err)
            }
        }
    }
}
