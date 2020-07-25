//
//  DateTransformer.swift
//  Productivity Analytics Implementation
//
//  Created by KUAN-YU CHEN on 2020/7/5.
//  Copyright © 2020 KUAN-YU CHEN. All rights reserved.
//

import Foundation

class CustomDate {
    static let df:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        formatter.timeZone = NSTimeZone.local
        return formatter
    }()
    
    static let dcf:DateComponentsFormatter = {
        let dcFormatter = DateComponentsFormatter()
        dcFormatter.allowedUnits = [.day, .hour, .minute, .second]
        dcFormatter.unitsStyle = .brief
        dcFormatter.maximumUnitCount = 4
        return dcFormatter
    }()
    
    static func dateDiff(start:Date, end:Date) -> TimeInterval {
        return (end.timeIntervalSinceReferenceDate - start.timeIntervalSinceReferenceDate)
    }
    
    static func buildMonthDayString(target: Date) -> String {
        let calendar = Calendar.current
        return String(calendar.component(.month, from: target)) + ":" + String(calendar.component(.day, from: target))
    }
}
