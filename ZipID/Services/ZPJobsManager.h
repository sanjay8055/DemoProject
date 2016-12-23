//
//  ZPJobsManager.h
//  ZipID
//
//  Created by Richard S on 7/10/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZPJobsManager : NSObject

@property (atomic, assign) UIBackgroundTaskIdentifier bgTask;

+ (instancetype)sharedInstance;
- (void)fetchAndProcessJobsWithCompletion:(void(^)(BOOL success))completion;

@end
