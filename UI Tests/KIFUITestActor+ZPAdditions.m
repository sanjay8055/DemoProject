//
//  KIFUITestActor+ZPAdditions.m
//  ZipID
//
//  Created by Damien Hill on 5/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "KIFUITestActor+ZPAdditions.h"
#import "ZPAppResetService.h"


@implementation KIFUITestActor (ZPAdditions)

- (void)resetApp
{
    NSLog(@"resetting app");
    [[ZPAppResetService sharedInstance] resetApp];
}

- (void)resetAppViaUI
{
    [tester tapViewWithAccessibilityLabel:@"Menu"];
    [tester scrollViewWithAccessibilityIdentifier:@"Menu items" byFractionOfSizeHorizontal:0 vertical:-0.5];
    [tester waitForTimeInterval:2];
    [tester tapViewWithAccessibilityLabel:@"Remove all data and settings"];
    [tester waitForTimeInterval:1];
    [tester tapViewWithAccessibilityLabel:@"Remove"];
}


- (void) stubQuestionsAndVerificationTypes
{
    [[ZPMockService sharedInstance] stub:@"GET" path:@"/api/ios/v3/questions" file:@"questions.json"];
    [[ZPMockService sharedInstance] stub:@"GET" path:@"/api/ios/v3/verification-types" file:@"verification-types.json"];
}

- (void) stubTollJobs
{
    [[ZPMockService sharedInstance] stub:@"GET" path:@"/api/ios/v3/jobs/100524" file:@"toll-remote-job.json"];
}

- (void)login
{
    [self stubQuestionsAndVerificationTypes];
    
    [[ZPMockService sharedInstance] stub:@"POST" path:@"/api/ios/v3/login" file:@"login-valid.json"];
    [[ZPMockService sharedInstance] stub:@"GET" path:@"/api/ios/v3/jobs/3" file:@"empty-jobs.json"];
	
    [tester tapViewWithAccessibilityLabel:@"Sign in"];
    [tester enterText:@"3" intoViewWithAccessibilityLabel:@"ZipID Business Code"];
    [tester enterText:@"zipiddemo" intoViewWithAccessibilityLabel:@"Password"];
    [tester tapViewWithAccessibilityLabel:@"Submit"];
    [tester waitForTappableViewWithAccessibilityLabel:@"Menu"];
    [tester waitForTimeInterval:2];
   
    // To Do: Remove the empty jobs stub?
//    [OHHTTPStubs removeStub:stub];
}

- (void)tollLogin
{
    [self stubQuestionsAndVerificationTypes];
    [self stubTollJobs];
    
    [[ZPMockService sharedInstance] stub:@"POST" path:@"/api/ios/v3/login" file:@"login-valid-toll.json"];
    
    [tester tapViewWithAccessibilityLabel:@"Sign in"];
    [tester enterText:@"100524" intoViewWithAccessibilityLabel:@"ZipID Business Code"];
    [tester enterText:@"password" intoViewWithAccessibilityLabel:@"Password"];
    [tester tapViewWithAccessibilityLabel:@"Submit"];
    [tester waitForTappableViewWithAccessibilityLabel:@"Menu"];
    [tester waitForTimeInterval:2];
    
}

- (void)remoteJobLogin
{
    [self stubQuestionsAndVerificationTypes];
    
    [[ZPMockService sharedInstance] stub:@"POST" path:@"/api/ios/v3/login" file:@"login-valid-remote.json"];
    
    [tester tapViewWithAccessibilityLabel:@"Sign in"];
    [tester enterText:@"3" intoViewWithAccessibilityLabel:@"ZipID Business Code"];
    [tester enterText:@"zipiddemo" intoViewWithAccessibilityLabel:@"Password"];
    [tester tapViewWithAccessibilityLabel:@"Submit"];
    [tester waitForTappableViewWithAccessibilityLabel:@"Menu"];
    [tester waitForTimeInterval:2];
    
}


- (void)logout
{
    [tester tapViewWithAccessibilityLabel:@"Menu"];
    [tester tapViewWithAccessibilityLabel:@"Sign out"];
    [tester tapViewWithAccessibilityLabel:@"Sign out"];
    [tester waitForTappableViewWithAccessibilityLabel:@"Sign in"];
}

@end
