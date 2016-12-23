//
//  ZPVerificationType+LocalAccessors.h
//  ZipID
//
//  Created by Damien Hill on 4/05/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "ZPVerificationType.h"

@interface ZPVerificationType (LocalAccessors)

+ (NSArray *)findAll;
+ (NSArray *)findAllUserSelectable;
+ (NSArray *)findByIds:(NSArray *)ids userSelectable:(BOOL)userSelectable;
+ (ZPVerificationType *)findById:(NSString *)verificationTypeId;

@end
