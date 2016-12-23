//
//  ZPQuestionSet+LocalAccessors.m
//  ZipID
//
//  Created by Damien Hill on 2/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "ZPQuestionSet+LocalAccessors.h"
#import "ZPPersistentEndpoint.h"

@implementation ZPQuestionSet (LocalAccessors)

+ (NSArray *)findAll {

		NSDictionary *dictionary = [ZPPersistentEndpoint endpointWithName:@"questions"].response;
    
    NSMutableArray *mutableQuestionSets = [NSMutableArray array];
    for (id key in dictionary) {
        NSMutableDictionary *questionSetDictionary = [[dictionary objectForKey:key] mutableCopy];
        [questionSetDictionary setObject:key forKey:@"questionSetId"];
        ZPQuestionSet *questionSet = [[ZPQuestionSet alloc] initWithDictionary:questionSetDictionary];
        [mutableQuestionSets addObject:questionSet];
    }
    
    [mutableQuestionSets sortUsingComparator:^NSComparisonResult(ZPQuestionSet *questionSet1, ZPQuestionSet *questionSet2) {
        return [questionSet1.name compare:questionSet2.name];
    }];
    
    return [NSArray arrayWithArray:mutableQuestionSets];
}

+ (ZPQuestionSet *)findById:(NSString *)questionSetId
{
    ZPQuestionSet *questionSet = nil;
    NSArray *questionSets = [self findAll];
    for (ZPQuestionSet *aQuestionSet in questionSets) {
        if ([aQuestionSet.questionSetId isEqualToString:questionSetId]) {
            questionSet = aQuestionSet;
            break;            
        }
    }
    return questionSet;
}

+ (NSArray *)findMultipleById:(NSArray *)questionSetIds userSelectableOnly:(BOOL)userSelectableOnly {
  NSMutableArray *questionSetsMutable = [NSMutableArray array];
  for (NSString *questionSetId in questionSetIds) {
		ZPQuestionSet *questionSet = [ZPQuestionSet findById:questionSetId];
		if (questionSet) {
			if (!userSelectableOnly || (userSelectableOnly && questionSet.userSelectable)) {
				[questionSetsMutable addObject:questionSet];
			}
		}
  }
  return [NSArray arrayWithArray:questionSetsMutable];
}

+ (NSArray *)findMultipleById:(NSArray *)questionSetIds
{
  return [ZPQuestionSet findMultipleById:questionSetIds userSelectableOnly:NO];
}

@end
