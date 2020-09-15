//
//  Request.swift
//  iOS Assignment
//
//  Created by Dai on 15/09/2020.
//  Copyright © 2020 Dai. All rights reserved.
//

import UIKit

// MARK: - Helper functions for creating encoders and decoders
public func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

public func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}


public enum HTTPMethod: String {
    case post = "POST"
    case get = "GET"
    case put = "PUT"
    case delete = "DELETE"
}


public class Request: NSObject {
    
    static let headerPost = ["accept":"application/json",
                             "Content-Type":"application/json-patch+json"]
    
    static let headerGet = ["accept":"application/json"]
    
    public static func request(method:HTTPMethod, url:String, params:[String:Any],_ completion: @escaping (_ data:Any?,_ error:Any?) -> Void) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            
            var headers:[String:String] = [:]
            
            var query = ""
            
            var data:Data?
            
            switch method {
            case .get:
                headers = headerGet
                for (k,v) in params {
                    if query.count == 0 {
                        query.append("?\(k)=\(v)")
                    } else {
                        query.append("&\(k)=\(v)")
                    }
                }
                query = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
            case .delete:
                headers = ["Content-Type":"application/json"]
                data = try? JSONSerialization.data(withJSONObject: params, options: [])
            default:
                headers = ["Content-Type":"application/json"]
                data = try? JSONSerialization.data(withJSONObject: params, options: [])
            }
            
            let urlString = url + query
            
            guard let urlWrapped = URL(string: urlString) else {
                completion(nil,NSError(domain: "request.api", code: -1, userInfo: ["message":"Url is invalid"]) as Error)
                return
            }
            
            #if DEBUG
            if let dt = data {
                print("🟡 ==== REQUEST \(method) url: \(urlString) \(String(describing: try? JSONSerialization.jsonObject(with: dt, options: JSONSerialization.ReadingOptions.allowFragments)))")
            } else {
                print("🟡 ==== REQUEST \(method) url: \(urlString)")
            }
            #endif
            
            let request = NSMutableURLRequest(url: urlWrapped, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 60.0)
            request.httpMethod = method.rawValue
            request.allHTTPHeaderFields = headers
            
            if let dt = data {
                request.httpBody = dt
            }
            
            let session = URLSession.shared
            let dataTask:URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode != 200 {
                        completion(nil,error.debugDescription)
                        return
                    }
                }
                guard let dt = data else {
                    completion(nil,error)
                    return
                }
                completion(dt,error)
            }
            
            dataTask.resume()
        }
    }
}
