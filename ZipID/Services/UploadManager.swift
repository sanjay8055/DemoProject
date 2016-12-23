//
//  UploadManager.swift
//  ZipID
//
//  Created by Damien Hill on 6/11/2015.
//  Copyright © 2015 ZipID. All rights reserved.
//

import Foundation
import Analytics
import Crashlytics

@objc class UploadManager: NSObject {
    static let sharedInstance = UploadManager()

    private var uploads = [String: Float]()
    
    func clearUploads () {
        self.uploads.removeAll()
    }
    
    func newUpload (uploadGUID: String) {
        self.uploads[uploadGUID] = 0
    }
    
    func removeUpload (uploadGUID: String) {
        self.uploads.removeValueForKey(uploadGUID)
    }
    
    func inProgress (uploadGUID: String) -> Bool {
        return self.uploads[uploadGUID] != nil
    }
    
    func getProgress (uploadGUID: String) -> Float {
        return self.uploads[uploadGUID]!
    }
    
    func startBackgroundUpload (job: Job) {
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            CLSLogv("Starting background upload", getVaList([]))
            UploadManager.sharedInstance.uploadJobWithCompletion(job, completion: { (success, error) in
                if (success) {
                    CLSLogv("Success completing upload task in background", getVaList([]))
                } else {
                    if let errorDescription = error?.localizedDescription {
                        CLSLogv("Error completing upload task in background: %@", getVaList([errorDescription]))
                    } else {
                        CLSLogv("Error completing upload task in background", getVaList([]))
                    }
                }
            })
        }
    }
    
    func uploadJobWithCompletion (job: Job, completion: (success: Bool, error: NSError?) -> Void) {
        ZPApiClient.sharedInstance().validateTokenWithSuccess({ () -> Void in
            self.newUpload(job.jobGUID)
            let basePath: String = ZPStringHelper.applicationDocumentsDirectory().path!
            let zipPath: String = basePath + "/" + job.jobGUID + ".zip"
            let encryptedZipPath: String = basePath + "/" + job.jobGUID + ".zip.enc"
            let encryptedKeyPath: String = basePath + "/" + job.jobGUID + ".txt.enc"
            let encryptedIVPath: String = basePath + "/" + job.jobGUID + "-iv.txt.enc"
            
            ZPApiClient.sharedInstance().uploadReport(zipPath,
                withEncryptedReport: encryptedZipPath,
                withKey: encryptedKeyPath,
                withIV: encryptedIVPath,
                success: { () -> Void in
                    self.removeUpload(job.jobGUID)
                    job.jobStatusRaw = JobStatusCompleted
                    
                    //remove identifying data.
                    job.dateOfBirth = nil
                    job.middleName = nil
//                    if let firstName = job.firstName {
//                        let r = firstName.startIndex.advancedBy(0)
//                        let shortFirstName: String = String(firstName[r]).stringByAppendingString(".")
//                        job.firstName = shortFirstName
//                    }
                    
                    NSUserDefaults.standardUserDefaults().setObject(1, forKey: "verificationUploaded")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    if let responseId = job.jobGUID, verificationType = job.verificationType {
                        SEGAnalytics.sharedAnalytics().track("Verification Uploaded", properties: ["Response ID": responseId, "Verification type": verificationType])
                    }
                    NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreWithCompletion({ (success: Bool, error: NSError?) -> Void in
                        NSNotificationCenter.defaultCenter().postNotificationName("uploadComplete",
                            object: nil,
                            userInfo: ["jobGUID": job.jobGUID, "success": success])
                        completion(success: success, error: nil)
                    })
                    
                }, failure: { (error: NSError!) -> Void in
                    print("Upload failed with error:" + error.localizedDescription)
                    self.removeUpload(job.jobGUID)
                    if let responseId = job.jobGUID, verificationType = job.verificationType {
                        SEGAnalytics.sharedAnalytics().track("Verification Failed to Upload", properties: ["Response ID": responseId, "Verification type": verificationType])
                    }
                    completion(success: false, error: error)
                    
                }, progress: { (progress: Float) -> Void in
                    var progressUpdate = progress
                    if (progressUpdate > 0.20) {
                        progressUpdate = progressUpdate - 0.09
                    }
                    self.uploads[job.jobGUID] = progressUpdate
            })
            
        }) { (error: NSError!) -> Void in
            print("validate token failed: @", error.localizedDescription)
            if error.domain == "au.com.zipid.zipid" && error.code == 401 {
                NSNotificationCenter.defaultCenter().postNotificationName("tokenInvalid", object:self)
            }
            completion(success: false, error: error)
        }
    }
}