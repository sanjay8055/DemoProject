//
//  ZPVerificationType+LocalAccessors.m
//  ZipID
//
//  Created by Damien Hill on 4/05/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "ZPVerificationType+LocalAccessors.h"
#import "ZPPersistentEndpoint.h"
#import "ZPSubscriber.h"

@implementation ZPVerificationType (LocalAccessors)

+ (NSArray *)findAll {
	return [ZPVerificationType findAllOnlyUserSelectable:NO];
}

+ (NSArray *)findAllUserSelectable {
	return [ZPVerificationType findAllOnlyUserSelectable:YES];
}

+ (NSArray *)findByIds:(NSArray *)ids userSelectable:(BOOL)userSelectable {
    NSArray *verificationTypes = @[];
    if (userSelectable) {
        verificationTypes = [self findAllUserSelectable];
    } else {
        [self findAll];
    }
    NSMutableArray *matches = [NSMutableArray array];
    for (ZPVerificationType *aVerificationType in verificationTypes) {
        if ([ids containsObject:aVerificationType.verificationTypeId]) {
            [matches addObject:aVerificationType];
        }
    }
    return [NSArray arrayWithArray:matches];
}

+ (NSArray *)findAllOnlyUserSelectable:(BOOL)userSelectable {
	NSDictionary *dictionary = [ZPPersistentEndpoint endpointWithName:@"verification-types"].response;
	NSMutableArray *mutableVerificationTypes = [NSMutableArray array];
	for (id key in dictionary) {
        NSMutableDictionary *verificationTypeDictionary = [[dictionary objectForKey:key] mutableCopy];
        [verificationTypeDictionary setObject:key forKey:@"verificationTypeId"];
        ZPVerificationType *verificationType = [[ZPVerificationType alloc] initWithDictionary:verificationTypeDictionary];
        if (userSelectable && !verificationType.userSelectable) {
            continue;
        }
        [mutableVerificationTypes addObject:verificationType];
    }
	return [NSArray arrayWithArray:mutableVerificationTypes];
}

+ (ZPVerificationType *)findById:(NSString *)verificationTypeId
{
    ZPVerificationType *verificationType = nil;
    NSArray *verificationTypes = [self findAll];
    for (ZPVerificationType *aVerificationType in verificationTypes) {
        if ([aVerificationType.verificationTypeId isEqualToString:verificationTypeId]) {
            verificationType = aVerificationType;
            break;
        }
    }
    return verificationType;
}

@end
