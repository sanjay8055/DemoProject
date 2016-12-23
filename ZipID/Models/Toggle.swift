//
//  Toggle.swift
//  ZipID
//
//  Created by Damien Hill on 9/12/2015.
//  Copyright © 2015 ZipID. All rights reserved.
//

import Foundation

@objc class Toggle: NSObject {

    let name: ToggleName
    let enabled: Bool
 
    init(name: ToggleName, enabled: Bool) {
        self.name = name
        self.enabled = enabled
    }
    
    @objc class func toggleNameForString(name: String) -> ToggleName {
        switch (name) {
            case "iosNewCamera":
                return ToggleName.NewCamera
            default:
                return ToggleName.None
        }
    }
    
}