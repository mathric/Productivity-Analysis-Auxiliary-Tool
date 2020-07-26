//
//  Timer.swift
//  Productivity Analytics Implementation
//
//  Created by KUAN-YU CHEN on 2020/7/17.
//  Copyright © 2020 KUAN-YU CHEN. All rights reserved.
//

import Foundation

class CustomTimer {
    var timer: Timer
    var applicationNameToIndexDict:[String: Int]
    
    init() {
        self.timer = Timer()
        self.applicationNameToIndexDict = [:]
    }
    
    func setTimer(activityList:[ActivityModel], detectCore: DetectCore) {
        if activityList.count > 0 {
            for i in (0...activityList.count - 1) {
                applicationNameToIndexDict[activityList[i].applicationName] = i
            }
        }
        let activityDataDict:[String: Any] = ["activity": activityList, "detect": detectCore]
        self.timer = Timer.scheduledTimer(timeInterval: AppConstant.UPDATE_TIMEUSAGE_INTERVAL, target: self, selector: #selector(self.updateActivityData), userInfo: activityDataDict, repeats: true)
    }
    
    func stopTimer() {
        timer.invalidate()
    }
    
    @objc func updateActivityData() {
        if let userInfo = timer.userInfo as? [String: Any] {
            if let detectCore = (userInfo["detect"] as? DetectCore) {
                //find application row index
                if let index = applicationNameToIndexDict[detectCore.applicationName] {
                    let indexSetDict = ["index":IndexSet(integer:index)]
                    
                    //update activity time
                    if let activityList = userInfo["activity"] as? [ActivityModel] {
                        activityList[index].usageTime += AppConstant.UPDATE_TIMEUSAGE_INTERVAL
                    }
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateRowData"), object: nil, userInfo: indexSetDict)
                }
                else {
                    let index = applicationNameToIndexDict.count
                    let indexSetDict = ["index": IndexSet(integer: index)]
                    var newActivity = ActivityModel()
                    newActivity.applicationName = detectCore.applicationName
                    newActivity.usageTime = AppConstant.UPDATE_TIMEUSAGE_INTERVAL
                    let activityDict = ["newElement":newActivity]
                    
                    //update index dict
                    applicationNameToIndexDict[newActivity.applicationName] = index
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AddNewElementToActivityList"), object: nil, userInfo: activityDict)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateRowData"), object: nil, userInfo: indexSetDict)
                }
            }
        }
    }
    
}
