//
//  ZPSubscriber.h
//  ZipID
//
//  Created by Damien Hill on 15/06/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ToggleName.h"
#import "PermissionName.h"

// Forward declaration for swift class
@class Account;

@interface ZPSubscriber: NSObject

@property (nonatomic, strong) NSString *agentId;
@property (nonatomic, strong) NSString *agentUserName;
@property (nonatomic, strong) NSString *lastUsedUsername;
@property (nonatomic, strong) NSString *agentFirstName;
@property (nonatomic, strong) NSString *agentLastName;
@property (nonatomic, strong, readonly) NSString *authToken;
@property (nonatomic, strong, readonly) NSArray *allowedVerfificationTypes;
@property (nonatomic, assign) BOOL rememberUsername;
@property (nonatomic, retain) NSArray *brokerFor;
@property (nonatomic, retain) Account *account;

+ (instancetype)sharedInstance;
- (id)initFromDefaults;
+ (id)initWithDictionary:(NSDictionary *)dictionary;

+ (void)signOut;
+ (BOOL)isSignedIn;

- (void)setTogglesFromDictionary:(NSDictionary *)dictionary;
+ (BOOL)isFeatureEnabled:(ToggleName)name;

- (void)setPermissionsFromDictionary:(NSDictionary *)dictionary;
+ (BOOL)hasPermission:(PermissionName)name;

@end
