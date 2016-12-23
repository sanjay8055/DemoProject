//
//  StepProcess.swift
//  ZipID
//
//  Created by Damien Hill on 17/11/2015.
//  Copyright © 2015 ZipID. All rights reserved.
//

import Foundation

enum StepProcessType {
    case DocumentPicker
    case VerificationType
}

class StepProcess {
    
    let start: String
    let steps: [String: Step]
    let storyboardName: String
    
    init(dictionary: Dictionary<String, AnyObject>) {
        self.start = dictionary["start"] as! String
        self.storyboardName = "DocumentPicker"
        var steps: [String: Step] = [:]
        for (key, value) in dictionary["steps"] as! Dictionary<String, AnyObject> {
            steps[key] = Step(dictionary: value as! Dictionary<String, AnyObject>)
        }
        self.steps = steps
    }
    
    func startStep() -> Step {
        return self.steps[self.start]!
    }
    
    class func endPointNameForProcessType(processType: StepProcessType) -> String {
        switch processType {
            case .DocumentPicker: return "document-pickers"
            case .VerificationType: return "verification-types"
        }
    }
    
    class func getStepProcess(pickerId: String, processType: StepProcessType) -> StepProcess {
        let endPointName = endPointNameForProcessType(processType)
        let stepProcessDict = ZPPersistentEndpoint.endpointWithName(endPointName).response as! Dictionary<String, AnyObject>
        let stepProcess = stepProcessDict[pickerId] as! Dictionary<String, AnyObject>
        let config = stepProcess["config"] as! Dictionary<String, AnyObject>
        return StepProcess(dictionary: config)
    }
}