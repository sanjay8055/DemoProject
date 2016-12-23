//
//  KIFUITestActor+ZPStubs.m
//  ZipID
//
//  Created by Richard S on 22/10/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "KIFUITestActor+ZPStubs.h"

@implementation KIFUITestActor (ZPStubs)

- (void)stubEmptyJobs
{
    [[ZPMockService sharedInstance] stub:@"GET" path:@"/api/ios/v3/jobs/3" file:@"empty-jobs.json"];
}

- (void)stubARemoteJob
{
    [[ZPMockService sharedInstance] stub:@"GET" path:@"/api/ios/v3/jobs/3" file:@"remote-job.json"];
}

- (void)stubValidateTokenWithAdhoc
{
    [[ZPMockService sharedInstance] stub:@"POST" path:@"/api/ios/v3/validate-token" file:@"token-valid-with-adhoc.json"];
}

- (void)stubValidateTokenWithAdhocAndFetch
{
    [[ZPMockService sharedInstance] stub:@"POST" path:@"/api/ios/v3/validate-token" file:@"token-valid-with-adhoc-fetch.json"];
}

- (void)stubValidateTokenWithFetch
{
    [[ZPMockService sharedInstance] stub:@"POST" path:@"/api/ios/v3/validate-token" file:@"token-valid-with-fetch.json"];
}

- (void)stubFailedValidateToken
{
    [[ZPMockService sharedInstance] stub:@"POST" path:@"/api/ios/v3/validate-token" file:@"token-invalid.json"];
}

- (void)stubValidUpload
{
    [[ZPMockService sharedInstance] stub:@"POST" path:@"/api/ios/v3/upload" file:@"upload-valid.json"];
}

@end
