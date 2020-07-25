//
//  ActivityModel.swift
//  Productivity Analytics Implementation
//
//  Created by KUAN-YU CHEN on 2020/7/5.
//  Copyright © 2020 KUAN-YU CHEN. All rights reserved.
//

import Foundation

class ActivityModel {
    var applicationName:String
    var mouseClickNum:Int32
    var keyDownNum:Int32
    var startTime:Date
    var endTime:Date
    var usageTime:TimeInterval
    
    init() {
        self.applicationName = ""
        self.mouseClickNum = 0
        self.keyDownNum = 0
        self.startTime = Date()
        self.endTime = Date()
        self.usageTime = 0;
    }
}
