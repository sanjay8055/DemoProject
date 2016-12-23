//
//  ZPVerificationTests.m
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

@interface ZPVerificationTests : XCTestCase

@end

@implementation ZPVerificationTests

- (void)setUp {
    [super setUp];
    [tester tapViewWithAccessibilityLabel:@"Skip"];
    [tester login];
    [tester stubValidUpload];
    [tester stubEmptyJobs];
    [tester stubValidateTokenWithAdhoc];
}

- (void)tearDown {
    [tester stubEmptyJobs];
    [tester logout];
    [[ZPMockService sharedInstance] removeAllStubs];
    [tester resetApp];    
    [super tearDown];
}

- (void)testShouldPerformPEXAVerification {
    [tester tapViewWithAccessibilityLabel:@"New job"];
    [tester enterText:@"Thomas" intoViewWithAccessibilityLabel:@"First name"];
    [tester enterText:@"Adam" intoViewWithAccessibilityLabel:@"Middle name"];
    [tester enterText:@"Anderson" intoViewWithAccessibilityLabel:@"Last name"];
    [tester tapViewWithAccessibilityLabel:@"Male"];
    
    [tester tapViewWithAccessibilityLabel:@"Date of birth"];
    [tester selectDatePickerValue:@[@"July", @"20", @"1969"]];
    
    [tester tapViewWithAccessibilityLabel:@"Select ID documents"];
    [tester tapViewWithAccessibilityLabel:@"Australian Passport"];
    [tester tapViewWithAccessibilityLabel:@"Australian Drivers Licence"];
    [tester tapViewWithAccessibilityLabel:@"Done"];
    [tester tapViewWithAccessibilityLabel:@"Done"];
    
    [tester tapRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:1] inTableViewWithAccessibilityIdentifier:@"Client list"];
    [tester tapViewWithAccessibilityLabel:@"Begin verification"];
    
    // Agent list
    [tester tapViewWithAccessibilityLabel:@"Add verifier"];
    [tester enterText:@"John" intoViewWithAccessibilityLabel:@"First name"];
    [tester enterText:@"Smith" intoViewWithAccessibilityLabel:@"Last name"];
    [tester tapViewWithAccessibilityLabel:@"Done"];
    [tester tapRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] inTableViewWithAccessibilityIdentifier:@"Verifier list"];
    [tester tapViewWithAccessibilityLabel:@"Next"];
    
    
    // PEXA info - these 2 steps fail as the textfields are custom and don't seem to work with KIF
    //        [tester enterText:@"ZipID Pty Ltd" intoViewWithAccessibilityLabel:@"Firm name"];
    //        [tester enterText:@"23/05/78" intoViewWithAccessibilityLabel:@"Date of birth"];
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
    
    // Client signature card (photo)
    [tester tapViewWithAccessibilityLabel:@"Camera"];
    [tester tapViewWithAccessibilityLabel:@"Next"];
    
    // Agent declaration page 1
    [tester tapViewWithAccessibilityLabel:@"Next"];
    
    // Agent signature
    [tester waitForTimeInterval:1];
    [tester tapViewWithAccessibilityLabel:@"Next"];
    [tester tapViewWithAccessibilityLabel:@"Signature"];
    [tester swipeViewWithAccessibilityLabel:@"DrawSignature" inDirection:KIFSwipeDirectionRight];
    [tester tapViewWithAccessibilityLabel:@"Done"];
    [tester tapViewWithAccessibilityLabel:@"Next"];
    
    // Privacy
    [tester tapViewWithAccessibilityLabel:@"Next"];
    
    // Review
    [tester tapViewWithAccessibilityLabel:@"Submit"];
    
    // Complete
    [tester tapViewWithAccessibilityLabel:@"Done"];
    
    // Upload report
//    [tester tapRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1] inTableViewWithAccessibilityIdentifier:@"Client list"];
    
//    [tester tapViewWithAccessibilityLabel:@"Clients"];
    [tester waitForViewWithAccessibilityLabel:@"Menu"];
}

- (void)testShouldPerformReauthPriorToSubmission {
    [[ZPMockService sharedInstance] removeAllStubs];
    [tester stubFailedValidateToken];
    [tester stubEmptyJobs];
    
    [tester tapViewWithAccessibilityLabel:@"New job"];
    [tester enterText:@"Thomas" intoViewWithAccessibilityLabel:@"First name"];
    [tester enterText:@"Adam" intoViewWithAccessibilityLabel:@"Middle name"];
    [tester enterText:@"Anderson" intoViewWithAccessibilityLabel:@"Last name"];
    [tester tapViewWithAccessibilityLabel:@"Male"];
    
    [tester tapViewWithAccessibilityLabel:@"Date of birth"];
    [tester selectDatePickerValue:@[@"July", @"20", @"1969"]];
    
    [tester tapViewWithAccessibilityLabel:@"Select ID documents"];
    [tester tapViewWithAccessibilityLabel:@"Australian Passport"];
    [tester tapViewWithAccessibilityLabel:@"Australian Drivers Licence"];
    [tester tapViewWithAccessibilityLabel:@"Done"];
    [tester tapViewWithAccessibilityLabel:@"Done"];
    
    [tester tapRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:1] inTableViewWithAccessibilityIdentifier:@"Client list"];
    [tester tapViewWithAccessibilityLabel:@"Begin verification"];
    
    // Agent list
    [tester tapViewWithAccessibilityLabel:@"Add verifier"];
    [tester enterText:@"John" intoViewWithAccessibilityLabel:@"First name"];
    [tester enterText:@"Smith" intoViewWithAccessibilityLabel:@"Last name"];
    [tester tapViewWithAccessibilityLabel:@"Done"];
    [tester tapRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] inTableViewWithAccessibilityIdentifier:@"Verifier list"];
    [tester tapViewWithAccessibilityLabel:@"Next"];
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
    
    // Client signature card (photo)
    [tester tapViewWithAccessibilityLabel:@"Camera"];
    [tester tapViewWithAccessibilityLabel:@"Next"];
    
    // Agent declaration page 1
    [tester tapViewWithAccessibilityLabel:@"Next"];
    
    // Agent signature
    [tester waitForTimeInterval:1];
    [tester tapViewWithAccessibilityLabel:@"Next"];
    [tester tapViewWithAccessibilityLabel:@"Signature"];
    [tester swipeViewWithAccessibilityLabel:@"DrawSignature" inDirection:KIFSwipeDirectionRight];
    [tester tapViewWithAccessibilityLabel:@"Done"];
    [tester tapViewWithAccessibilityLabel:@"Next"];
    
    // Privacy
    [tester tapViewWithAccessibilityLabel:@"Next"];
    
    // Review
    [tester tapViewWithAccessibilityLabel:@"Submit"];
    
    // Cancel first reauth
    [tester waitForViewWithAccessibilityLabel:@"Password"];
    [tester tapViewWithAccessibilityLabel:@"Cancel" traits:UIAccessibilityTraitButton];
    
    // Complete
    [tester tapViewWithAccessibilityLabel:@"Done"];
    
    // Check that job is waiting to upload
    [tester tapRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1] inTableViewWithAccessibilityIdentifier:@"Client list"];

    // Tap upload
    [tester tapViewWithAccessibilityLabel:@"Upload report"];
    
    // Login
    [[ZPMockService sharedInstance] stub:@"POST" path:@"/api/ios/v3/login" file:@"login-valid.json"];
    [[ZPMockService sharedInstance] stub:@"GET" path:@"/api/ios/v3/jobs/3" file:@"empty-jobs.json"];
    [tester stubValidateTokenWithAdhocAndFetch];
    [tester stubValidUpload];
    
    [tester waitForViewWithAccessibilityLabel:@"Password"];
    [tester enterText:@"zipiddemo" intoViewWithAccessibilityLabel:@"Password"];
    [tester tapViewWithAccessibilityLabel:@"Sign in"];
    [tester waitForTimeInterval:2];
    
    // Tap upload again
    [tester waitForViewWithAccessibilityLabel:@"Upload report"];
    [tester tapViewWithAccessibilityLabel:@"Upload report"];
    
    // Confirm alert
    [tester waitForViewWithAccessibilityLabel:@"Ok"];
    [tester tapViewWithAccessibilityLabel:@"Ok"];

    // Back to client list
    [tester tapViewWithAccessibilityLabel:@"Clients"];
    [tester waitForViewWithAccessibilityLabel:@"Menu"];
}


@end
