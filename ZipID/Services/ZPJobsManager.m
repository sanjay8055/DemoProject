//
//  ZPJobsManager.m
//  ZipID
//
//  Created by Richard S on 7/10/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "ZPJobsManager.h"
#import "ZPApiClient+Methods.h"
#import "Job.h"
#import "ZPSubscriber.h"

@implementation ZPJobsManager

// Singleton because if we want to make this into a background queue
// We should be able to upload existing jobs up online without worrying
// if the parent owner is alive or not.
+ (instancetype)sharedInstance {
	static id sharedInstance = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
        DebugLog(@"creating a JobsManager instance of %@", sharedInstance);
	});

	return sharedInstance;
}

- (id)init {
    self.bgTask = UIBackgroundTaskInvalid;
    return self;
}

- (void)cleanUpExpiredJobs {
	NSPredicate *expiryDateWaiting = [NSPredicate predicateWithFormat:@"(expiryDateTime < %@) AND (status IN %@) AND (jobId.length > 0)",
														 @([[NSDate date] timeIntervalSince1970]),
														 @[@(JobStatusReady), @(JobStatusWaiting), @(JobStatusCompleted)]];
	[Job MR_deleteAllMatchingPredicate:expiryDateWaiting];

}

- (void)fetchAndProcessJobsWithCompletion:(void(^)(BOOL success))completion {
	// If someone hangs up while we're trying to save then lets tell the app
	// to perform the outstanding work in the backgroun
    if (self.bgTask != UIBackgroundTaskInvalid) {
        DebugLog(@"backgroundTask might be already running : %lu", (unsigned long)self.bgTask);
    } else  {
    
        __block UIApplication *application = [UIApplication sharedApplication];
        __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
            [application endBackgroundTask:self.bgTask];
            self.bgTask = UIBackgroundTaskInvalid;
        }];
        self.bgTask = bgTask;
        
        //dispatch, else it will be blocking the main thread.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self fetchJobsWithCompletion:^(NSArray *jobs) {
                if (jobs) {
                    if ([jobs count] < 1) {
                        DebugLog(@"No Jobs?");
                    }
                    
                    for (NSDictionary *jobDict in jobs) {					
                        Job *job = [Job MR_findFirstByAttribute:@"jobId" withValue:jobDict[@"jobId"]];
                        if (job && [job.status integerValue] != JobStatusReady) {
                            continue;
                        } else if (!job) {
                            job = [Job MR_createEntity];
                        }
                        
                        //Update Jobs, always, or if they have been modified, even if they are completed?
                        [job populateWithDictionary:jobDict];
                        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
                    }
                }
                
                [self cleanUpExpiredJobs];

                BOOL hasJobs = jobs ? YES : NO;
                completion(hasJobs);

                //this bgTask, is nil or something
                [application endBackgroundTask:self.bgTask];
                self.bgTask = UIBackgroundTaskInvalid;
            }];
        });
    }
}

- (void)fetchJobsWithCompletion:(void(^)(NSArray *jobs))completion {
	NSString *path = [NSString stringWithFormat:@"jobs/%@", [ZPSubscriber sharedInstance].agentId];
	[[ZPApiClient sharedInstance] get:path params:nil success:^(id response) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"jobsUpdatedDate"];
        if ([response isKindOfClass:NSArray.class]) {
			completion(response);
			return;
		}
		
		completion(nil);
		
	} failure:^(NSError *error) {
        DebugLog(@"fetchJobs failed");
		completion(@[]);
	}];
}

@end