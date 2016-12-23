//
//  ZPAFHTTPRequestSerializer.m
//  ZipID
//
//  Created by Richard S on 16/03/2015.
//  Copyright (c) 2015 ZipID. All rights reserved.
//

#import "ZPAFHTTPRequestSerializer.h"

@implementation ZPAFHTTPRequestSerializer

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
																 URLString:(NSString *)URLString
																parameters:(id)parameters
																		 error:(NSError *__autoreleasing *)error
{
	
    NSRange range = [URLString rangeOfString:@"?"];
    if (range.length != NSNotFound) {
        URLString = [URLString stringByAppendingString:@"?"];
    } else {
        URLString = [URLString stringByAppendingString:@"&"];
    }

	BOOL testMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"testMode"];
	NSString *urlString = [NSString stringWithFormat:@"%@testMode=%@", URLString, testMode ? @"true" : @"false"];
	return [super requestWithMethod:method URLString:urlString parameters:parameters error:error];
}

@end