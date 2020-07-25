//
//  AppleScript.swift
//  Productivity Analytics Implementation
//
//  Created by KUAN-YU CHEN on 2020/7/4.
//  Copyright © 2020 KUAN-YU CHEN. All rights reserved.
//

import Foundation

class AppleScript {
    static let detectFrontWindowAppleScript =
    """
    global activeApp, appName
    tell application "System Events"
        set activeApp to first application process whose frontmost is true
        set appName to name of activeApp
    end tell
    return appName
    """
    
    static let waitChangeAppleScript =
    """
    global activeAppName
    tell application "System Events"
        set activeAppName to name of first application process whose frontmost is true
        repeat until (activeAppName is not (name of first application process whose frontmost is true))
        end repeat
    end tell
    return
    """
}
