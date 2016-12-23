//
//  AFNetworking+ZPPersistentEndpoint.m
//  ZipID
//
//  Created by Richard S on 6/10/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "ZPApiClient.h"
#import "ZPPersistentEndpoint.h"

@interface ZPPersistentEndpoint()

@property (nonatomic, retain) NSMutableArray *completions;
@property (nonatomic, retain) NSMutableArray *failures;
@property (nonatomic, strong) NSDictionary *endpoints;

@end

@implementation ZPPersistentEndpoint

+ (instancetype)sharedInstance {
	static ZPPersistentEndpoint *_sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedInstance = [[ZPPersistentEndpoint alloc] init];
		_sharedInstance.completions = [NSMutableArray array];
		_sharedInstance.failures = [NSMutableArray array];
	});
	return _sharedInstance;
}

+ (void)subscribeToCompletion:(void(^)())completion {
	[[ZPPersistentEndpoint sharedInstance].completions addObject:completion];
}

+ (void)subscribeToCompletion:(void(^)(id responseObject))completion andFailure:(void(^)())failure {
	[[ZPPersistentEndpoint sharedInstance].completions addObject:completion];
	[[ZPPersistentEndpoint sharedInstance].failures addObject:failure];
}

+ (void)persistDefaults:(NSDictionary *)defaults forFilePath:(NSString *)filePath {
	[defaults writeToFile:filePath atomically:YES];
}

+ (id)getDefaultsForEndpointFromFile:(NSString *)filename {
	NSData *defaults = [NSData dataWithContentsOfFile:[ZPPersistentEndpoint defaultsFileLocationForFile:filename]];
	NSPropertyListFormat format;
	NSError *error = nil;
    
    id contents = [NSPropertyListSerialization propertyListWithData:defaults options:NSPropertyListMutableContainersAndLeaves format:&format error:&error];    
	return contents;
}

- (void)setEndPointsToLoad:(NSArray *)endPointsToLoad {
	NSMutableArray *mutableArray = [NSMutableArray array];
	NSMutableDictionary *mutableEndpoints = [NSMutableDictionary dictionary];

	for (NSDictionary *endpointDict in endPointsToLoad) {
		ZPPersistentEndpointToLoad *endPoint = [[ZPPersistentEndpointToLoad alloc] initWithDictionary:endpointDict];
		[mutableArray addObject:endPoint];
		mutableEndpoints[endPoint.file] = endPoint;
	}
	_endPointsToLoad = [NSArray arrayWithArray:mutableArray];
	self.endpoints = [NSDictionary dictionaryWithDictionary:mutableEndpoints];
	[[ZPPersistentEndpoint sharedInstance] copyBundleFileIfRequired];
	
	for (ZPPersistentEndpointToLoad *endpoint in self.endPointsToLoad) {
		endpoint.response = [ZPPersistentEndpoint getDefaultsForEndpointFromFile:endpoint.file];
	}
}

- (void)copyBundleFileIfRequired {
	if (self.endPointsToLoad) {
		for (ZPPersistentEndpointToLoad *endpoint in self.endPointsToLoad) {
			NSString *defaultsPath = [ZPPersistentEndpoint defaultsFileLocationForFile:endpoint.file];
			NSFileManager *fileManager = [NSFileManager defaultManager];
			NSString *defaultsFile = [[NSBundle mainBundle] pathForResource:endpoint.file ofType:@"json"];
			
			if ([fileManager fileExistsAtPath:defaultsPath] == NO &&
				[fileManager fileExistsAtPath:defaultsFile]) {
				NSData *JSONData = [NSData dataWithContentsOfFile:defaultsFile options:NSDataReadingMappedIfSafe error:nil];
				NSDictionary *defaults = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableContainers error:nil];
				[ZPPersistentEndpoint persistDefaults:defaults forFilePath:defaultsPath];
			}
		}
	}
}

+ (NSString *)defaultsFileLocationForFile:(NSString *)filename {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	filename = [NSString stringWithFormat:@"%@.plist", filename];
	return [documentsDirectory stringByAppendingPathComponent:filename];
}

+ (void)refreshDefaults {
	[ZPPersistentEndpoint refreshDefaultsWithCompletion:nil];
}

+ (void)refreshDefaultsWithCompletion:(void (^)())completion {
	for (ZPPersistentEndpointToLoad *endpointToLoad in [ZPPersistentEndpoint sharedInstance].endPointsToLoad) {
		if (endpointToLoad.path) {
            [[ZPPersistentEndpoint sharedInstance] refreshDefaultsForEndpoint:endpointToLoad withCompletion:completion andFailure: ^() {DebugLog(@"failure, relying on defaults");}];
		}
	}
}

- (void)refreshDefaultsForEndpoint:(ZPPersistentEndpointToLoad *)endpointToLoad withCompletion:(void(^)(id responseObject))completion andFailure:(void(^)())failure {

	[[ZPApiClient sharedInstance] get:endpointToLoad.path params:nil success:^(id response) {
	
		if (response) {
			endpointToLoad.response = response;
			[ZPPersistentEndpoint persistDefaults:response forFilePath:[ZPPersistentEndpoint defaultsFileLocationForFile:endpointToLoad.file]];
		}
		if (completion) {
			completion(response);
		}
		if ([[ZPPersistentEndpoint sharedInstance].completions count]) {
			for (void (^completionBlock)() in [ZPPersistentEndpoint sharedInstance].completions) {
				completionBlock();
			}
			[[ZPPersistentEndpoint sharedInstance].completions removeAllObjects];
		}
        [[ZPPersistentEndpoint sharedInstance].failures removeAllObjects];
	} failure:^(NSError *error) {
		if (failure) {
			failure();
		}
		if ([[ZPPersistentEndpoint sharedInstance].failures count]) {
			for (void (^failureBlock)() in [ZPPersistentEndpoint sharedInstance].failures) {
				failureBlock();
			}
			[[ZPPersistentEndpoint sharedInstance].failures removeAllObjects];
		}
		[[ZPPersistentEndpoint sharedInstance].completions removeAllObjects];
	}];
}

+ (ZPPersistentEndpointToLoad *)endpointWithName:(NSString *)endpointName {
	return [ZPPersistentEndpoint sharedInstance].endpoints[endpointName];
}

@end

@implementation ZPPersistentEndpointToLoad

- (id)initWithDictionary:(NSDictionary *)dictionary {
	if (self = [super init]) {
		self.file = dictionary[@"file"];
		self.path = dictionary[@"path"];
	}
	return self;
}

@end