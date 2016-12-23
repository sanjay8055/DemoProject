//
//  ZPApiClient+Methods.h
//  ZipID
//
//  Created by Damien Hill on 18/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "ZPApiClient.h"

typedef void(^SuccessBlock)(void);
typedef void(^FailureBlock)(NSError *error);
typedef void(^ProgressBlock)(float percentComplete);

@interface ZPApiClient (Methods)

- (void)checkVersionWithSuccess:(void(^)(NSString *versionNumber, NSURL *updateURL))success failure:(FailureBlock)failure;
- (void)loginWithUsername:(NSString *)username password:(NSString *)password success:(SuccessBlock)success failure:(FailureBlock)failure;
- (void)validateTokenWithSuccess:(SuccessBlock)success failure:(FailureBlock)failure;
- (void)uploadReport:(NSString *)reportFilePath withEncryptedReport:(NSString *)encryptedReportFilePath withKey:(NSString *)encryptedKeyFilePath  withIV:(NSString *)encryptedIVFilePath success:(SuccessBlock)success failure:(FailureBlock)failure progress:(ProgressBlock)progress;

@end
