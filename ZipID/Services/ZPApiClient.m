//
//  ZPApiClient.m
//  ZipID
//
//  Created by Damien Hill on 18/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "ZPApiClient.h"
#import "NSDictionary+QueryStringBuilder.h"
#import "ZPSubscriber.h"

@interface ZPApiClient ()

@property (nonatomic, copy) ApiProgressBlock progressBlock;
@property (nonatomic, retain) NSURLSessionUploadTask *uploadTask;
@property (nonatomic, retain) NSString *defaultUserAgent;
@end


@implementation ZPApiClient

@dynamic requestSerializer;

static ZPApiClient *_sharedInstance;

+ (ZPApiClient *) sharedInstance {
    NSString *baseUrl;
#if DEV
    if ([[[NSProcessInfo processInfo] arguments] containsObject:@"MOCK_HTTP_SERVER"]) {
        DebugLog(@"Use Mock Server");
        baseUrl = @"http://localhost:3002/api/ios/v3/";
    } else {
        baseUrl = @"https://localhost:3001/api/ios/v3/";
    }
#elif TEST
    baseUrl = @"https://test.zipid.com.au/api/ios/v3/";
#elif PROD
    baseUrl = @"https://zipid.com.au/api/ios/v3/";
#endif
    
#if !(DEV || TEST || PROD)
  #error "must specify which website to use DEV, TEST, PROD"
#endif
    
    if (_sharedInstance == nil) {
        _sharedInstance = [[ZPApiClient alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
    }
    return _sharedInstance;
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];

    DebugLog(@"configured with baseUrl %@", url);
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer = [[ZPAFHTTPRequestSerializer alloc] init];
        self.defaultUserAgent = [self.requestSerializer valueForHTTPHeaderField:@"User-Agent"];
       
        [self setAuthorizationHeader];
        [self setVersionInformationHeaders];
			
        #if DEV || TEST
        AFSecurityPolicy* securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        securityPolicy.allowInvalidCertificates = YES;
        securityPolicy.validatesDomainName = NO;
        self.securityPolicy = securityPolicy;
        DebugLog(@"Disable Cert check for Dev and test");
        #endif
    }
    return self;
}

- (void)get:(NSString *)path params:(NSDictionary *)params success:(ApiSuccessBlock)success failure:(ApiFailureBlock)failure
{
    [self setAuthorizationHeader];
    [self GET:path parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {

    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *response = (NSDictionary *)responseObject;
        success(response);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

- (void)post:(NSString *)path params:(NSDictionary *)params success:(ApiSuccessBlock)success failure:(ApiFailureBlock)failure
{
    [self setAuthorizationHeader];
    [self POST:path parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *response = (NSDictionary *)responseObject;
        success(response);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

- (void)post:(NSString *)path withFiles:(NSArray *)files params:(NSDictionary *)params success:(ApiSuccessBlock)success failure:(ApiFailureBlock)failure progress:(ApiProgressBlock)progress
{
    [self setAuthorizationHeader];
    
    DebugLog(@"POST with files: %@%@", self.baseURL, path);
    // Prepare temporary file to store the multipart request prior to sending it to the server due to a bug in NSURLSessionTask
    // See here for more info: https://github.com/AFNetworking/AFNetworking/issues/1398
    NSString* tmpFilename = [NSString stringWithFormat:@"%f", [NSDate timeIntervalSinceReferenceDate]];
    NSURL* tmpFileUrl = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:tmpFilename]];
    
    self.progressBlock = progress;
    
    // Create a multipart form request.
    NSMutableURLRequest *multipartRequest = [self.requestSerializer multipartFormRequestWithMethod:@"POST"
                                                                                         URLString:[NSString stringWithFormat:@"%@%@", self.baseURL, path]
                                                                                        parameters:params
                                                                         constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
                                             {
                                                 for (NSDictionary *file in files) {
                                                     NSString *fileName = (NSString *)[file objectForKey:@"fileName"];
                                                     NSString *mimeType = (NSString *)[file objectForKey:@"mimeType"];
                                                     NSString *paramName = (NSString *)[file objectForKey:@"paramName"];
                                                     NSString *filePath = (NSString *)[file objectForKey:@"filePath"];

                                                     NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
                                                     
                                                     [formData appendPartWithFileURL:fileUrl
                                                                                name:paramName
                                                                            fileName:fileName
                                                                            mimeType:mimeType
                                                                               error:nil];
                                                 }
                                             } error:nil];
    

    // Dump multipart request into the temporary file.
    [self.requestSerializer requestWithMultipartFormRequest:multipartRequest
                                writingStreamContentsToFile:tmpFileUrl
                                          completionHandler:^(NSError *error) {
                                              // Here note that we are submitting the initial multipart request. We are, however,
                                              // forcing the body stream to be read from the temporary file.
                                              self.uploadTask = [self uploadTaskWithStreamedRequest:multipartRequest progress:^(NSProgress * _Nonnull uploadProgress) {
                                                  
                                              } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                                                  // Cleanup: remove temporary file.
                                                  [[NSFileManager defaultManager] removeItemAtURL:tmpFileUrl error:nil];
                                                  
                                                  // Do something with the result.
                                                  if (error) {
                                                      DebugLog(@"Error: %@", error);
                                                      failure(error);
                                                  } else {
                                                      NSDictionary *responseDictionary = (NSDictionary *)responseObject;
                                                      if ([[responseDictionary objectForKey:@"success"] boolValue]) {
                                                          success(responseObject);
                                                      } else {
                                                          NSError *error = [NSError errorWithDomain:@"au.com.zipid.zipid" code:ZipErrorUnauthorized userInfo:nil];
                                                          failure(error);
                                                      }
                                                  }
                                              }];
                                              [self.uploadTask resume];
                                          }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    if ([keyPath isEqualToString:@"fractionCompleted"] && [object isKindOfClass:[NSProgress class]]) {
        NSProgress *progress = (NSProgress *)object;
        dispatch_async(dispatch_get_main_queue(),^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUploadProgress" object:nil userInfo:@{ @"job" : @"self.job.jobGUID", @"progress" : [NSNumber numberWithFloat:progress.fractionCompleted] }];
        });

    }
}

- (void)setAuthorizationHeader
{
	if ([ZPSubscriber sharedInstance].authToken) {
			[self.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [ZPSubscriber sharedInstance].authToken] forHTTPHeaderField:@"Authorization"];
	} else {
			[self.requestSerializer setValue:nil forHTTPHeaderField:@"Authorization"];
	}
}

- (void)setVersionInformationHeaders {
	
	NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	[self.requestSerializer setValue:version forHTTPHeaderField:@"App Version"];
	
	NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
	[self.requestSerializer setValue:build forHTTPHeaderField:@"App Build"];

    NSString *deviceName = [[UIDevice currentDevice] name];
    NSString *userName = [ZPSubscriber sharedInstance].agentUserName;
    NSString *agentId = [ZPSubscriber sharedInstance].agentId;

    NSString *deviceDetails = [NSString stringWithFormat:@"%@ (build:%@; deviceName:%@;)", self.defaultUserAgent, build, deviceName];
    
    NSString *newUserAgent = [NSString stringWithFormat:@"%@ userName:%@ businessCode:%@", deviceDetails, userName, agentId];
    
    [self.requestSerializer setValue:newUserAgent forHTTPHeaderField:@"User-Agent"];
    
    [self.requestSerializer setValue:deviceName forHTTPHeaderField:@"Device name"];
    
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    if (self.progressBlock && task == self.uploadTask) {
        DebugLog(@"Total upload size: %@", [NSByteCountFormatter stringFromByteCount:totalBytesExpectedToSend countStyle:NSByteCountFormatterCountStyleFile]);
        DebugLog(@"Total sent: %@", [NSByteCountFormatter stringFromByteCount:totalBytesSent countStyle:NSByteCountFormatterCountStyleFile]);
        NSProgress *progress = [NSProgress progressWithTotalUnitCount:totalBytesExpectedToSend];
        progress.completedUnitCount = totalBytesSent;
			if (self.progressBlock) {
        self.progressBlock(progress.fractionCompleted);
			}
    }
}

@end
