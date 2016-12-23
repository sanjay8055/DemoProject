//
//  NSDictionary+Nillable.h
//  ZipID
//
//  Created by Richard S on 7/10/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Nillable)

- (id)validatedValueForKey:(NSString *)key;
- (void)setSafeObject:(id)value forKey:(NSString *)key;

@end
