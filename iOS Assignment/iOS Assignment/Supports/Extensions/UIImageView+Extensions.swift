//
//  UIImageView+Extensions.swift
//  iOS Assignment
//
//  Created by Dai on 16/09/2020.
//  Copyright © 2020 Dai. All rights reserved.
//

import UIKit
import MapKit

// MARK: - IMAGEVIEW
private var KeepTap:String = "KeepTap"
private var KeepTapEvent:String = "KeepTapEvent"
private var BLURMASK:String = "BLURMASK"
private var imageViewCover = "imageViewCover"
private var SESSION_TASK_DOWNLOAD_IMAGEVIEW = "SESSION_TASK_DOWNLOAD_IMAGEVIEW"
private var CURRENT_OBJECT = "CURRENT_OBJECT_DOWNLOAD_IMAGEVIEW"
extension UIImageView:URLSessionDelegate, URLSessionDownloadDelegate {
    
    // MARK: -  session delegate
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if let data = try? Data(contentsOf: location), let downloadedImage = UIImage(data: data) {
            imageUrlIgnores.setObject("true", forKey: (downloadTask.response?.url?.absoluteString ?? "") as NSString)
            ManagerCache.cacheImage(image: downloadedImage, key: downloadTask.response?.url?.absoluteString)
            DispatchQueue.main.async {
                if self.accessibilityIdentifier == downloadTask.response?.url?.absoluteString {
                    self.image = downloadedImage
                }
            }
            
            do {
                try FileManager.default.removeItem(at: location)
                #if DEBUG
                print("\(#function) remove \(location) success ")
                #endif
            } catch let err {
                #if DEBUG
                print("\(#function) \(err.localizedDescription) ")
                #endif
            }
        }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        #if DEBUG
        print("\(#function) \(totalBytesWritten) \(totalBytesExpectedToWrite) ")
        #endif
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        #if DEBUG
        print("\(#function) \(String(describing: error?.localizedDescription)) ")
        #endif
        if let resposne = task.response as? HTTPURLResponse {
            if resposne.statusCode == 415 || resposne.statusCode == 304 {
                imageUrlIgnores.setObject("true", forKey: (resposne.url?.absoluteString ?? "") as NSString)
            }
        }
        
        if let e = error as NSError? {
            if e.code == NSURLErrorCancelled {
                if ManagerCache.getImage(key: ((e.userInfo["NSErrorFailingURLStringKey"] as? String) ?? "")) != nil {
                    imageUrlIgnores.setObject("true", forKey: ((e.userInfo["NSErrorFailingURLStringKey"] as? String) ?? "") as NSString)
                }
            }
        }
    }
    
    // MARK: -  function extension
    func cancelAllTaskDownloadImage() {
        guard let session = objc_getAssociatedObject(self, &SESSION_TASK_DOWNLOAD_IMAGEVIEW) as? URLSession else {return}
        session.getAllTasks(completionHandler: { (tasks) in
            if tasks.count > 0 {
                _ = tasks.filter({$0.currentRequest?.url?.absoluteString.contains(self.accessibilityIdentifier ?? "-1") == true}).map{
                    #if DEBUG
                    print("\(#function) \(String(describing: self.accessibilityIdentifier)) ")
                    #endif
                    $0.cancel()
                }
            }
        })
    }
    
    func loadImageUsingCacheWithURLString(_ URLString: String?, placeHolder: UIImage? = #imageLiteral(resourceName: "ic_placeholder_256"),_ object:Any? = nil, allowRefreshCached:Bool = false,_ onComplete:((UIImage?,Any?)->Void)? = nil){
        
        //        cancelAllTaskDownloadImage()
        
        guard let URLString = URLString else {return}
        
        accessibilityIdentifier = URLString
        
        let key = URLString
        
        let cachedImage = ManagerCache.getImage(key: key)
        
        if cachedImage != nil {
            self.image = cachedImage
        } else {
            if let cachedOrigin = ManagerCache.getImage(key: URLString) {
                self.image = cachedOrigin
            } else {
                if placeHolder == nil {
                    self.startLoading()
                } else {
                    self.image = placeHolder
                }
            }
        }
        
        if !allowRefreshCached {
            if imageUrlIgnores.object(forKey: URLString as NSString) != nil {
                self.stopLoading()
                onComplete?(self.image,object)
                return
            }
        }
        
        if let url = URL(string: URLString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)) {
            self.accessibilityIdentifier = url.absoluteString
            
            let config = URLSessionConfiguration.default
            config.requestCachePolicy = .useProtocolCachePolicy
            //            let session = URLSession(configuration: config, delegate: nil, delegateQueue: nil)
            let session = URLSession(configuration: config)
            objc_setAssociatedObject(self, &SESSION_TASK_DOWNLOAD_IMAGEVIEW, session, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            let request = URLRequest(url: url)
            let task = session.dataTask(with: request, completionHandler: {[weak self] (data, response, error) in
                
                guard let _self = self else {
                    return
                }
                
                if let resposne = response as? HTTPURLResponse {
                    if resposne.statusCode == 415 || resposne.statusCode == 304 {
                        imageUrlIgnores.setObject("true", forKey: (resposne.url?.absoluteString ?? "") as NSString)
                        DispatchQueue.main.async {
                            _self.stopLoading()
                            onComplete?(_self.image,object)
                        }
                        return
                    }
                }
                
                objc_setAssociatedObject(_self, &SESSION_TASK_DOWNLOAD_IMAGEVIEW, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                
                if let e = error as NSError? {
                    if e.code == NSURLErrorCancelled {
                        if ManagerCache.getImage(key: ((e.userInfo["NSErrorFailingURLStringKey"] as? String) ?? "")) != nil {
                            imageUrlIgnores.setObject("true", forKey: ((e.userInfo["NSErrorFailingURLStringKey"] as? String) ?? "") as NSString)
                        }
                        DispatchQueue.main.async {
                            _self.stopLoading()
                            onComplete?(_self.image,object)
                        }
                        return
                    }
                }
                
                //print("RESPONSE FROM API: \(response)")
                if error != nil {
                    imageUrlIgnores.setObject("true", forKey: (response?.url?.absoluteString ?? "") as NSString)
                    DispatchQueue.main.async {
                        _self.stopLoading()
                    }
                    return
                }
                if let data = data {
                    if let downloadedImage = UIImage(data: data) {
                        imageUrlIgnores.setObject("true", forKey: (response?.url?.absoluteString ?? "") as NSString)
                        ManagerCache.cacheImage(image: downloadedImage, key: response?.url?.absoluteString)
                        DispatchQueue.main.async {
                            _self.image = downloadedImage
                            onComplete?(_self.image,object)
                        }
                    }
                }
                DispatchQueue.main.async {
                    _self.stopLoading()
                }
                
            })
            task.accessibilityLabel = url.absoluteString
            task.resume()
            
        } else {
            self.stopLoading()
            onComplete?(self.image,object)
        }
    }
    
    func mapSnapshotter(coordinate:CLLocationCoordinate2D,
                        _ complete:((UIImage?)->Void)?) {
        
        let coords = coordinate
        let distanceInMeters: Double = 100
        
        let options = MKMapSnapshotter.Options()
        options.region = MKCoordinateRegion.init(center: coords, latitudinalMeters: distanceInMeters, longitudinalMeters: distanceInMeters)
        options.size = self.frame.size
        
        /// 4.
        let bgQueue = DispatchQueue.global(qos: .default)
        let snapShotter = MKMapSnapshotter(options: options)
        
        
        snapShotter.start(with: bgQueue, completionHandler: {[weak self](snapshot, error) in
            guard error == nil else {
                DispatchQueue.main.async {
                    complete?(self?.image)
                }
                return
            }
            
            if let snapShotImage = snapshot?.image, let coordinatePoint = snapshot?.point(for: coords) {
                UIGraphicsBeginImageContextWithOptions(snapShotImage.size, true, snapShotImage.scale)
                snapShotImage.draw(at: CGPoint.zero)
                
                let pinImage =  #imageLiteral(resourceName: "ic_pin_64")//.resizeImageWith(newSize: CGSize(width: 20, height: 20))
                
                // need to fix the point position to match the anchor point of pin which is in middle bottom of the frame
                let fixedPinPoint = CGPoint(x: coordinatePoint.x - pinImage.size.width / 2, y: coordinatePoint.y - pinImage.size.height/2)
                pinImage.draw(at: fixedPinPoint)
                let mapImage = UIGraphicsGetImageFromCurrentImageContext()
                
                DispatchQueue.main.async {
                    if let mapImage = mapImage {
                        self?.image = mapImage
                    }
                    complete?(self?.image)
                }
                UIGraphicsEndImageContext()
            }
        })
    }
}
