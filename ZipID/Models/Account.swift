//
//  Account.swift
//  ZipID
//
//  Created by Damien Hill on 16/12/2015.
//  Copyright © 2015 ZipID. All rights reserved.
//

import Foundation

@objc class Account: NSObject {
    
    let id: Int
    let name: String
    let verificationTypes: Array<String>
    let address: String?
    let type: String?
    
    init(id: Int, name: String, verificationTypes: Array<String>, address: String?, type: String?) {
        self.id = id
        self.name = name
        self.verificationTypes = verificationTypes
        self.address = address
        self.type = type
    }
    
    convenience init?(dictionary: Dictionary<String, AnyObject>) {
        if let newId = dictionary["id"] as? Int, newName = dictionary["name"] as? String, newVerificationTypes = dictionary["verificationTypes"] as? Array<String> {
            let address = dictionary["address"] as? String
            let type = dictionary["type"] as? String
            self.init(id: newId, name: newName, verificationTypes: newVerificationTypes, address: address, type: type)
        } else {
            print("Warning: missing name, id, verificationTypes or address in dictionary for account init")
            return nil
        }
    }
    
    func toDictionary() -> Dictionary<String, AnyObject> {
        let address = (self.address != nil) ? self.address! : ""
        let type = (self.type != nil) ? self.type! : ""
        let dictionary: [String: AnyObject] = [
            "id": self.id,
            "name": self.name,
            "verificationTypes": self.verificationTypes,
            "address": address,
            "type": type
        ]
        return dictionary
    }

}
