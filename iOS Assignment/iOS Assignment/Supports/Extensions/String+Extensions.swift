//
//  String+Extensions.swift
//  iOS Assignment
//
//  Created by Dai on 16/09/2020.
//  Copyright © 2020 Dai. All rights reserved.
//

import UIKit

extension String {
    func UTCToLocal(format:String = "yyyy-MM-dd'T'HH:mm:ss.SSS") -> String {
        
        let key = self + format
        if let cached = ManagerCache.getDateFormatted(key: key) {
            return cached
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let dt = dateFormatter.date(from: self)
        
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = format
        dateFormatter1.timeZone = TimeZone.current
        
        if let d = dt {
            let t = dateFormatter1.string(from: d)
            ManagerCache.cacheDateFormatted(dateFormmated: t, key: key)
            return t
        }
        
        return ""
    }
}
