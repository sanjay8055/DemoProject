//
//  NSDictionary+Nillable.m
//  ZipID
//
//  Created by Richard S on 7/10/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "NSDictionary+Nillable.h"

@implementation NSDictionary (Nillable)

- (id)validatedValueForKey:(NSString *)key {
	id value = [self valueForKey:key];
	if (value == [NSNull null]) {
		value = nil;
	}
	return value;
}

- (void)setSafeObject:(id)value forKey:(NSString *)key {
	if ([self isKindOfClass:NSMutableDictionary.class]) {
		NSMutableDictionary *dict = (NSMutableDictionary *)self;
		if (value == nil) {
			[dict setObject:[NSNull null] forKey:key];
		} else {
			[dict setObject:value forKey:key];
		}
	}
}

@end
