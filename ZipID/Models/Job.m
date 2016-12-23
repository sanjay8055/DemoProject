//
//  Job.m
//  ZipID
//
//  Created by Damien Hill on 7/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "ZipID-Swift.h"
#import "Job.h"
#import "ZPQuestionSet.h"
#import "ZPQuestionSet+LocalAccessors.h"
#import "ZPQuestion.h"
#import "ZPVerificationType+LocalAccessors.h"
#import "NSDictionary+Nillable.h"
#import "Job+Formatters.h"
#import "ZPApiClient+Methods.h"
#import "ZPApiClient.h"
#import "ZPStringHelper.h"

@implementation Job

// Job
@dynamic jobId;
@dynamic jobGUID;
@dynamic agentId;
@dynamic agentName;
@dynamic dateStarted;
@dynamic dateCompleted;
@dynamic dateCreated;
@dynamic status;
@dynamic expiryDateTime;
@dynamic bookingDateTime;
@dynamic agentForBusinessCode;
@dynamic questionsString;
@dynamic clientReference;
@dynamic testMode;
@dynamic practice;

// Person
@dynamic firstName;
@dynamic gender;
@dynamic lastName;
@dynamic middleName;
@dynamic dateOfBirth;
@dynamic email;
@dynamic phone;


// Survey
@dynamic verificationType;
@dynamic surveyType;

// Geodata
@dynamic hasGeodata;
@dynamic geoLat;
@dynamic geoLng;


@dynamic searchString;
@dynamic appointmentSuburb;

@synthesize questions = _questions;
@synthesize selectedQuestionSets = _selectedQuestionSets;
@synthesize verificationTypeObj = _verificationTypeObj;
@synthesize hasSelectedDocuments = _hasSelectedDocuments;



- (void)populateWithDictionary:(NSDictionary *)dict {
	self.jobId = [dict validatedValueForKey:@"jobId"];
	self.agentName = [dict validatedValueForKey:@"agentName"];
	self.agentId = [dict validatedValueForKey:@"agentId"];
	self.firstName = [dict validatedValueForKey:@"firstName"];
	self.middleName = [dict validatedValueForKey:@"middleName"];
	self.lastName = [dict validatedValueForKey:@"lastName"];
  	self.phone = [dict validatedValueForKey:@"phone"];
   	self.email = [dict validatedValueForKey:@"email"];
	self.gender = [dict validatedValueForKey:@"gender"];
	self.genderRaw = (Gender)[self.gender integerValue];
	self.expiryDateTime = @([[dict validatedValueForKey:@"expiryUnix"] integerValue]);
	self.bookingDateTime = @([[dict validatedValueForKey:@"bookingDateTime"] integerValue]);
	self.selectedQuestionSets = [dict validatedValueForKey:@"questions"];
	self.questionsString = [self.selectedQuestionSets componentsJoinedByString:@","];
	self.verificationType = [dict validatedValueForKey:@"verificationType"];
	self.status = [dict validatedValueForKey:@"status"];
	self.searchString = [dict validatedValueForKey:@"searchString"];
    self.appointmentSuburb = [dict validatedValueForKey:@"appointmentSuburb"];
	self.clientReference = [dict validatedValueForKey:@"clientReference"];
	self.agentForBusinessCode = [dict validatedValueForKey:@"agentForBusinessCode"];
	self.testMode = [[dict validatedValueForKey:@"testMode"] boolValue];
    self.practice = [[dict validatedValueForKey:@"practice"] boolValue];

    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    self.dateOfBirth = [df dateFromString:[dict validatedValueForKey:@"dateOfBirth"]];
}

- (void)awakeFromInsert {
	[super awakeFromInsert];
	self.jobGUID = [[NSUUID UUID] UUIDString];
	self.dateCreated = [NSDate new];
	self.jobStatusRaw = JobStatusWaiting;
	self.hasGeodata = NO;
}

#pragma mark - Job status
- (JobStatus)jobStatusRaw
{
    if ([[UploadManager sharedInstance] inProgress:self.jobGUID]) {
        return JobStatusUploadInProgress;
    } else {
        return (JobStatus)[self.status intValue];
    }
}

- (void)setJobStatusRaw:(JobStatus)jobStatus
{
    [self setStatus:[NSNumber numberWithInt:jobStatus]];
}


+ (NSSet *)keyPathsForValuesAffectingJobStatusRaw
{
    return [NSSet setWithObject:@"jobStatus"];
}

#pragma mark - Gender
- (Gender)genderRaw
{
    return (Gender)[[self gender] intValue];
}

- (void)setGenderRaw:(Gender)gender
{
    [self setGender:[NSNumber numberWithInt:gender]];
}

+ (NSSet *)keyPathsForValuesAffectingGenderRaw
{
    return [NSSet setWithObject:@"gender"];
}

#pragma mark - GeoData
- (void)setGeoDataWithLocation:(CLLocation *)location
{
    if (location) {
        self.geoLat = location.coordinate.latitude;
        self.geoLng = location.coordinate.longitude;
        self.hasGeodata = YES;
        DebugLog(@"setGeoLocation: %6f, %6f", location.coordinate.latitude, location.coordinate.longitude);
    }
}

- (ZPVerificationType *)verificationTypeObj {
	if (!_verificationTypeObj) {
		_verificationTypeObj = [ZPVerificationType findById:self.verificationType];
	}
	return _verificationTypeObj;
}

- (void)setVerificationTypeObj:(ZPVerificationType *)verificationTypeObj {
	_verificationTypeObj = verificationTypeObj;
	self.verificationType = verificationTypeObj.verificationTypeId;
}

#pragma mark - Survey
- (NSArray *)selectedQuestionSets {
	if (!_selectedQuestionSets) {
		if (self.questionsString) {
            self.selectedQuestionSets = [self.questionsString componentsSeparatedByString:@","];
		}
	}
	return _selectedQuestionSets;
}

- (void)setSelectedQuestionSets:(NSArray *)selectedQuestionSets {

	self.hasSelectedDocuments = NO;
	self.questions = nil;
	_selectedQuestionSets = nil;

	NSArray *questionSets;
	if (!self.jobId) { // Adhoc Job
		questionSets = [ZPQuestionSet findMultipleById:self.verificationTypeObj.questionSets];
	} else {
		// Use only the questions that have been provided to us
		questionSets = [ZPQuestionSet findMultipleById:selectedQuestionSets];
	}
	
	NSMutableArray *includedSets = [NSMutableArray array];
	NSMutableArray *selectedSets = [NSMutableArray array];
	for (ZPQuestionSet *set in questionSets) {
		if (!set.userSelectable || [selectedQuestionSets containsObject:set.questionSetId]) {
			
			if (set.userSelectable) {
				self.hasSelectedDocuments = YES;
			}
			
			[selectedSets addObject:set.questionSetId];
			// This goes through all the question sets and gets the questions out into a flattened array structure
			includedSets = [[includedSets arrayByAddingObjectsFromArray:set.questions] mutableCopy];
		}
	}
	self.questions = includedSets;
	_selectedQuestionSets = [NSArray arrayWithArray:selectedSets];
	self.questionsString = [self questionsAsString];
}

- (NSArray *)questions {
	if (!_questions) {
		NSArray *questionSets = [self.questionsString componentsSeparatedByString:@","];
		self.selectedQuestionSets = questionSets;
	}
	return _questions;
}

+ (NSSet *)keyPathsForValuesAffectingRequiredDocuments
{
    return [NSSet setWithObject:@"requiredDocuments"];
}

- (NSArray *)sortRequiredDocuments:(NSArray *)requiredDocuments
{
    // TODO: Get sort order from reference data
    NSArray *sortOrder = @[@"APP",
                           @"FPV",
                           @"FPN",
                           @"ADL",
                           @"POA",
                           @"BTH",
                           @"CTZ",
                           @"DSC",
                           @"MED",
                           @"CTL",
                           @"VAC",
                           @"MRG",
                           @"NAM"];
    
    NSArray *sortedDocuments = [requiredDocuments sortedArrayUsingComparator:^NSComparisonResult(NSString *doc1Id, NSString *doc2Id) {
        int doc1Index = 0;
        for (NSString *docId in sortOrder) {
            if ([doc1Id isEqualToString:docId]) {
                break;
            }
            doc1Index++;
        }
        
        int doc2Index = 0;
        for (NSString *docId in sortOrder) {
            if ([doc2Id isEqualToString:docId]) {
                break;
            }
            doc2Index++;
        }
        return [[NSNumber numberWithInt:doc1Index] compare:[NSNumber numberWithInt:doc2Index]];
    }];
    
    return sortedDocuments;
}

- (void)generateSearchString
{
    NSString *newSearchString = [NSString stringWithFormat:@"%@, %@, %@, %@",
                                 self.clientReference,
                                 self.firstName,
                                 self.middleName,
                                 self.lastName];
    if (![newSearchString isEqualToString:self.searchString]) {
        self.searchString = newSearchString;
    }
}

- (void)willSave
{
    if (!self.jobId) { // Don't generate for fetched jobs
        [self generateSearchString];
    }
}

- (UIImage *)getClientPhoto
{
    NSString *filePath = [[ZPStringHelper applicationDocumentsDirectory].path stringByAppendingPathComponent:[NSString stringWithFormat:@"avatar-%@.jpg", self.jobGUID]];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    UIImage *avatar = [UIImage imageWithData:data];
    
    if (!avatar) {
        if (self.genderRaw == GenderFemale) {
            avatar = [UIImage imageNamed:@"ClientIconFemaleLargeVerified"];
        } else {
            avatar = [UIImage imageNamed:@"ClientIconMaleLargeVerified"];
        }
    }
    
    return avatar;
}

@end
