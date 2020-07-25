//
//  DetectCore.swift
//  Productivity Analytics Implementation
//
//  Created by KUAN-YU CHEN on 2020/7/4.
//  Copyright © 2020 KUAN-YU CHEN. All rights reserved.
//

import Cocoa
import Foundation

class DetectCore {
    var applicationName:String
    var mouseClickNum:Int32
    var keyDownNum:Int32
    var startTime:Date
    var endTime:Date
    
    
    init() {
        self.applicationName = ""
        self.mouseClickNum = 0
        self.keyDownNum = 0
        self.startTime = Date()
        self.endTime = Date()
    }
    
    func clear() {
        self.mouseClickNum = 0
        self.keyDownNum = 0
    }
    
    func inputEventRegister() {
        NSEvent.addGlobalMonitorForEvents(matching: NSEvent.EventTypeMask.leftMouseDown, handler: {(leftMouseClickEvent:NSEvent) in
            self.mouseClickNum += 1
        })
        
        NSEvent.addGlobalMonitorForEvents(matching: NSEvent.EventTypeMask.rightMouseDown, handler: {(rightMouseClickEvent:NSEvent) in
            self.mouseClickNum += 1
        })
        
        NSEvent.addGlobalMonitorForEvents(matching: NSEvent.EventTypeMask.keyDown, handler: {(keyDownEvent:NSEvent) in
            self.keyDownNum += 1
        })
        
        /*NSEvent.addGlobalMonitorForEvents(matching: NSEvent.EventTypeMask.mouseMoved, handler: {(mouseMoveEvent:NSEvent) in
            let position = mouseMoveEvent.locationInWindow
            print(position)
        })*/
    }
    
    func activeWindowDetect() {
        var error: NSDictionary?
        let dispatchQueue = DispatchQueue(label: "DetectActiveWindow", qos: .background)
        dispatchQueue.async{
            while true {
                //get the current using window name
                if let scriptObject = NSAppleScript(source: AppleScript.detectFrontWindowAppleScript) {
                    if let output: NSAppleEventDescriptor = scriptObject.executeAndReturnError(
                        &error) {
                        print(output.stringValue ?? "unknown application")
                        self.applicationName = output.stringValue!
                    } else if (error != nil) {
                        print("error: \(String(describing: error))")
                    }
                }
                self.startTime = Date()
                                
                //wait for the change of active window
                if let scriptObject = NSAppleScript(source: AppleScript.waitChangeAppleScript) {
                    if let _: NSAppleEventDescriptor = scriptObject.executeAndReturnError(
                        &error) {
                    } else if (error != nil) {
                        print("error: \(String(describing: error))")
                    }
                }
                self.endTime = Date()
                
                //post notification to update coredata
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateActivityData"), object: nil)
                self.clear()
            }
            
        }
    }
}
