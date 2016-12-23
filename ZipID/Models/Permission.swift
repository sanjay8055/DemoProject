//
//  Permission.swift
//  ZipID
//
//  Created by Damien Hill on 9/12/2015.
//  Copyright © 2015 ZipID. All rights reserved.
//

import Foundation

@objc class Permission: NSObject {
    
    let name: PermissionName
    let enabled: Bool
    
    init(name: PermissionName, enabled: Bool) {
        self.name = name
        self.enabled = enabled
    }
    
    @objc class func permissionNameForString(name: String) -> PermissionName {
        switch (name) {
        case "adhoc":
            return PermissionName.Adhoc
        case "fetchJobs":
            return PermissionName.FetchJobs
        case "testMode":
            return PermissionName.TestMode
        case "manualForward":
            return PermissionName.ManualForward
        case "locationServicesRequired":
            return PermissionName.LocationServicesRequired
        default:
            return PermissionName.None
        }
    }
    
}