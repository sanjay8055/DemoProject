//
//  ZPApiClient+Methods.m
//  ZipID
//
//  Created by Damien Hill on 18/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "ZipID-Swift.h"
#import "ZPApiClient+Methods.h"
#import "ZPSubscriber.h"
#import "NSDictionary+Nillable.h"

@implementation ZPApiClient (Methods)

NSString *const ZipErrorDomain = @"au.com.zipid.zipid";

#pragma mark - Version check

- (void)checkVersionWithSuccess:(void(^)(NSString *versionNumber, NSURL *updateURL))success failure:(FailureBlock)failure
{
    #ifdef PROD
        #if !ENTERPRISE
            NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
            [self fetchAppStoreURLFromiTunes:^(NSURL *updateURL, NSString *versionNumber) {
                if ([versionNumber compare:currentVersion options:NSNumericSearch] == NSOrderedDescending) {
                    success(versionNumber, updateURL);
                } else {
                    failure(nil);
                }
            } failure:^{
                failure(nil);
            }];
        #endif
    #endif
}

- (void)fetchAppStoreURLFromiTunes:(void(^)(NSURL *trackURL, NSString *versionNumber))success failure:(void(^)(void))failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    dispatch_async(dispatch_get_main_queue(), ^() {
        NSString *url = [NSString stringWithFormat:@"https://itunes.apple.com/au/lookup?bundleId=%@", [[NSBundle mainBundle] bundleIdentifier]];
        [manager GET:url parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            if ([responseObject isKindOfClass:NSDictionary.class]) {
                
                NSArray *results = (NSArray *)responseObject[@"results"];
                
                if ([results count] == 0) {
                    failure();
                    return;
                }
                
                NSString *trackURL = results.firstObject[@"trackViewUrl"];
                NSString *version = results.firstObject[@"version"];
                
                if (![trackURL isEqualToString:@""] && ![version isEqualToString:@""]) {
                    NSURL *url = [NSURL URLWithString:trackURL];
                    success(url, version);
                } else {
                    failure();
                }
            }
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            failure();
        }];
    });
}

//- (void)checkEnterpriseVersionWithSuccess:(void (^)(NSString *versionNumber, NSURL *updateURL))success failure:(FailureBlock)failure {
//	NSString *url = @"https://www.zipid.com.au/manifest.plist?enterprise";
//	
//	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//	manager.responseSerializer = [AFPropertyListResponseSerializer serializer];
//	manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"text/xml"]];
//	
//    [manager GET:url
//      parameters:nil
//         success:^(AFHTTPRequestOperation *operation, id responseObject) {
//             if ([responseObject isKindOfClass:NSDictionary.class]) {
//                 NSDictionary *item = ((NSArray *)responseObject[@"items"]).firstObject;
//                 NSString *newVersionNumber = item[@"metadata"][@"bundle-version"];
//                 
//                 NSURL *url = [NSURL URLWithString:@"https://www.zipid.com.au/ios/enterprise/update"];
//                 success(newVersionNumber, url);
//             }
//         }
//         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//             NSString *message = [error.userInfo objectForKey:@"message"] ? [error.userInfo objectForKey:@"message"] : @"Invalid version";
//             NSDictionary *errorDetail = @{ NSLocalizedDescriptionKey: message };
//             NSError *zipError = [NSError errorWithDomain:ZipErrorDomain code:110 userInfo:errorDetail];
//             failure(zipError);
//         }];
//}


#pragma mark - Authentication

- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
                  success:(SuccessBlock)success
                  failure:(FailureBlock)failure
{
    NSDictionary *params = @{ @"username": username,
                              @"password": password };
    
    [self post:@"login" params:params success:^(NSDictionary *response) {
        BOOL loginSuccess = [[response objectForKey:@"success"] boolValue];
        NSString *authToken = [response objectForKey:@"authToken"];
        if (loginSuccess && authToken) {
            ZPSubscriber *subscriber = [ZPSubscriber initWithDictionary:response];
            
            //TODO: client side verificaiton
            NSDictionary* payload = [self decodeJwt:authToken];
            
            // if ManagedUserLogin is supported, use the businessCode
            if ([payload objectForKey:@"businessCode"]) {
                NSString *businessCode = [NSString stringWithFormat:@"%@", [payload objectForKey:@"businessCode"]];
                subscriber.agentId = businessCode;
                subscriber.agentUserName = username;
                if ([payload objectForKey:@"given_name"]) {
                    subscriber.agentFirstName = [payload objectForKey:@"given_name"];
                }
                if ([payload objectForKey:@"family_name"]) {
                    subscriber.agentLastName = [payload objectForKey:@"family_name"];
                }

            } else {
                //todo: agentId should be numeric userId
                subscriber.agentId = username;
                subscriber.agentUserName = username;
            }
            [self setVersionInformationHeaders];
            
            #if !DEBUG
            [CrashlyticsKit setUserIdentifier:[ZPSubscriber sharedInstance].agentUserName];
            #endif
            
            NSNumber *userID = [payload objectForKey:@"userId"];
            
            NSDictionary *userDict = [response objectForKey:@"user"];
            NSMutableDictionary *userDictSanitized = [NSMutableDictionary dictionary];
            for (NSString * key in [userDict allKeys]) {
                if (![[userDict objectForKey:key] isKindOfClass:[NSNull class]] &&
                    ![[userDict objectForKey:key] isKindOfClass:[NSDictionary class]] &&
                    ![[userDict objectForKey:key] isKindOfClass:[NSArray class]]) {
                    [userDictSanitized setObject:[userDict objectForKey:key] forKey:key];
                }
            }
            
            NSDictionary *accountDict = [response objectForKey:@"account"];
            NSMutableDictionary *accountDictSanitized = [NSMutableDictionary dictionary];
            for (NSString * key in [accountDict allKeys]) {
                if (![[accountDict objectForKey:key] isKindOfClass:[NSNull class]] &&
                    ![[accountDict objectForKey:key] isKindOfClass:[NSDictionary class]] &&
                    ![[accountDict objectForKey:key] isKindOfClass:[NSArray class]]) {
                    [accountDictSanitized setObject:[accountDict objectForKey:key] forKey:key];
                }
            }
            #ifdef ENTERPRISE
            [userDictSanitized setObject:@"Enterprise" forKey:@"App Distribution"];
            [userDictSanitized setObject:[[UIDevice currentDevice] name] forKey:@"Device Name"];
            #else
            [userDictSanitized setObject:@"App Store" forKey:@"App Distribution"];
            #endif
            
            // Ensure these fields don't go to analytics
            [userDictSanitized removeObjectForKey:@"firstName"];
            [userDictSanitized removeObjectForKey:@"lastName"];
            [userDictSanitized removeObjectForKey:@"email"];
            [userDictSanitized removeObjectForKey:@"phone"];
            [userDictSanitized removeObjectForKey:@"username"];
            
            [[SEGAnalytics sharedAnalytics] identify:[userID stringValue]
                                              traits:userDictSanitized];
            [[SEGAnalytics sharedAnalytics] group:[NSString stringWithFormat:@"%d", (int)subscriber.account.id]
                                           traits:accountDictSanitized];
            [[SEGAnalytics sharedAnalytics] track:@"Signed in"];

            NSDictionary *toggles = [response objectForKey:@"toggles"];
            if (toggles) {
                DebugLog(@"toggles: %@", toggles);
            }
            success();
        } else {
            NSDictionary *errorDetail = @{ NSLocalizedDescriptionKey: NSLocalizedString(@"AUTHENTICATION_FAILED_MESSAGE", nil) };
            NSError *error = [NSError errorWithDomain:ZipErrorDomain code:ZipErrorUnauthorized userInfo:errorDetail];
            failure(error);
        }
    } failure:^(NSError *error) {
        failure(error);
    }];
}

//TODO: this can be validated client side only now, expiry is not an idle timeout, it is a max time before re-auth is required.
- (void)validateTokenWithSuccess:(SuccessBlock)success
                         failure:(FailureBlock)failure
{
    NSDictionary *params = @{@"authToken": [ZPSubscriber sharedInstance].authToken};
    [self post:@"validate-token" params:params success:^(NSDictionary *response) {
        
        BOOL valid = [[response objectForKey:@"valid"] boolValue];
        if (valid) {
            NSDictionary *toggles = [response objectForKey:@"toggles"];
            
            if (toggles) {
                [[ZPSubscriber sharedInstance] setTogglesFromDictionary:[response validatedValueForKey:@"toggles"]];
            }
            [[ZPSubscriber sharedInstance] setPermissionsFromDictionary:[response validatedValueForKey:@"permissions"]];
            success();
        } else {
            NSDictionary *errorDetail = @{ NSLocalizedDescriptionKey: @"Invalid auth token" };
            NSError *error = [NSError errorWithDomain:ZipErrorDomain code:ZipErrorUnauthorized userInfo:errorDetail];
            DebugLog(@"Couldn't validate auth token: %@", [error localizedDescription]);
            if (failure) {
                failure(error);
            }
        }
    } failure:^(NSError *error) {
        DebugLog(@"Couldn't validate auth token: %@", [error localizedDescription]);
        if (failure) {
            failure(error); // may of been network drop out
        }
    }];
}


#pragma mark - Upload

- (void)uploadReport:(NSString *)reportFilePath
 withEncryptedReport:(NSString *)encryptedReportFilePath
             withKey:(NSString *)encryptedKeyFilePath
             withIV:(NSString *)encryptedIVFilePath
             success:(SuccessBlock)success
             failure:(FailureBlock)failure
            progress:(ProgressBlock)progress
{
    
    NSDictionary *params = @{
                             @"responseId": [[reportFilePath lastPathComponent] stringByDeletingPathExtension]
                             };

//    NSDictionary *reportFile = @{ @"fileName": [reportFilePath lastPathComponent],
//                                  @"filePath": reportFilePath,
//                                  @"mimeType": @"application/zip",
//                                  @"paramName": @"report"
//                                };
    NSDictionary *encryptedKeyFile = @{ @"fileName": [encryptedKeyFilePath lastPathComponent],
                               @"filePath": encryptedKeyFilePath,
                               @"mimeType": @"application/octet-stream",
                               @"paramName": @"key"
                               };

    NSDictionary *encryptedIVFile = @{ @"fileName": [encryptedIVFilePath lastPathComponent],
                                        @"filePath": encryptedIVFilePath,
                                        @"mimeType": @"application/octet-stream",
                                        @"paramName": @"iv"
                                        };
    
    NSDictionary *encryptedReportFile = @{ @"fileName": [encryptedReportFilePath lastPathComponent],
                               @"filePath": encryptedReportFilePath,
                               @"mimeType": @"application/octet-stream",
                               @"paramName": @"encryptedReport"
                               };
    
    NSArray *files = @[ encryptedKeyFile, encryptedIVFile, encryptedReportFile ];
    
    [self post:@"upload" withFiles:files params:params success:^(NSDictionary *response) {        
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSError *error = [[NSError alloc] init];

        [fileManager removeItemAtPath:reportFilePath error:&error];
        [fileManager removeItemAtPath:encryptedKeyFilePath error:&error];
        [fileManager removeItemAtPath:encryptedIVFilePath error:&error];
        [fileManager removeItemAtPath:encryptedReportFilePath error:&error];
        success();
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    } progress:^(float percentComplete) {
        if (progress) {
            progress(percentComplete);
        }
    }];
}

-(NSDictionary *) decodeJwt: (NSString *) jwt {
    NSArray *segments = [jwt componentsSeparatedByString:@"."];
    if (segments.count != 3) { // Handle tests
        return @{};
    }
    
    NSString *base64String = [segments objectAtIndex: 1];
    
    int requiredLength = (int)(4 * ceil((float)[base64String length] / 4.0));
    int nbrPaddings = requiredLength - (int)[base64String length];
    
    if (nbrPaddings > 0) {
        NSString *padding =
        [[NSString string] stringByPaddingToLength:nbrPaddings
                                        withString:@"=" startingAtIndex:0];
        base64String = [base64String stringByAppendingString:padding];
    }
    
    base64String = [base64String stringByReplacingOccurrencesOfString:@"-" withString:@"+"];
    base64String = [base64String stringByReplacingOccurrencesOfString:@"_" withString:@"/"];
    
    NSData *decodedData =
    [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    NSString *decodedString =
    [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    
    NSDictionary *jsonDictionary =
    [NSJSONSerialization JSONObjectWithData:[decodedString
                                             dataUsingEncoding:NSUTF8StringEncoding]
                                    options:0 error:nil];
    return jsonDictionary;
}

@end
