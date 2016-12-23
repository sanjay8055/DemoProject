//
//  KIFUITestActor+ZPStubs.h
//  ZipID
//
//  Created by Richard S on 22/10/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "KIFUITestActor.h"

@interface KIFUITestActor (ZPStubs)

- (void)stubEmptyJobs;
- (void)stubARemoteJob;
- (void)stubValidateTokenWithAdhoc;
- (void)stubValidateTokenWithAdhocAndFetch;
- (void)stubValidateTokenWithFetch;
- (void)stubFailedValidateToken;
- (void)stubValidUpload;

@end
