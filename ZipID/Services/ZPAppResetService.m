//
//  ZPAppResetService.m
//  ZipID
//
//  Created by Damien Hill on 11/06/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "ZPAppResetService.h"
#import "Job.h"
#import "Agent.h"

@implementation ZPAppResetService

static ZPAppResetService *_sharedInstance;

+ (ZPAppResetService *) sharedInstance {
    if (_sharedInstance == nil) {
        _sharedInstance = [[ZPAppResetService alloc] init];
    }
    return _sharedInstance;
}

- (void)resetApp
{
    [self resetApp:nil failure:nil];
}

- (void)resetApp:(ResetSuccessBlock)successBlock failure:(ResetFailureBlock)failureBlock
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didSignOut" object:nil];
    
    [[SEGAnalytics sharedAnalytics] reset];
    
    // Reset NSUserDefaults
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Delete data from file system
    [self deleteAllUserDocuments];
    
    [Job MR_truncateAll];
    [Agent MR_truncateAll];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            if (successBlock) successBlock();
            // In memory objects handled by notification
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didResetAppState" object:self];
        } else {
            if (failureBlock) failureBlock(error);
        }
    }];
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)deleteAllUserDocuments
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *directoryContents = [fileMgr contentsOfDirectoryAtPath:[self applicationDocumentsDirectory].path error:&error];
    if (error == nil) {
        for (NSString *path in directoryContents) {
            NSString *fullPath = [[self applicationDocumentsDirectory].path stringByAppendingPathComponent:path];
            BOOL removeSuccess = [fileMgr removeItemAtPath:fullPath error:&error];
            if (!removeSuccess) {
                // Todo: Error handling
            }
        }
    } else {
        // Todo: Error handling
    }
}

@end
