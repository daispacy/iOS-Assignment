//
//  ManagerCache.swift
//  GlobeDr
//
//  Created by dai on 12/8/18.
//  Copyright © 2018 GlobeDr. All rights reserved.
//

import UIKit

fileprivate var imageCache = NSCache<NSString, UIImage>()
var imageUrlIgnores = NSCache<NSString, NSString>()
fileprivate var stringCache = NSCache<NSString, NSString>()
fileprivate var ratioImages = NSCache<NSString, NSNumber>()

class ManagerCache: NSObject {
    
    let config = URLSessionConfiguration.ephemeral
    var session:URLSession?
    var isConsultAlreadyVibrate = false
    var isConnectionAlreadyVibrate = false
    public static let shared: ManagerCache = { return ManagerCache() }()
    
    override init() {
        super.init()
        // Initialise reachability
    }
    
    static func removeCachecDateFormatted() {
        
        #if DEBUG
        print("\(#function)")
        #endif
        
        stringCache.removeAllObjects()
    }
    
    static func removeAllCached() {
        imageCache.removeAllObjects()
        stringCache.removeAllObjects()
        
        // remove cache for wkwebview
        var libraryPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, false).first!
        libraryPath += "/Cookies"
        
        do {
            try FileManager.default.removeItem(atPath: libraryPath)
        } catch {
            #if DEBUG
                print("error")
            #endif
        }
        URLCache.shared.removeAllCachedResponses()
    }
    
    static func removeCached(key:String?) {
        guard let key = key else {return}
        if let _ = imageCache.object(forKey: NSString(string: key)) {
            imageCache.removeObject(forKey: NSString(string: key))
        }
    }
    
    static func cacheDateFormatted(dateFormmated:String, key:String) {
        stringCache.setObject(NSString(string: dateFormmated), forKey: NSString(string: key))
    }
    
    static func cacheImage(image:UIImage, key:String?) {
        guard let key = key else {return}
        ratioImages.setObject(NSNumber(floatLiteral: Double(image.size.width/image.size.height)), forKey: NSString(string: key))
        imageCache.setObject(image, forKey: NSString(string: key))
    }
    
    static func getRatioImage(url:String?) -> CGFloat {
        var keyTemp = url
        if keyTemp?.contains("/wd") == true {
            keyTemp = keyTemp?.components(separatedBy: "/wd").first?.appending("/wd100")
        }
        guard let key = keyTemp, let number = ratioImages.object(forKey: NSString(string: key)) else {
            #if DEBUG
            print("\(#function) \(String(describing: keyTemp))")
            #endif
            return 1
        }
        
        return CGFloat(number.doubleValue)
    }
    
    static func getImage(key:String?) -> UIImage? {
        guard let key = key else {return nil}
        if let a =  imageCache.object(forKey: NSString(string: key)) {
            var keyTemp = key
            if keyTemp.contains("/wd") {
                keyTemp = keyTemp.components(separatedBy: "/wd").first?.appending("/wd100") ?? keyTemp
            }
            ratioImages.setObject(NSNumber(floatLiteral: Double(a.size.width/a.size.height)), forKey: NSString(string: keyTemp))
            return a
        }
        return nil
    }
    
    static func getDateFormatted(key:String?) -> String? {
        guard let key = key else {return nil}
        if let a =  stringCache.object(forKey: NSString(string: key)) as String?{
            return a
        }
        return nil
    }
    
    static func prepareCacheForURLs(_ URLStrings: [String], ignoreCache:Bool = false,_ completion:(()->Void)? = nil){

//        #if DEBUG
//        print("\(#function) \(URLStrings) ")
//        #endif
        
        for URLString in URLStrings {
            if getImage(key: URLString) != nil && !ignoreCache{
                completion?()
                continue
            }
            
            guard let url = URL(string: URLString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)) else {continue}
            
            var request = URLRequest(url: url)
            
            if let url = URL(string: URLString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)) {
                let config = URLSessionConfiguration.default
                config.requestCachePolicy = .useProtocolCachePolicy
                let session = URLSession.init(configuration: config)
                let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
                    session.getAllTasks(completionHandler: { (tasks) in
                        if tasks.count == 0 {
                            session.reset {
                                session.finishTasksAndInvalidate()
                            }
                        }
                    })
                    
                    if let resposne = response as? HTTPURLResponse {
                        if resposne.statusCode == 304 {
                            #if DEBUG
                            print("\(#function) \(resposne.url?.absoluteString ?? "") image not change ")
                            #endif
                            completion?()
                            return
                        } else {
                            #if DEBUG
                            print("\(#function) \(resposne.url?.absoluteString ?? "") image change ")
                            #endif
                        }
                    }
                    
                    if let e = error as NSError? {
                        if e.code == NSURLErrorCancelled {
                            completion?()
                            return
                        }
                    }
                    
                    if error != nil {
                        completion?()
                        return
                    }
                    if let data = data {
                        if let downloadedImage = UIImage(data: data)?.withRenderingMode(.alwaysOriginal) {
                            ManagerCache.cacheImage(image: downloadedImage, key: URLString)
                        }
                    }
                    completion?()
                })
                task.accessibilityLabel = url.absoluteString
                task.resume()
            }
        }
    }
}

