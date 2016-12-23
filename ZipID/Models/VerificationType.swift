//
//  VerificationType.swift
//  ZipID
//
//  Created by Damien Hill on 19/11/2015.
//  Copyright © 2015 ZipID. All rights reserved.
//

import Foundation

@objc class VerificationType: NSObject {
    
    let verificationTypeId: String
    let name: String
    let userSelectable: Bool
    let questionSets: Array<String>
    
    init(dictionary: Dictionary<String, AnyObject>) {
        verificationTypeId = dictionary["id"] as! String
        userSelectable = dictionary["userSelectable"] as! Bool
        name = dictionary["name"] as! String
        questionSets = dictionary["acceptedIdentityDocuments"] as! Array<String>
    }
    
}
