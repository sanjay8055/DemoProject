//
//  ZPSurveyResponse.m
//  ZipID
//
//  Created by Damien Hill on 3/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "ZPSurveyResponse.h"
#import "Job+Formatters.h"
#import "ZPTextResponse.h"
#import "NSDictionary+Nillable.h"

@implementation ZPSurveyResponse

- (id)init
{
    self = [super init];
    if (self) {
        self.identificationDocumentsDictionary = [NSMutableDictionary dictionary];
        self.additionalDocumentsDictionary = [NSMutableDictionary dictionary];
        self.textResponsesDictionary = [NSMutableDictionary dictionary];
        self.additionalStepsResponsesDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSArray *)identificationDocuments
{
    NSArray *allKeys = [self.identificationDocumentsDictionary allKeys];
    NSArray *sortedKeys = [allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    
    NSMutableArray *identificationDocuments = [NSMutableArray array];
    for (NSString *key in sortedKeys) {
        ZPImageResponse *imageResponse = self.identificationDocumentsDictionary[key];
        [identificationDocuments addObject:imageResponse];
    }
    return identificationDocuments;
}

- (NSArray *)additionalDocuments
{
    NSArray *allKeys = [self.additionalDocumentsDictionary allKeys];
    NSArray *sortedKeys = [allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    
    NSMutableArray *additionalDocuments = [NSMutableArray array];
    for (NSString *key in sortedKeys) {
        ZPImageResponse *imageResponse = self.additionalDocumentsDictionary[key];
        [additionalDocuments addObject:imageResponse];
    }
    return additionalDocuments;
}

- (NSData *)buildReportModel {
	@try {
		NSMutableDictionary *reportDictionary = [NSMutableDictionary dictionary];

		if (self.job.nameAsString) {
			[reportDictionary setSafeObject:self.job.nameAsString forKey:@"clientName"];
			[reportDictionary setSafeObject:self.job.firstName forKey:@"firstName"];
			if (self.job.middleName) {
				[reportDictionary setSafeObject:self.job.middleName forKey:@"middleName"];
			}
			[reportDictionary setSafeObject:self.job.lastName forKey:@"lastName"];
            [reportDictionary setSafeObject:self.job.dateOfBirth forKey:@"dateOfBirth"];
		}
		[reportDictionary setSafeObject:self.job.agentName forKey:@"agentName"];
		[reportDictionary setSafeObject:self.job.agentId forKey:@"agentId"];
        [reportDictionary setSafeObject:self.job.agentId forKey:@"subscriberCode"];
		[reportDictionary setSafeObject:self.job.agentForBusinessCode forKey:@"agentForBusinessCode"];
        if (self.job.agentForBusinessCode && ![self.job.agentForBusinessCode isEqualToString:self.job.agentId]) {
            [reportDictionary setSafeObject:self.job.agentId forKey:@"broker"];
        }
		[reportDictionary setSafeObject:[self.job dateOfBirthAsString] forKey:@"dateOfBirth"];
        [reportDictionary setSafeObject:self.job.email forKey:@"email"];
        [reportDictionary setSafeObject:self.job.phone forKey:@"phone"];
        if (self.job.practice) {
            [reportDictionary setSafeObject:@YES forKey:@"practice"];
        } else {
            [reportDictionary setSafeObject:@NO forKey:@"practice"];
        }
        
        if (self.job.genderRaw == GenderFemale) {
            [reportDictionary setSafeObject:@"Female" forKey:@"gender"];
        } else if (self.job.genderRaw == GenderMale) {
            [reportDictionary setSafeObject:@"Male" forKey:@"gender"];
        }
        
		NSString *jobId = self.job.jobId.length > 0 ? self.job.jobId : @"";
		[reportDictionary setSafeObject:jobId forKey:@"jobId"];

		if (self.job.dateCompleted) {
				[reportDictionary setSafeObject:[self.job completedDateAsDateTimeString] forKey:@"reportDate"];
				[reportDictionary setSafeObject:[NSTimeZone localTimeZone].name forKey:@"timezone"];
		}
        
		
		// Geodata
		if (self.job.hasGeodata) {
            DebugLog(@"has geo data: %d", self.job.hasGeodata);
				[reportDictionary setSafeObject:@{
                                                  @"lat": [NSNumber numberWithDouble:self.job.geoLat],
                                                  @"lng": [NSNumber numberWithDouble:self.job.geoLng] }
                                         forKey:@"location"];
		}
		
		[reportDictionary setSafeObject:self.job.clientReference forKey:@"clientReference"];

		// ID documents
		NSMutableArray *identificationDocuments = [NSMutableArray array];
		for (ZPImageResponse *imageResponse in self.identificationDocuments) {
				[identificationDocuments addObject:[self dictionaryForImageResponse:imageResponse]];
		}
		if (identificationDocuments.count > 0) {
				[reportDictionary setSafeObject:[NSArray arrayWithArray:identificationDocuments] forKey:@"identificationDocuments"];
		}
		
		// Additional documents
		NSMutableArray *additionalDocuments = [NSMutableArray array];
		for (ZPImageResponse *imageResponse in self.additionalDocuments) {
				[additionalDocuments addObject:[self dictionaryForImageResponse:imageResponse]];
		}
		if (additionalDocuments.count > 0) {
				[reportDictionary setSafeObject:[NSArray arrayWithArray:additionalDocuments] forKey:@"additionalDocuments"];
		}
		
		if (self.clientPhoto) {
				[reportDictionary setSafeObject:[self dictionaryForImageResponse:self.clientPhoto] forKey:@"clientPhoto"];
		}
		
		if (self.clientSignature) {
				[reportDictionary setSafeObject:[self dictionaryForImageResponse:self.clientSignature] forKey:@"clientSignature"];
		}
		
		if (self.agentSignature) {
				[reportDictionary setSafeObject:[self dictionaryForImageResponse:self.agentSignature] forKey:@"agentSignature"];
		}

		[reportDictionary setSafeObject:self.job.jobGUID forKey:@"responseId"];
		[reportDictionary setSafeObject:self.job.verificationType forKey:@"verificationType"];

		// Text responses
		NSMutableDictionary *textResponses = [NSMutableDictionary dictionary];
		for (NSString *textResponseKey in self.textResponsesDictionary) {
				ZPTextResponse *textResponse = self.textResponsesDictionary[textResponseKey];
				[textResponses setSafeObject:[self dictionaryForTextResponse:textResponse] forKey:textResponse.key];
		}
		if (textResponses.count > 0) {
            [reportDictionary setSafeObject:textResponses forKey:@"textResponses"];
		}

        //todo: add images support later
        NSMutableDictionary *additionalStepResponses = [NSMutableDictionary dictionary];
        for (NSString *responseKey in self.additionalStepsResponsesDictionary.keyEnumerator) {
           	ZPTextResponse *textResponse = [self.additionalStepsResponsesDictionary objectForKey:responseKey];
            [additionalStepResponses setSafeObject:[self dictionaryForTextResponse:textResponse] forKey:responseKey];
        }
        [reportDictionary setSafeObject:additionalStepResponses forKey:@"additionalSteps"];
       
		// Transform dictionary to JSON data
		NSData *jsonData = nil;
		NSError *error = [[NSError alloc] init];
		jsonData = [NSJSONSerialization dataWithJSONObject:reportDictionary
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&error];
		if (!jsonData) {
				DebugLog(@"Error creating json data");
		}
		
		return jsonData;
	} @catch (NSException *e) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"A serious error has occurred within the app and the report has not been able to be saved. Please contact ZipID on 1300 073 744 for assistance" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[alertView show];
		return nil;
	}
}

- (NSDictionary *)dictionaryForImageResponse:(ZPImageResponse *)imageResponse
{
    NSMutableDictionary *imageDictionary = [NSMutableDictionary dictionary];
    if (imageResponse.imageReference && imageResponse.documentId) {
        [imageDictionary setSafeObject:imageResponse.documentId forKey:@"documentId"];
        [imageDictionary setSafeObject:imageResponse.documentName forKey:@"name"];
        [imageDictionary setSafeObject:@[ imageResponse.imageName ] forKey:@"images"];
        if (imageResponse.text) {
            [imageDictionary setSafeObject:imageResponse.text forKey:@"text"];
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:imageDictionary];
}

- (NSDictionary *)dictionaryForTextResponse:(ZPTextResponse *)textResponse {
    NSMutableDictionary *textDictionary = [NSMutableDictionary dictionary];
    if (textResponse.text) {
        [textDictionary setSafeObject:textResponse.text forKey:@"text"];
        [textDictionary setSafeObject:textResponse.label forKey:@"name"];
        [textDictionary setSafeObject:textResponse.key forKey:@"key"];
        if (! [textResponse.question isKindOfClass:[NSNull class]] && [textResponse.question length] > 0) {
            [textDictionary setSafeObject:textResponse.question forKey:@"question"];
        }
    }
    return [NSDictionary dictionaryWithDictionary:textDictionary];
}

@end
