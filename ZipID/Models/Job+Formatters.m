//
//  Job+Formatters.m
//  ZipID
//
//  Created by Damien Hill on 7/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "ZipID-Swift.h"
#import "Job+Formatters.h"
#import "ZPQuestionSet+LocalAccessors.h"
#import "ZPSubscriber.h"

@implementation Job (Formatters)

- (NSString *)jobStatusAsString
{
    switch (self.jobStatusRaw) {
        case JobStatusCompleted:
            return @"Verification complete";
            break;
        case JobStatusUploadInProgress:
            return @"Upload in Progress";
            break;
        case JobStatusReady:
            return @"Awaiting verification";
            break;
        case JobStatusWaiting:
            return @"Awaiting selection of documents";
            break;
        case JobStatusWaitingForUpload:
            return @"Waiting to upload";
            break;

    }
}

- (NSString *)nameAsString
{
	if (self.middleName.length > 0) {
		return [NSString stringWithFormat:@"%@ %@ %@", self.firstName, self.middleName, self.lastName];
	} else {
		return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
	}
}

- (NSString *)jobIdAsString {
	if (self.jobId.length) {
		return [NSString stringWithFormat:@"#%@", self.jobId];
	}
	return @"";
}

- (NSString *)completedTimeAsString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mma"];
    return [[dateFormatter stringFromDate:self.dateCompleted] lowercaseString];
}

- (NSString *)completedDateAsString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE d 'of' MMMM YYYY"];
    return [dateFormatter stringFromDate:self.dateCompleted];
}

- (NSString *)completedDateAsDateTimeString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    return [dateFormatter stringFromDate:self.dateCompleted];
}

- (NSString *)dateOfBirthAsString
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd"];
	return [dateFormatter stringFromDate:self.dateOfBirth];
}

- (NSString *)startDateAsString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE d 'of' MMMM YYYY"];
    return [dateFormatter stringFromDate:self.dateStarted];
}

- (NSDictionary *)dictionaryForMergeFields
{
    NSMutableDictionary *mergeFields = [NSMutableDictionary dictionary];
    
    if (self.nameAsString) {
        [mergeFields setObject:self.nameAsString forKey:@"clientFullName"];
    }
    if (self.firstName) {
        [mergeFields setObject:self.firstName forKey:@"clientFirstName"];
    }
    if ([self getRequiredDocumentsAsArray].count > 0) {
        [mergeFields setObject:[self getRequiredDocumentsAsArray] forKey:@"identificationDocuments"];
    }
    if ([self getRequiredDocumentsAsArray].count > 0) {
        [mergeFields setObject:[[self getRequiredDocumentsAsArray] componentsJoinedByString:@", "] forKey:@"identificationDocumentsString"];
    }
    if ([self startDateAsString]) {
        [mergeFields setObject:[self startDateAsString] forKey:@"startDate"];
    }
    if (self.agentName) {
        [mergeFields setObject:self.agentName forKey:@"agentName"];
    }
    if ([ZPSubscriber sharedInstance].account) {
        Account *account = [ZPSubscriber sharedInstance].account;
        [mergeFields setObject:account.address forKey:@"agentBusinessAddress"];
        [mergeFields setObject:account.name forKey:@"agentBusinessName"];
    }
    
    return [NSDictionary dictionaryWithDictionary:mergeFields];
}

- (NSString *)requiredDocumentNamesAsString {
	NSArray *docNames = [self getRequiredDocumentsAsArray];
	return [docNames componentsJoinedByString:@", "];
}

- (NSString *)questionsAsString {
	NSMutableArray *docNames = [NSMutableArray array];
	NSArray *questionSets = [ZPQuestionSet findMultipleById:self.selectedQuestionSets];
	for (ZPQuestionSet *questionSet in questionSets) {
		if (questionSet.questionSetId) {
			[docNames addObject:questionSet.questionSetId];
		}
	}
	return [docNames componentsJoinedByString:@","];
}

- (NSArray *)getRequiredDocumentsAsArray {
	NSMutableArray *docNames = [NSMutableArray array];
	NSArray *questionSets = [ZPQuestionSet findMultipleById:self.selectedQuestionSets];
	for (ZPQuestionSet *questionSet in questionSets) {
		if (questionSet.name && questionSet.userSelectable) {
			[docNames addObject:questionSet.name];
		}
	}
	return docNames;
}

@end
