//
//  ZPImageResponseSpec.swift
//  ZipID
//
//  Created by Damien Hill on 18/09/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

import XCTest

class ZPImageResponseSpec: XCTestCase {
    
    func testImageName() {
        let imageResponse = ZPImageResponse()
        imageResponse.questionIndex = 1
        imageResponse.documentId = "APP"
        XCTAssertEqual(imageResponse.imageName(), "1-APP.jpg", "image name should be in format documentId-questionIndex.jpg")
    }
    
}
