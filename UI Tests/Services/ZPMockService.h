//
//  ZPMockService.h
//  ZipID
//
//  Created by Damien Hill on 29/10/2015.
//  Copyright © 2015 ZipID. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZPMockService : NSObject

+ (id)sharedInstance;
- (void)stub:(NSString *)method path:(NSString *)path file:(NSString *)fileName;
- (void)stub:(NSString *)method path:(NSString *)path file:(NSString *)fileName statusCode:(NSInteger)statusCode;
- (void)removeAllStubs;

// Convenience helpers
- (void)stubQuestionsAndVerificationTypes;

@end
