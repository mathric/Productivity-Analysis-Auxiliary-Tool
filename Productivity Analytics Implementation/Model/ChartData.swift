//
//  ChartData.swift
//  Productivity Analytics Implementation
//
//  Created by KUAN-YU CHEN on 2020/7/22.
//  Copyright © 2020 KUAN-YU CHEN. All rights reserved.
//

import Foundation
import CoreData

class ChartData {
    static func mouseClickCount(_ coredata: [CoreDataActivity], _ applicationName: String) -> [Double] {
        var output = [Double](repeating: 0, count: 24)
        let calendar = Calendar.current
        var startTime:Int
        var endTime:Int
        var avgClick:Double = 0
        var daySet:Set<String> = Set<String>()
        
        for data in coredata {
            if data.applicationName == applicationName {
                let currentElementDate = CustomDate.buildMonthDayString(target: data.startTime!)
                if !daySet.contains(currentElementDate) {
                    daySet.insert(currentElementDate)
                }
                startTime = Int(calendar.component(.hour, from: data.startTime!))
                endTime = Int(calendar.component(.hour, from: data.endTime!))
                avgClick = Double(data.mouseClickTime)/Double(endTime - startTime + 1)
                for i in startTime...endTime {
                    output[i] += avgClick
                }
            }
        }
        
        for i in 0..<24 {
            output[i] /= Double(daySet.count)
        }
        return output
    }
    
    static func keyPressCount(_ coredata: [CoreDataActivity], _ applicationName: String) -> [Double] {
        var output = [Double](repeating: 0, count: 24)
        let calendar = Calendar.current
        var startTime:Int
        var endTime:Int
        var avgClick:Double = 0
        var daySet:Set<String> = Set<String>()
        
        for data in coredata {
            if data.applicationName == applicationName {
                let currentElementDate = CustomDate.buildMonthDayString(target: data.startTime!)
                if !daySet.contains(currentElementDate) {
                    daySet.insert(currentElementDate)
                }
                startTime = Int(calendar.component(.hour, from: data.startTime!))
                endTime = Int(calendar.component(.hour, from: data.endTime!))
                avgClick = Double(data.keyPressTime)/Double(endTime - startTime + 1)
                for i in startTime...endTime {
                    output[i] += avgClick
                }
            }
        }
        for i in 0..<24 {
            output[i] /= Double(daySet.count)
        }
        return output
    }
    
    static func timeUsageCount(_ coredata: [CoreDataActivity], _ applicationName: String) -> [Double] {
        var output = [Double](repeating: 0, count: 24)
        let calendar = Calendar.current
        var daySet:Set<String> = Set<String>()
        
        for data in coredata {
            if data.applicationName == applicationName {
                let currentElementDate = CustomDate.buildMonthDayString(target: data.startTime!)
                if !daySet.contains(currentElementDate) {
                    daySet.insert(currentElementDate)
                }
                if Int(calendar.component(.hour, from: data.endTime!)) > Int(calendar.component(.hour, from: data.startTime!))  {
                    for i in Int(calendar.component(.hour, from: data.startTime!))+1..<Int(calendar.component(.hour, from: data.endTime!)) {
                        output[i] += 60
                    }
                    output[Int(calendar.component(.hour, from: data.startTime!))] += Double(60 - calendar.component(.minute, from: data.startTime!))
                    output[Int(calendar.component(.hour, from: data.endTime!))] += Double(calendar.component(.minute, from: data.endTime!))
                }
                else {
                    output[Int(calendar.component(.hour, from: data.startTime!))] += CustomDate.dateDiff(start: data.startTime!, end: data.endTime!)/60
                }
                
            }
        }
        for i in 0..<24 {
            output[i] /= Double(daySet.count)
        }
        return output
    }
    
    //compare today's data to input coreData
    static func getProductivityData(todayData: [CoreDataActivity], compareData: [CoreDataActivity]) -> [Double] {
        var output = [Double](repeating: Double.leastNormalMagnitude, count: 24)
        var todayClickData = [Double](repeating: 0, count: 24)
        var compClickData = [Double](repeating: 0, count: 24)
        var startTime:Int
        var endTime:Int
        var avgClick:Double
        var daySet:Set<String> = Set<String>()
        
        //count all click and key press
        for data in todayData {
            startTime = Int(Calendar.current.component(.hour, from: data.startTime!))
            endTime = Int(Calendar.current.component(.hour, from: data.endTime!))
            avgClick = Double(data.keyPressTime + data.mouseClickTime)/Double(endTime - startTime + 1)
            for i in startTime...endTime {
                todayClickData[i] += avgClick
            }
        }
        
        for data in compareData {
            let currentElementDate = CustomDate.buildMonthDayString(target: data.startTime!)
            if !daySet.contains(currentElementDate) {
                daySet.insert(currentElementDate)
            }
            startTime = Int(Calendar.current.component(.hour, from: data.startTime!))
            endTime = Int(Calendar.current.component(.hour, from: data.endTime!))
            avgClick = Double(data.keyPressTime + data.mouseClickTime)/Double(endTime - startTime + 1)
            for i in startTime...endTime {
                compClickData[i] += avgClick
            }
        }
        
        for i in 0..<24 {
            compClickData[i] /= Double(daySet.count)
        }
        
        /* two cases:
        1.the today's data after current time : not display
        2. history data is zero: -2(special mark)  */
        for i in 0...Int(Calendar.current.component(.hour, from: Date())) {
  
            if compClickData[i] == 0{
                output[i] = Double.leastNormalMagnitude
            }
            else {
                output[i] = (todayClickData[i] - compClickData[i])/compClickData[i]
                print(output[i])
            }
        }
        return output
    }
    
    
}
