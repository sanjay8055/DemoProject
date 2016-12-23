//
//  Response.swift
//  ZipID
//
//  Created by Damien Hill on 18/11/2015.
//  Copyright © 2015 ZipID. All rights reserved.
//

import Foundation

enum ResponseType {
    case DocumentList               // [ADL, APP]
    case IdentificationDocuments    // [ImageResponse]
    case AdditionalDocuments        // [ImageResponse]
    case Text                       // [ ["Firm name", "ABC Conveyancing"] ]
    case ClientPhoto                // [ImageResponse]
    case ClientSignature            // [ImageResponse]
    case AgentSignature             // [ImageResponse]
    case MultiChoice                // [AnyObjects]
}

class Response {    
    let responseType: ResponseType
    var response: Array<AnyObject> = []

    init(responseType: ResponseType) {
        self.responseType = responseType
    }
}