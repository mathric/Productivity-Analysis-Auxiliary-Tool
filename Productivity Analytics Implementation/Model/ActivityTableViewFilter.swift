//
//  ActivityTableViewFilter.swift
//  Productivity Analytics Implementation
//
//  Created by KUAN-YU CHEN on 2020/7/5.
//  Copyright © 2020 KUAN-YU CHEN. All rights reserved.
//

import Foundation

class ActivityTableViewFilter {
    
    static func sortByTimeUsage(list:[CoreDataActivity]) -> [ActivityModel] {
        var dict = [String:ActivityModel]()
        var sortedList:[ActivityModel] = []
        for data in list {
            if let name = data.applicationName {
                if (dict.keys.contains(name)) {
                    dict[name]?.usageTime += CustomDate.dateDiff(start: data.startTime!, end: data.endTime!)
                }
                else {
                    let element:ActivityModel = ActivityModel()
                    element.applicationName = name
                    element.usageTime = CustomDate.dateDiff(start: data.startTime!, end: data.endTime!)
                    dict[name] = element
                }
            }
        }
        for (_, value) in dict {
            sortedList.append(value)
        }
        sortedList.sort{ (a, b) -> Bool in
            return (a.usageTime > b.usageTime)
        }
        return sortedList
    }
}
