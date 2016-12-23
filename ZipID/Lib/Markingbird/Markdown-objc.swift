//
//  Markdown-objc.swift
//  ZipID
//
//  Created by Damien Hill on 8/12/2015.
//  Copyright © 2015 ZipID. All rights reserved.
//

import Foundation

@objc class MarkingbirdObjc: NSObject {
    
    class func render(inputText: String) -> String {
        var markdown = Markdown()
        return markdown.transform(inputText)
    }

}