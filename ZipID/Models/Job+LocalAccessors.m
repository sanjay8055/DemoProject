//
//  Job+LocalAccessors.m
//  ZipID
//
//  Created by Damien Hill on 7/06/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "Job+LocalAccessors.h"
#import "ZPSubscriber.h"

@implementation Job (LocalAccessors)

+ (NSInteger)totalJobCount
{
    NSString *username = [ZPSubscriber sharedInstance].agentId;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"agentId == %@", username];
    return [Job MR_countOfEntitiesWithPredicate:predicate];
}

+ (NSArray *)findCompleted {
    return [self findCompletedSortedBy:JobsSortOrderDateCreated];
}

+ (NSArray *)findCompletedSortedBy:(JobsSortOrder)sortOrder {
    return [self findAllGroupedByStatus:JobStatusCompleted sortedBy:sortOrder];
}

+ (NSArray *)findInProgress {
    return [self findInProgressSortedBy:JobsSortOrderDateCreated];
}

+ (NSArray *)findInProgressSortedBy:(JobsSortOrder)sortOrder {
    return [self findAllGroupedByStatus:JobStatusReady sortedBy:sortOrder];
}

+ (NSArray *)findCompletedWithSearchString:(NSString *)searchString {
    return [self findCompletedWithSearchString:searchString sortedBy:JobsSortOrderDateCreated];
}

+ (NSArray *)findCompletedWithSearchString:(NSString *)searchString sortedBy:(JobsSortOrder)sortOrder {
	return [self findAllGroupedByStatus:JobStatusCompleted withSearchString:searchString sortedBy:sortOrder];
}

+ (NSArray *)findInProgressWithSearchString:(NSString *)searchString {
    return [self findInProgressWithSearchString:searchString sortedBy:JobsSortOrderDateCreated];
}

+ (NSArray *)findInProgressWithSearchString:(NSString *)searchString sortedBy:(JobsSortOrder)sortOrder {
    return [self findAllGroupedByStatus:JobStatusReady withSearchString:searchString sortedBy:sortOrder];
}

+ (NSArray *)findAllGroupedByStatus:(JobStatus)jobStatus withSearchString:(NSString *)searchString sortedBy:(JobsSortOrder)sortOrder {
	// Get jobs for current user

	NSMutableArray *predicateList = [NSMutableArray array];

	if (searchString) {
        NSPredicate *textSearch = [NSPredicate predicateWithFormat:@"(searchString CONTAINS[cd] %@)", searchString];
		[predicateList addObject:textSearch];
	}
    
	NSPredicate *jobSearch;
	NSString *username = [ZPSubscriber sharedInstance].agentId;
	BOOL testMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"testMode"];
	
	if (jobStatus == JobStatusCompleted) {
		jobSearch = [NSPredicate predicateWithFormat:@"(agentId == %@) AND (status == %u) AND (testMode == %@)", username, JobStatusCompleted, @(testMode)];
	} else {
		jobSearch = [NSPredicate predicateWithFormat:@"(agentId == %@) AND (status != %u) AND (testMode == %@)", username, JobStatusCompleted, @(testMode)];
	}
	[predicateList addObject:jobSearch];

	NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicateList];
    
    NSString *sortField = @"";
    switch (sortOrder) {
        case JobsSortOrderDateCreated:
            sortField = @"dateCreated";
            break;
            
        case JobsSortOrderFirstName:
            sortField = @"firstName";
            break;
            
        case JobsSortOrderLastName:
            sortField = @"lastName";
            break;
            
        default:
            sortField = @"dateCreated";
            break;
    }
    
	NSArray *jobs = [[Job MR_findAllSortedBy:sortField ascending:YES withPredicate:predicate] mutableCopy];   
    
    // ToDo: Remove this once all users are on new model version
  	BOOL isFetchJobsMigration = [[NSUserDefaults standardUserDefaults] objectForKey:@"fetchJobsMigration"] == nil;
    if (isFetchJobsMigration) {
        [self generateSearchStringsForBlanks:jobs];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"fetchJobsMigration"];
    }
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
    }];
    return [self groupJobs:jobs];
}

+ (void)generateSearchStringsForBlanks:(NSArray *)jobs
{
    for (Job *job in jobs) {
        if (!job.searchString) {
            [job generateSearchString];
        }
    }
}

+ (NSArray *)findAllGroupedByStatus:(JobStatus)jobStatus sortedBy:(JobsSortOrder)sortOrder {
	return [Job findAllGroupedByStatus:jobStatus withSearchString:nil sortedBy:sortOrder];
}

+ (NSArray *)groupJobs:(NSArray *)jobs {
	
    
    NSMutableArray *waitingJobs = [NSMutableArray array];
    NSMutableArray *waitingToUploadJobs = [NSMutableArray array];
    NSMutableArray *uploadInProgress = [NSMutableArray array];
    NSMutableArray *completedJobs = [NSMutableArray array];
    for (Job *job in jobs) {
        switch (job.jobStatusRaw) {
            case JobStatusCompleted:
                [completedJobs addObject:job];
                break;
            case JobStatusUploadInProgress:
                [uploadInProgress addObject:job];
                break;
            case JobStatusWaitingForUpload:
                [waitingToUploadJobs addObject:job];
                break;
            default:
                [waitingJobs addObject:job];
                break;
        }
    }
    
    // Sort
//    [waitingJobs sortUsingComparator:^NSComparisonResult(Job *job1, Job *job2) {
//        return [job2.dateCreated compare:job1.dateCreated];
//    }];

    [uploadInProgress sortUsingComparator:^NSComparisonResult(Job *job1, Job *job2) {
        return [job2.dateCompleted compare:job1.dateCompleted];
    }];

    [waitingToUploadJobs sortUsingComparator:^NSComparisonResult(Job *job1, Job *job2) {
        return [job2.dateCompleted compare:job1.dateCompleted];
    }];
    
    [completedJobs sortUsingComparator:^NSComparisonResult(Job *job1, Job *job2) {
        return [job2.dateCompleted compare:job1.dateCompleted];
    }];
    
    NSMutableArray *jobGroups = [NSMutableArray array];
    if (uploadInProgress.count > 0) {
        [jobGroups addObject:@{@"title": @"Upload in progress",
                               @"jobs": uploadInProgress}];
    }
    if (waitingToUploadJobs.count > 0) {
        [jobGroups addObject:@{@"title": @"Waiting to upload",
                               @"jobs": waitingToUploadJobs}];
    }
    if (waitingJobs.count > 0) {
        [jobGroups addObject:@{@"title": @"Awaiting verification",
                               @"jobs": waitingJobs}];
    }
    if (completedJobs.count > 0) {
        [jobGroups addObject:@{@"title": @"Completed jobs",
                               @"jobs": completedJobs}];
    }
    
    return [NSArray arrayWithArray:jobGroups];
}

@end
