//
//  ZPSurveyResponseSpec.m
//  ZipID
//
//  Created by Damien Hill on 19/08/2015.
//  Copyright (c) 2015 ZipID. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ZPSurveyResponse.h"

@interface ZPSurveyResponseSpec : XCTestCase

@property (nonatomic, retain) ZPSurveyResponse *surveyResponse;

@end


@implementation ZPSurveyResponseSpec

- (void)setUp {
    [super setUp];
    self.surveyResponse = [[ZPSurveyResponse alloc] init];
}

- (void)tearDown {
    self.surveyResponse = nil;
    [super tearDown];
}

- (void)testAddingAnIdentificationDocumentShouldIncreaseArrayCount {
    [self.surveyResponse.identificationDocumentsDictionary setObject:@"TestObject" forKey:@"TEST"];
    XCTAssertEqual(self.surveyResponse.identificationDocuments.count, 1);
}

- (void)testAddingAnAdditionalDocumentShouldIncreaseArrayCount {
    [self.surveyResponse.additionalDocumentsDictionary setObject:@"TestObject" forKey:@"TEST"];
    XCTAssertEqual(self.surveyResponse.additionalDocuments.count, 1);
}

@end
