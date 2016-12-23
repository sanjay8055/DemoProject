//
//  ZPApiClient.h
//  ZipID
//
//  Created by Damien Hill on 18/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

@import AFNetworking.AFHTTPSessionManager;
#import "ZPAFHTTPRequestSerializer.h"

typedef void(^ApiProgressBlock)(float percentComplete);
typedef void(^ApiSuccessBlock)(NSDictionary *response);
typedef void(^ApiFailureBlock)(NSError *error);

typedef NS_ENUM(NSInteger, ZipError) {
    ZipErrorNone,
    ZipErrorNetwork,
    ZipErrorUnauthorized = 401,
    ZipErrorBadRequest
};

@interface ZPApiClient : AFHTTPSessionManager

@property (nonatomic, strong) ZPAFHTTPRequestSerializer <AFURLRequestSerialization> *requestSerializer;
@property (nonatomic, strong) NSString *userAgent;

+ (ZPApiClient *)sharedInstance;

- (void)setVersionInformationHeaders;

- (void)get:(NSString *)path params:(NSDictionary *)params success:(ApiSuccessBlock)success failure:(ApiFailureBlock)failure;
- (void)post:(NSString *)path params:(NSDictionary *)params success:(ApiSuccessBlock)success failure:(ApiFailureBlock)failure;
- (void)post:(NSString *)path withFiles:(NSArray *)files params:(NSDictionary *)params success:(ApiSuccessBlock)success failure:(ApiFailureBlock)failure progress:(ApiProgressBlock)progress;

@end
