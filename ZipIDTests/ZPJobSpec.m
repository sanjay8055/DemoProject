//
//  ZPJobSpec.m
//  ZipID
//
//  Created by Damien Hill on 19/08/2015.
//  Copyright (c) 2015 ZipID. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Job.h"
#import "Job+Formatters.h"
#import "ZPSubscriber.h"
#import "ZPVerificationType.h"
#import "ZPVerificationType+LocalAccessors.h"
#import "ZPPersistentEndpoint.h"
#import "ZPQuestionSet.h"
#import "ZPQuestionSet+LocalAccessors.h"

@interface ZPJobSpec : XCTestCase

@property (nonatomic, retain) Job *job;

@end


@implementation ZPJobSpec

- (void)setUp {
    [super setUp];
    NSArray *endpoints = @[
                           @{@"path": @"questions", @"file": @"questions"},
                           @{@"path": @"verification-types", @"file": @"verification-types"}
                           ];
    [ZPPersistentEndpoint sharedInstance].endPointsToLoad = endpoints;
    [[ZPSubscriber sharedInstance] setPermissionsFromDictionary:@{@"verificationTypes": @[@"PEXA"]}];

    [MagicalRecord setDefaultModelFromClass:[self class]];
    [MagicalRecord setupCoreDataStackWithInMemoryStore];
    self.job = [Job MR_createEntity];
}

- (void)tearDown {
    [self.job MR_deleteEntity];
    self.job = nil;
    [MagicalRecord cleanUp];
    [super tearDown];
}


- (void)testVerificationTypesShouldMatchObjects {
    ZPVerificationType *verificationObj = [ZPVerificationType findById:@"PEXA"];
    self.job.verificationTypeObj = verificationObj;
    XCTAssertEqualObjects(self.job.verificationType, verificationObj.verificationTypeId);
}

- (void)testShouldReturnEmptyQuestionsIfQuestionStringIsEmpty {
    self.job.verificationTypeObj = nil;
    XCTAssertEqual(self.job.questions.count, 0);
}

- (void)testNewJobHasRandomGUIIDWithLengthOf36Characters {
    XCTAssertEqual(self.job.jobGUID.length, 36);
}

- (void)testNewJobDefaultStatusOfWaiting {
    XCTAssertEqual(self.job.jobStatusRaw, JobStatusWaiting);
}

- (void)testPersonNameShouldEqualTheOneSupplied {
    self.job.firstName = @"John";
    self.job.middleName = @"David";
    self.job.lastName = @"Woo";
    XCTAssertEqualObjects(self.job.nameAsString, @"John David Woo");
}

- (void)testPersonsGenderShouldEqualTheOneSupplied {
    self.job.genderRaw = GenderMale;
    XCTAssertEqual(self.job.genderRaw, GenderMale);
}


// TO DO: Not sure why these were disabled in previous specta/expetca implementation?
- (void)DISABLED_testVerificationTypesShouldBeReadFromStringLazily {
    self.job.verificationType = @"PEXA";
    XCTAssertEqualObjects(self.job.verificationTypeObj.name, @"PEXA Subscriber");
}

- (void)DISABLED_testShouldGetQuestionsIfQuestionStringIsEmptyButVerificationTypeIsKnown {
    self.job.verificationTypeObj = nil;
    self.job.verificationType = @"PEXA";
    NSInteger count = 0;
    for (NSString *qsString in [ZPVerificationType findById:@"PEXA"].questionSets) {
        ZPQuestionSet *qs = [ZPQuestionSet findById:qsString];
        if (!qs.userSelectable) {
            count += [qs.questions count];
        }
    }
    XCTAssertEqual(self.job.questions.count, count);
}

@end
