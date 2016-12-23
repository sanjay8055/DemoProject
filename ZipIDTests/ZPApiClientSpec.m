//
//  ZPApiClientSpec.m
//  ZipID
//
//  Created by Damien Hill on 19/08/2015.
//  Copyright (c) 2015 ZipID. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <OHHTTPStubs/OHPathHelpers.h>
#import "ZPApiClient+Methods.h"
#import "ZPSubscriber.h"

@interface ZPApiClientSpec : XCTestCase

@property (nonatomic, retain) ZPSubscriber *subscriber;

@end


@implementation ZPApiClientSpec

- (void)setUp {
    [super setUp];
    self.subscriber = [ZPSubscriber initWithDictionary:@{@"authToken": @"authToken"}];
}

- (void)tearDown {
    [super tearDown];
    self.subscriber = nil;
}

//fails in runloop. looks like the ZPSubscriber, MUST have a non nil authToken
- (void)testApiValidateTokenSuccessShouldCallSuccessBlock {
    XCTestExpectation *successExpectation = [self expectationWithDescription:@"success"];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.path isEqualToString:@"/api/ios/v3/validate-token"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSString* fixture = OHPathForFile(@"token-valid-with-adhoc-fetch.json", self.class);
        return [OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                statusCode:200
                                                   headers:@{@"Content-Type":@"application/json"}];
    }];
    

    [[ZPApiClient sharedInstance] validateTokenWithSuccess:^{
        [successExpectation fulfill];
    } failure: nil];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) { }];
}

- (void)testApiValidateAnInvalidTokenShouldCallFailureBlock {
    XCTestExpectation *failurexpectation = [self expectationWithDescription:@"failure"];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.path isEqualToString:@"/api/ios/v3/validate-token"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSString* fixture = OHPathForFile(@"token-invalid.json", self.class);
        return [OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                statusCode:200
                                                   headers:@{@"Content-Type":@"application/json"}];
    }];
    
    [[ZPApiClient sharedInstance] validateTokenWithSuccess:nil
                                                   failure: ^(NSError *error) {
                                                       [failurexpectation fulfill];
                                                   }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) { }];
}

@end
