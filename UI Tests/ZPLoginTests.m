//
//  ZPLoginTests.m
//  ZipID
//
//  Created by Damien Hill on 19/08/2015.
//  Copyright (c) 2015 ZipID. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "KIFTestCase.h"
#import "KIFUITestActor+ZPAdditions.h"


@interface ZPLoginTests : XCTestCase

@property (nonatomic, retain) ZPMockService *mockService;

@end


@implementation ZPLoginTests

- (void)setUp {
    [super setUp];
    _mockService = [ZPMockService sharedInstance];
    
    [_mockService stub:@"GET" path:@"/api/ios/v3/version-check" file:@"version-check-valid.json"];
    [_mockService stub:@"POST" path:@"/api/ios/v3/validate-token" file:@"token-valid-with-adhoc-fetch.json"];
    [tester tapViewWithAccessibilityLabel:@"Skip"];
}

- (void)tearDown {
    [_mockService removeAllStubs];
    [tester resetApp];
    [super tearDown];
}

- (void)testThatAllowsGoodLoginCredentials {
    [tester login];
    [tester logout];
}

- (void)testThatRejectsBadLoginCredentials {
    [_mockService stub:@"POST" path:@"/api/ios/v3/login" file:@"login-invalid.json"];
    
    [tester tapViewWithAccessibilityLabel:@"Sign in"];
    [tester enterText:@"999999" intoViewWithAccessibilityLabel:@"ZipID Business Code"];
    [tester enterText:@"badpassword" intoViewWithAccessibilityLabel:@"Password"];
    [tester tapViewWithAccessibilityLabel:@"Sign in"];
    
    // Alert view
    [tester waitForTappableViewWithAccessibilityLabel:@"Ok"];
    [tester tapViewWithAccessibilityLabel:@"Ok"];
    [tester waitForTappableViewWithAccessibilityLabel:@"Sign in"];
    [tester tapViewWithAccessibilityLabel:@"Back"];
    
    // Reset app not working correctly in tests without a successful login
    [tester login];
    [tester logout];
}

//- (void)testThatShowsAlertWhenServerIsDown {
//    [_mockService removeAllStubs];
//    
//    [tester tapViewWithAccessibilityLabel:@"Sign in"];
//    [tester enterText:@"3" intoViewWithAccessibilityLabel:@"ZipID Business Code"];
//    [tester enterText:@"zipiddemo" intoViewWithAccessibilityLabel:@"Password"];
//    [tester tapViewWithAccessibilityLabel:@"Sign in"];
//    
//    // Alert view
//    [tester waitForTappableViewWithAccessibilityLabel:@"Ok"];
//    [tester tapViewWithAccessibilityLabel:@"Ok"];
//    [tester waitForTappableViewWithAccessibilityLabel:@"Sign in"];
//    [tester tapViewWithAccessibilityLabel:@"Back"];
//}

@end
