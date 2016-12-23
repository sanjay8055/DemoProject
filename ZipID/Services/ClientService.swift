//
//  ClientService.swift
//  ZipID
//
//  Created by Damien Hill on 6/06/2016.
//  Copyright © 2016 ZipID. All rights reserved.
//

import Foundation

@objc class ClientService: NSObject {
    
    class func createPractice() -> Job? {
        let job = create()
        job?.practice = true
        job?.selectedQuestionSets = defaultDocuments()
        job?.jobStatusRaw = JobStatusReady
        
        job?.firstName = "Thomas"
        job?.middleName = "Adam"
        job?.lastName = "Anderson"
        job?.genderRaw = GenderMale
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        job?.dateOfBirth = dateFormatter.dateFromString("1979-07-29")
        
        return job
    }
    
    class func create() -> Job? {
        if let job = Job.MR_createEntity() {
            job.agentId = ZPSubscriber.sharedInstance().agentId
            if let owner = defaultOwner() {
                job.agentForBusinessCode = String(owner.id)
                if let verificationType = defaultVerificationType(owner) {
                    job.verificationType = verificationType.verificationTypeId
                    job.verificationTypeObj = verificationType
                    job.selectedQuestionSets = nil
                }
            }
            return job
        } else {
            return nil
        }
    }
 
    class func defaultOwner() -> Account? {
        return ZPSubscriber.sharedInstance().brokerFor.first as? Account
    }
    
    class func defaultVerificationType(account: Account) -> ZPVerificationType? {
        if let verificationTypeId = account.verificationTypes.first {
            return ZPVerificationType.findById(verificationTypeId)
        } else {
            return nil
        }
    }
    
    class func defaultDocuments() -> Array<String> {
        return ["APP", "ADL"]
    }
    
}
