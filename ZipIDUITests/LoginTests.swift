//
//  LoginTests.swift
//  ZipID
//
//  Created by Damien Hill on 6/06/2016.
//  Copyright © 2016 ZipID. All rights reserved.
//

import Foundation
import XCTest

class LoginTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
//        let mockService = ZPMockService.sharedInstance()
//        mockService.stub("GET", path: "/api/ios/v3/version-check", file: "version-check-valid.json")
//        mockService.stub("POST", path: "/api/ios/v3/validate-token", file: "token-valid-with-adhoc-fetch.json")
        
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launchArguments = ["MOCK_HTTP_SERVER"]
        app.launch()
        
        // reset app here
    }
    
    override func tearDown() {
//        let mockService = ZPMockService.sharedInstance()
//        mockService.removeAllStubs()
        // reset app here
        super.tearDown()
    }
    
    func testGoodCredentials() {
//        let mockService = ZPMockService.sharedInstance()
//        mockService.stub("GET", path: "/api/ios/v3/login", file: "login-valid.json")
//        mockService.stub("POST", path: "/api/ios/v3/jobs/3", file: "empty-jobs.json")
//        
//        let app = XCUIApplication()
//        
//
//
//        let skip = app.buttons["Skip"]
//        if skip.exists {
//            skip.tap()
//        }
//        
//        let elementsQuery = app.scrollViews.otherElements
//        elementsQuery.buttons["Sign in"].tap()
//        elementsQuery.textFields["Email address"].typeText("3")
//        elementsQuery.secureTextFields["Password"].tap()
//        elementsQuery.secureTextFields["Password"].typeText("zipiddemo")
        
//        app.navigationBars["ZPLoginView"].buttons["Sign in"].tap()
        
//        [tester waitForTappableViewWithAccessibilityLabel:@"Menu"];
//        [tester waitForTimeInterval:2];
    }
    
}