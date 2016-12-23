//
//  UserInputHelper.swift
//  ZipID
//
//  Created by Brett Dargan on 8/06/2016.
//  Copyright © 2016 ZipID. All rights reserved.
//

import Foundation

@objc class UserInputHelper : NSObject {
    class func validateUserInput(name: String, text: String?) -> String? {
        let regex = try! NSRegularExpression(pattern: "[\\[\\]<>()%;/\\\\*=]|--", options: [])
        var errorMessage: String?
        
        if (text != nil) {
            let restrictedCharMatch = regex.firstMatchInString(text!, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, text!.characters.count)) != nil
            if (restrictedCharMatch) {
                errorMessage = name.stringByAppendingString(" must not contain any special characters including < > ( ) % ; / \\ [ ] * = --")
            }
        }
        return errorMessage;
    }
}