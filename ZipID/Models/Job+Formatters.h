//
//  Job+Formatters.h
//  ZipID
//
//  Created by Damien Hill on 7/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "Job.h"

@interface Job (Formatters)

- (NSString *)jobStatusAsString;
- (NSString *)nameAsString;
- (NSString *)completedTimeAsString;
- (NSString *)completedDateAsString;
- (NSString *)completedDateAsDateTimeString;
- (NSDictionary *)dictionaryForMergeFields;
- (NSString *)requiredDocumentNamesAsString;
- (NSArray *)getRequiredDocumentsAsArray;
- (NSString *)questionsAsString;
- (NSString *)jobIdAsString;
- (NSString *)dateOfBirthAsString;

@end
