//
//  ZPQuestionViewController.h
//  ZipID
//
//  Created by Damien Hill on 2/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Job.h"
#import "ZPSurveyResponse.h"

@interface ZPQuestionViewController : UIViewController

@property (nonatomic, assign) int questionIndex;
@property (nonatomic, retain) Job *job;
@property (nonatomic, retain) ZPSurveyResponse *surveyResponse;

/* TO DO: Make these private but allow subclasses to access */
@property (nonatomic, retain) IBOutlet UIBarButtonItem *nextButton;
@property (nonatomic, assign) BOOL hasResponse;

- (IBAction)next:(id)sender;
- (void)saveToResponse;
- (void)removeFromResponse;

@end
