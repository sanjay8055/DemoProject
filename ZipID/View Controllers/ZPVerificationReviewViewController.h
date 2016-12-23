//
//  ZPVerificationReviewViewController.h
//  ZipID
//
//  Created by Damien Hill on 2/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Job.h"
#import "ZPSurveyResponse.h"

@interface ZPVerificationReviewViewController : UITableViewController

@property (nonatomic, retain) Job *job;
@property (nonatomic, retain) ZPSurveyResponse *surveyResponse;

@end
