//
//  ZPJobsTests.m
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

@interface ZPJobsTests : XCTestCase

@end

@implementation ZPJobsTests

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

- (void)testThatItCanSearchForValidJobs {
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
    
    [tester enterText:@"Wumpus" intoViewWithAccessibilityLabel:@"Search for a job"];
    
    cell = [tester waitForCellAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1] inTableViewWithAccessibilityIdentifier:@"Client list"];
    
    name = cell.textLabel.text;
    XCTAssertEqualObjects(name, @"Wumpus M Kowski");
    
    [tester clearTextFromAndThenEnterText:@"Mewmew Robot" intoViewWithAccessibilityLabel:@"Search for a job"];
    
    UITableView *tableView;
    [tester waitForAccessibilityElement:nil view:&tableView withIdentifier:@"Client list" tappable:NO];
    
    XCTAssertEqual(tableView.numberOfSections, 1);

    
//    UILabel *emptyTitleLabel;
//    [tester waitForAccessibilityElement:nil view:&emptyTitleLabel withIdentifier:@"emptyTitle" tappable:NO];
//    
//    XCTAssertEqualObjects(emptyTitleLabel.text, @"No jobs found");
    
    // Hacky way to dismiss keyboard so test can pass in iOS7
//    [tester tapViewWithAccessibilityLabel:@"New job"];
//    [tester tapViewWithAccessibilityLabel:@"Cancel"];
    
}


@end
