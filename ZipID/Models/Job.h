//
//  Job.h
//  ZipID
//
//  Created by Damien Hill on 7/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "ZPVerificationType.h"

typedef enum {
    JobStatusWaiting,
    JobStatusReady,
    JobStatusWaitingForUpload,
    JobStatusCompleted,
    JobStatusUploadInProgress
} JobStatus;

typedef enum {
    GenderNotSpecified,
    GenderFemale,
    GenderMale
} Gender;

@interface Job : NSManagedObject

@property (nonatomic, strong) NSString *jobId;
@property (nonatomic, strong) NSString *jobGUID;
@property (nonatomic, strong) NSString *verificationType;
@property (nonatomic, strong) NSString *agentName;
@property (nonatomic, strong) NSString *agentId;
@property (nonatomic, strong) NSNumber *expiryDateTime;
@property (nonatomic, strong) NSNumber *bookingDateTime;
@property (nonatomic, strong) NSDate *dateStarted;
@property (nonatomic, strong) NSDate *dateCompleted;
@property (nonatomic, strong) NSDate *dateCreated;
@property (nonatomic, assign) NSNumber *status;
@property (nonatomic, assign) BOOL testMode;
@property (nonatomic, assign) BOOL practice;

@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSNumber *gender;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) NSString *middleName;
@property (nonatomic, retain) NSDate *dateOfBirth;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *phone;

@property (nonatomic, strong) NSString *clientReference;
@property (nonatomic, strong) NSString *agentForBusinessCode;

@property (nonatomic, strong) NSString *searchString;
@property (nonatomic, strong) NSString *appointmentSuburb;

@property (nonatomic, assign) Gender genderRaw;
@property (nonatomic, assign) JobStatus jobStatusRaw;

@property (nonatomic, retain) NSString *surveyType;

@property (nonatomic, assign) BOOL hasGeodata;
@property (nonatomic, assign) BOOL hasSelectedDocuments;
@property (nonatomic, assign) double geoLat;
@property (nonatomic, assign) double geoLng;

@property (nonatomic, strong) NSArray *questions;
@property (nonatomic, strong) NSString *questionsString;
@property (nonatomic, strong) NSArray *selectedQuestionSets;
@property (nonatomic, strong) ZPVerificationType *verificationTypeObj; //todo clean this up

- (void)setGeoDataWithLocation:(CLLocation *)location;
- (void)populateWithDictionary:(NSDictionary *)dict;
- (void)generateSearchString;
- (UIImage *)getClientPhoto;

@end
