//
//  ZPSubscriberSpec.m
//  ZipID
//
//  Created by Damien Hill on 19/08/2015.
//  Copyright (c) 2015 ZipID. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ZPSubscriber.h"

@interface ZPSubscriberSpec : XCTestCase

@property (nonatomic, retain) ZPSubscriber *subscriber;

@end


@implementation ZPSubscriberSpec

- (void)setUp {
    [super setUp];
    self.subscriber = [ZPSubscriber sharedInstance];
}

- (void)tearDown {
    self.subscriber = nil;
    [super tearDown];
}

- (void)testSubscriberCanBeSignedIn {
    self.subscriber.agentId = @"100300";
    self.subscriber = nil;
    ZPSubscriber *retreivedSubscriber = [ZPSubscriber sharedInstance];
    XCTAssertEqualObjects(retreivedSubscriber.agentId, @"100300");
}

- (void)testSubscriberCanBeSignedOut {
    self.subscriber.agentId = @"100300";
    [ZPSubscriber signOut];
    XCTAssertFalse([ZPSubscriber isSignedIn]);
}


@end
