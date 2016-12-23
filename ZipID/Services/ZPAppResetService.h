//
//  ZPAppResetService.h
//  ZipID
//
//  Created by Damien Hill on 11/06/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ResetSuccessBlock)();
typedef void(^ResetFailureBlock)(NSError *error);

@interface ZPAppResetService : NSObject

+ (ZPAppResetService *)sharedInstance;
- (void)resetApp;
- (void)resetApp:(ResetSuccessBlock)successBlock failure:(ResetFailureBlock)failureBlock;

@end
