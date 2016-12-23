//
//  ZPSurveyResponse.h
//  ZipID
//
//  Created by Damien Hill on 3/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZPImageResponse.h"
#import "Job.h"

@interface ZPSurveyResponse : NSObject

@property (nonatomic, retain) NSMutableDictionary *identificationDocumentsDictionary;
@property (nonatomic, retain) NSMutableDictionary *additionalDocumentsDictionary;
@property (nonatomic, retain) NSMutableDictionary *textResponsesDictionary;
@property (nonatomic, retain) NSMutableDictionary *additionalStepsResponsesDictionary;

@property (nonatomic, retain) ZPImageResponse *clientPhoto;
@property (nonatomic, retain) ZPImageResponse *clientSignature;
@property (nonatomic, retain) ZPImageResponse *agentSignature;
@property (nonatomic, retain) Job *job;

- (NSArray *)identificationDocuments;
- (NSArray *)additionalDocuments;

- (NSData *)buildReportModel;

@end