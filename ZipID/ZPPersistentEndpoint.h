//
//  AFNetworking+ZPPersistentEndpoint.h
//  ZipID
//
//  Created by Richard S on 6/10/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

@interface ZPPersistentEndpointToLoad : NSObject
	@property (atomic, strong) NSString *file;
	@property (atomic, strong) NSString *path;
	@property (atomic, strong) id response;

	- (id)initWithDictionary:(NSDictionary *)dictionary;
@end

@interface ZPPersistentEndpoint : NSObject

@property (nonatomic, strong) NSArray *endPointsToLoad;

+ (instancetype)sharedInstance;

// Refreshments
+ (void)refreshDefaults;
+ (void)refreshDefaultsWithCompletion:(void(^)())completion;
+ (void)subscribeToCompletion:(void(^)())completion;
+ (void)subscribeToCompletion:(void(^)(id responseObject))completion andFailure:(void(^)())failure;

// Getters
+ (ZPPersistentEndpointToLoad *)endpointWithName:(NSString *)endpointName;


@end