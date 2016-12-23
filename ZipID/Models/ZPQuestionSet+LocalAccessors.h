//
//  ZPQuestionSet+LocalAccessors.h
//  ZipID
//
//  Created by Damien Hill on 2/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "ZPQuestionSet.h"

@interface ZPQuestionSet (LocalAccessors)

+ (NSArray *)findAll;
+ (ZPQuestionSet *)findById:(NSString *)questionSetId;
+ (NSArray *)findMultipleById:(NSArray *)questionSetIds;
+ (NSArray *)findMultipleById:(NSArray *)questionSetIds userSelectableOnly:(BOOL)userSelectableOnly;

@end
