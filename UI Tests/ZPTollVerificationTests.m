//
//  ZPTollVerificationTests.m
//  ZipID
//
//  Created by Damien Hill on 19/08/2015.
//  Copyright (c) 2015 ZipID. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "KIFTestCase.h"
#import "KIFUITestActor+ZPAdditions.h"
#import "KIFUITestActor+ZPStubs.h"

@interface ZPTollVerificationTests : XCTestCase

@end

@implementation ZPTollVerificationTests

- (void)setUp {
    [super setUp];
    [tester stubValidUpload];
    [tester stubTollJobs];
    [tester stubValidateTokenWithFetch];
    
    [tester tapViewWithAccessibilityLabel:@"Skip"];
    [tester tollLogin];
}


- (void)tearDown {
    [tester logout];
    [[ZPMockService sharedInstance] removeAllStubs];
    [tester resetApp];    
    [super tearDown];
}

- (void)testShouldPerformTollVerification {
    //wait for background auto fetch jobs
    [tester waitForTimeInterval:1];
       
    [tester tapRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:1] inTableViewWithAccessibilityIdentifier:@"Client list"];
    [tester tapViewWithAccessibilityLabel:@"Begin verification"];
    
    // Agent list
    [tester tapViewWithAccessibilityLabel:@"Add verifier"];
    [tester enterText:@"John" intoViewWithAccessibilityLabel:@"First name"];
    [tester enterText:@"Smith" intoViewWithAccessibilityLabel:@"Last name"];
    [tester tapViewWithAccessibilityLabel:@"Done"];
    [tester tapRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] inTableViewWithAccessibilityIdentifier:@"Verifier list"];
    [tester tapViewWithAccessibilityLabel:@"Next"];
    
    // 5 point check
    [tester tapViewWithAccessibilityLabel:@"Next"];
    
    // Passport (1 photo, 1 skip)
    [tester tapViewWithAccessibilityLabel:@"Camera"];
    [tester tapViewWithAccessibilityLabel:@"Next"];
    [tester tapViewWithAccessibilityLabel:@"Next"];
    
    // Licence (2 photos)
    [tester tapViewWithAccessibilityLabel:@"Camera"];
    [tester tapViewWithAccessibilityLabel:@"Next"];
    [tester tapViewWithAccessibilityLabel:@"Camera"];
    [tester tapViewWithAccessibilityLabel:@"Next"];
    
    // Additional docs (skip)
    [tester tapViewWithAccessibilityLabel:@"Next"];
    
    // Client photo
    //[tester waitForTimeInterval:.5];
    [tester tapViewWithAccessibilityLabel:@"Camera"];
    [tester tapViewWithAccessibilityLabel:@"Next"];
    
    // Client signature
    [tester waitForTimeInterval:.3];
    [tester tapViewWithAccessibilityLabel:@"Signature"];
    [tester swipeViewWithAccessibilityLabel:@"DrawSignature" inDirection:KIFSwipeDirectionRight];
    [tester tapViewWithAccessibilityLabel:@"Done"];
    [tester tapViewWithAccessibilityLabel:@"Next"];
    
    // Agent declaration page
    [tester tapViewWithAccessibilityLabel:@"Continue"];
    
    // Privacy
    //        [tester tapViewWithAccessibilityLabel:@"Next"];
    
    // Review
    [tester tapViewWithAccessibilityLabel:@"Submit"];
    
    // Complete
    [tester tapViewWithAccessibilityLabel:@"Done"];
    
    // report automatically uploaded.
    [tester tapRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1] inTableViewWithAccessibilityIdentifier:@"Client list"];
    
    //verify the call to upload
    
    [tester tapViewWithAccessibilityLabel:@"Clients"];
    [tester waitForViewWithAccessibilityLabel:@"Menu"];
}

@end
