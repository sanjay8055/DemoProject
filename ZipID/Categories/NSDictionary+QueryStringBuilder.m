//
//  NSDictionary+QueryStringBuilder.m
//  ZipID
//
//  Created by Damien Hill on 18/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "NSDictionary+QueryStringBuilder.h"

static NSString * escapeString(NSString *unencodedString)
{
    NSString *string = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                      (CFStringRef)unencodedString,
                                                                      NULL,
                                                                      (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                      kCFStringEncodingUTF8));
    return string;
    
}

@implementation NSDictionary (QueryStringBuilder)

- (NSString *)queryString
{
    NSMutableString *queryString = nil;
    NSArray *keys = [self allKeys];
    
    if ([keys count] > 0) {
        for (id key in keys) {
            id value = [self objectForKey:key];
            if (nil == queryString) {
                queryString = [[NSMutableString alloc] init];
                [queryString appendFormat:@"?"];
            } else {
                [queryString appendFormat:@"&"];
            }
            
            if (nil != key && nil != value) {
                [queryString appendFormat:@"%@=%@", escapeString(key), escapeString(value)];
            } else if (nil != key) {
                [queryString appendFormat:@"%@", escapeString(key)];
            }
        }
    }
    
    return queryString;
}

@end
