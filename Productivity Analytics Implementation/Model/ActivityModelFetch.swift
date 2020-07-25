//
//  ActivityModelFetch.swift
//  Productivity Analytics Implementation
//
//  Created by KUAN-YU CHEN on 2020/7/5.
//  Copyright © 2020 KUAN-YU CHEN. All rights reserved.
//

import Foundation
import CoreData

class ActivityModelFetch {
    //today's data
    static func today() -> NSPredicate {
        print("current filter: today")
        return NSPredicate(format: "startTime >= %@", Calendar.current.startOfDay(for: Date()) as NSDate)
    }
    
    //last week (include today
    static func lastWeek() -> NSPredicate {
        print("current filter: lastWeek")
        return NSPredicate(format: "startTime >= %@", Calendar.current.date(byAdding: .day, value: -7, to: Date())! as NSDate)
    }
    
    //last month (include today
    static func lastMonth() -> NSPredicate {
         print("current filter: last month")
        return NSPredicate(format: "startTime >= %@", Calendar.current.date(byAdding: .month, value: -1, to: Date())! as NSDate)
    }
    
    static func lastWeekWithoutToday() -> NSPredicate {
        print("current filter: lastWeek")
        return NSPredicate(format: "startTime >= %@ && endTime < %@", Calendar.current.date(byAdding: .day, value: -7, to: Date())! as NSDate, Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())! as NSDate)
    }
    
    static func lastMonthWithoutToday() -> NSPredicate {
        print("current filter: lastWeek")
        return NSPredicate(format: "startTime >= %@ && endTime < %@", Calendar.current.date(byAdding: .month, value: -1, to: Date())! as NSDate, Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())! as NSDate)
    }
}
