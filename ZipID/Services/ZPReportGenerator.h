//
//  ZPReportGenerator.h
//  ZipID
//
//  Created by Damien Hill on 18/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZPSurveyResponse.h"

@interface ZPReportGenerator : NSObject

@property (nonatomic, retain) ZPSurveyResponse *surveyResponse;

- (void)generateReportWithSuccess:(void (^)(void))success failure: (void (^)(void))failure;

@end
