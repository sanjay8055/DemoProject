//
//  Job+LocalAccessors.h
//  ZipID
//
//  Created by Damien Hill on 7/06/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "Job.h"

typedef NS_ENUM(NSInteger, JobsSortOrder) {
    JobsSortOrderFirstName,
    JobsSortOrderLastName,
    JobsSortOrderDateCreated
};

@interface Job (LocalAccessors)

+ (NSInteger)totalJobCount;

+ (NSArray *)findCompleted;
+ (NSArray *)findCompletedSortedBy:(JobsSortOrder)sortOrder;

+ (NSArray *)findInProgress;
+ (NSArray *)findInProgressSortedBy:(JobsSortOrder)sortOrder;

//search
+ (NSArray *)findCompletedWithSearchString:(NSString *)searchString;
+ (NSArray *)findCompletedWithSearchString:(NSString *)searchString sortedBy:(JobsSortOrder)sortOrder;

+ (NSArray *)findInProgressWithSearchString:(NSString *)searchString;
+ (NSArray *)findInProgressWithSearchString:(NSString *)searchString sortedBy:(JobsSortOrder)sortOrder;

@end
