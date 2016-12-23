//
//  ZPMockService.m
//  ZipID
//
//  Created by Damien Hill on 29/10/2015.
//  Copyright © 2015 ZipID. All rights reserved.
//

#import "ZPMockService.h"
@import GCDWebServer;
//#import "GCDWebServerDataResponse.h"

@interface ZPMockService()

@property (nonatomic, retain) GCDWebServer *mockServer;

@end


@implementation ZPMockService

+ (id)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init
{
    self = [super init];
    if (self) {
        _mockServer = [[GCDWebServer alloc] init];
        [_mockServer startWithPort:3002 bonjourName:nil];
        NSLog(@"Mock server running at %@", _mockServer.serverURL);
    }
    return self;
}

- (id)getJSONObjectFromFile:(NSString *)fileName
{
    NSString *filePath = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:fileName];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
    NSError *error = nil;
    id JSONObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    return JSONObject;
}

- (void)stub:(NSString *)method path:(NSString *)path file:(NSString *)fileName
{
    [self stub:method path:path file:fileName statusCode:200];
}

- (void)stub:(NSString *)method path:(NSString *)path file:(NSString *)fileName statusCode:(NSInteger)statusCode
{
    __weak ZPMockService *weakSelf = self;
    [_mockServer addHandlerForMethod:method
                                path:path
                        requestClass:[GCDWebServerRequest class]
                        processBlock:^GCDWebServerResponse *(GCDWebServerRequest *request) {
                            id JSONObject = [weakSelf getJSONObjectFromFile:fileName];
                            GCDWebServerDataResponse *response = [GCDWebServerDataResponse responseWithJSONObject:JSONObject];
                            [response setContentType:@"application/json"];
                            [response setStatusCode:statusCode];
                            return response;
                        }];
}

- (void)removeAllStubs
{
    [_mockServer removeAllHandlers];
}

- (void)stubQuestionsAndVerificationTypes
{
    [self stub:@"GET" path:@"/api/ios/v3/questions" file:@"questions.json"];
    [self stub:@"GET" path:@"/api/ios/v3/verification-types" file:@"verification-types.json"];
}

@end
