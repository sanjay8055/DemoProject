//
//  Step.swift
//  ZipID
//
//  Created by Damien Hill on 17/11/2015.
//  Copyright © 2015 ZipID. All rights reserved.
//

import Foundation

class Step {
    let stepId: String
    let template: String
    let success: Bool?
    let title: String?
    let body: String?
    let next: String?
    let optionGroups: Array<StepOptionGroup>?

    init(dictionary: Dictionary<String, AnyObject>) {
        stepId = dictionary["stepId"] as! String
        template = dictionary["template"] as! String
        title = dictionary["title"] as? String
        body = dictionary["body"] as? String
        next = dictionary["next"] as? String
        success = dictionary["success"] as? Bool
        
        if (dictionary["optionGroups"] != nil) {
            optionGroups = []
            for value in dictionary["optionGroups"] as! Array<AnyObject> {
                optionGroups?.append(StepOptionGroup(dictionary: value as! Dictionary<String, AnyObject>))
            }
        } else {
            optionGroups = nil
        }
    }
    
    func allOptions() -> Array<StepOption> {
        var options: Array<StepOption> = []
        if (optionGroups != nil) {
            for optionGroup in optionGroups! {
                if (optionGroup.options != nil) {
                    for option in optionGroup.options! {
                        options.append(option)
                    }
                }
            }
        }
        return options
    }
}

class StepOptionGroup {
    let title: String?
    let options: Array<StepOption>?
    
    init(dictionary: Dictionary<String, AnyObject>) {
        title = dictionary["groupTitle"] as? String
        if (dictionary["options"] != nil) {
            options = []
            for value in dictionary["options"] as! Array<AnyObject> {
                options?.append(StepOption(dictionary: value as! Dictionary<String, AnyObject>))
            }
        } else {
            options = nil
        }
    }
}

class StepOption {
    let optionId: Int
    let name: String
    let subtitle: String?
    let iconName: String?
    var docs: Array<String>? = nil
    let next: String
    
    init(dictionary: Dictionary<String, AnyObject>) {
        optionId = dictionary["optionId"] as! Int
        name = dictionary["name"] as! String
        subtitle = dictionary["subtitle"] as? String
        docs = dictionary["docs"] as? Array<String>
        next = dictionary["next"] as! String
        iconName = dictionary["icon"] as? String
    }
    
//    func iconName() -> String? {
//        if (self.docs?.count == 1) {
//            if ["APP", "FPN", "MED", "CTL", "VAC", "ADL", "POA", "CTZ", "BTH", "DSC", "MRG", "NAM"].contains(self.docs![0]) {
//                return "icon-" + self.docs![0]
//            } else {
//                return "icon-generic"
//            }
//        } else {
//            return nil
//        }
//    }
    
}