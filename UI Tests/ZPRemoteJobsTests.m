//
//  ZPRemoteJobsTests.m
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

@interface ZPRemoteJobsTests : XCTestCase

@end

@implementation ZPRemoteJobsTests

- (void)setUp {
    [super setUp];
    [tester stubValidateTokenWithFetch];
    [tester stubEmptyJobs];
    
    [tester tapViewWithAccessibilityLabel:@"Skip"];
    [tester remoteJobLogin];
}

- (void)tearDown {
    [[ZPMockService sharedInstance] removeAllStubs];
    [tester logout];
    [tester resetApp];
    [super tearDown];
}

- (void)testLoadingRemoteJobsAndNavigatingThroughTheVerificationProcess {
    [[ZPMockService sharedInstance] removeAllStubs];
    
    [tester stubValidUpload];
    [tester stubValidateTokenWithFetch];
    [tester stubARemoteJob];
    
    [tester tapViewWithAccessibilityLabel:@"Refresh jobs" traits:UIAccessibilityTraitButton];
    
    UITableViewCell *practiceCell = [tester waitForCellAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1] inTableViewWithAccessibilityIdentifier:@"Client list"];
    UITableViewCell *cell = [tester waitForCellAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:1] inTableViewWithAccessibilityIdentifier:@"Client list"];
    
    NSString *practiceName = practiceCell.textLabel.text;
    NSString *name = cell.textLabel.text;
    XCTAssertEqualObjects(practiceName, @"Thomas Adam Anderson");
    XCTAssertEqualObjects(name, @"Wumpus M Kowski");
    
    [tester tapRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:1] inTableViewWithAccessibilityIdentifier:@"Client list"];
    
    [tester tapViewWithAccessibilityLabel:@"Begin verification"];
    
    // Agent list
    [tester tapViewWithAccessibilityLabel:@"Add verifier"];
    [tester enterText:@"John" intoViewWithAccessibilityLabel:@"First name"];
    [tester enterText:@"Smith" intoViewWithAccessibilityLabel:@"Last name"];
    [tester tapViewWithAccessibilityLabel:@"Done"];
    [tester tapRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] inTableViewWithAccessibilityIdentifier:@"Verifier list"];
    [tester tapViewWithAccessibilityLabel:@"Next"];
    
    // PEXA info
    [tester tapViewWithAccessibilityLabel:@"Next"];
    
    // 5 point check
    [tester tapViewWithAccessibilityLabel:@"Next"];
    
    // Passport
    [tester tapViewWithAccessibilityLabel:@"Camera"];
    [tester tapViewWithAccessibilityLabel:@"Next"];
    
    [tester tapViewWithAccessibilityLabel:@"Camera"];
    [tester tapViewWithAccessibilityLabel:@"Next"];
    
    // Proof of Age Card
    [tester tapViewWithAccessibilityLabel:@"Camera"];
    [tester tapViewWithAccessibilityLabel:@"Next"];
    
    // Additional documents
    [tester tapViewWithAccessibilityLabel:@"Camera"];
    [tester tapViewWithAccessibilityLabel:@"Next"];
    
    // Client Photo
    [tester tapViewWithAccessibilityLabel:@"Camera"];
    [tester tapViewWithAccessibilityLabel:@"Next"];
    
    // Client Signature Card (PEXA)
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
    
    [tester tapViewWithAccessibilityLabel:@"In progress"];
    [tester tapViewWithAccessibilityLabel:@"Completed"];
    
    // Upload report
    cell = [tester waitForCellAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1] inTableViewWithAccessibilityIdentifier:@"Client list"];
    
    name = cell.textLabel.text;
    XCTAssertEqualObjects(name, @"Wumpus Kowski");
}

- (void)testFetchedJobsShouldBeInProgressAndNotInComplete {
    [[ZPMockService sharedInstance] removeAllStubs];
    
    [tester stubValidUpload];
    [tester stubValidateTokenWithFetch];
    [tester stubARemoteJob];
    
    [tester tapViewWithAccessibilityLabel:@"Refresh jobs" traits:UIAccessibilityTraitButton];

    [tester waitForTimeInterval:3];
    [tester tapViewWithAccessibilityLabel:@"Completed"];
    
    UILabel *emptyTitleLabel;
    [tester waitForAccessibilityElement:nil view:&emptyTitleLabel withIdentifier:@"emptyTitle" tappable:NO];
    
    XCTAssertEqualObjects(emptyTitleLabel.text, @"No completed jobs");
}

@end
