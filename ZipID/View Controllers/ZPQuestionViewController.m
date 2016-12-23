//
//  ZPQuestionViewController.m
//  ZipID
//
//  Created by Damien Hill on 2/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "ZPQuestionViewController.h"
#import "ZPQuestion.h"
#import "ZPNavigationBarWithProgress.h"
#import "ZPQuestionSet+LocalAccessors.h"
#import <GRMustache/GRMustache.h>
#import "Job+Formatters.h"

@interface ZPQuestionViewController ()

@property (nonatomic, retain) ZPQuestion *question;
@property (nonatomic, retain) IBOutlet UILabel *questionText;
@property (nonatomic, retain) IBOutlet UILabel *detailText;
@property (nonatomic, assign) BOOL firstLoad;

- (IBAction)next:(id)sender;
- (IBAction)provideResponse:(id)sender;

@end


@implementation ZPQuestionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.question = self.job.questions[self.questionIndex];

    self.title = self.question.title ? self.question.title : @"";
    
    CLS_LOG(@"Loading step: %@", self.title);
    
    [self renderQuestionText];
    [self renderDetailText];
    
    self.hasResponse = NO;
    self.firstLoad = YES;
    
    [self updateNextButtonEnabled];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZPNavigationBarWithProgress *navBar = (ZPNavigationBarWithProgress *)self.navigationController.navigationBar;
    float progress = (float)(self.questionIndex + 2) / (float)(self.job.questions.count + 3);
    [navBar updateProgress:progress];
    
    [self removeFromResponse];
    [self updateNextButtonEnabled];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[SEGAnalytics sharedAnalytics] screen:self.title];
    [self updateNextButtonEnabled];
}

- (IBAction)next:(id)sender
{
    self.nextButton.enabled = NO;
    if (self.questionIndex + 1 >= self.job.questions.count) {
        CLS_LOG(@"Tapped next: going to review");
        [self gotoReview];
    } else {
        CLS_LOG(@"Tapped next: going to next question");
        [self gotoQuestion];
    }
}

- (void)renderQuestionText
{
    NSString *renderedQuestion = [GRMustacheTemplate renderObject:[self.job dictionaryForMergeFields] fromString:self.question.question error:NULL];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.paragraphSpacing = 10;
    
    if ([self.question.type isEqualToString:@"text"] || [self.question.type isEqualToString:@"confirm"]) {
        paragraphStyle.alignment = NSTextAlignmentLeft;
    } else {
        paragraphStyle.alignment = NSTextAlignmentCenter;
    }
    
    self.questionText.attributedText = [[NSAttributedString alloc] initWithString:renderedQuestion
                                                                       attributes:@{NSParagraphStyleAttributeName : paragraphStyle }];
}

- (void)renderDetailText
{
    if (!self.question.detailText) return;
    
    NSString *renderedDetail = [GRMustacheTemplate renderObject:[self.job dictionaryForMergeFields] fromString:self.question.detailText error:NULL];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.paragraphSpacing = 10;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    self.detailText.attributedText = [[NSAttributedString alloc] initWithString:renderedDetail
                                                                       attributes:@{NSParagraphStyleAttributeName : paragraphStyle }];
}

- (void)gotoReview
{
    [self saveToResponse];
    
    UIViewController *vc = [self getInitialVCForStoryboard:@"Review" universal:YES];
    if ([vc respondsToSelector:@selector(setJob:)]) {
        [vc performSelector:@selector(setJob:) withObject:self.job];
    }
    if ([vc respondsToSelector:@selector(setSurveyResponse:)]) {
        [vc performSelector:@selector(setSurveyResponse:) withObject:self.surveyResponse];
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoQuestion
{
    [self saveToResponse];
    
    ZPQuestion *nextQuestion = self.job.questions[self.questionIndex + 1];
    NSString *viewName = nextQuestion.getViewName;
    
    UIViewController *vc = [self getView:viewName forStoryboard:@"Questions" universal:YES];
    if ([vc isKindOfClass:ZPQuestionViewController.class]) {
        ZPQuestionViewController *questionVC = (ZPQuestionViewController *)vc;
        questionVC.job = self.job;
        questionVC.questionIndex = self.questionIndex + 1;
        questionVC.surveyResponse = self.surveyResponse;
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)provideResponse:(id)sender
{
    self.hasResponse = YES;
    [self updateNextButtonEnabled];
}

- (void)setHasResponse:(BOOL)hasResponse
{
    _hasResponse = hasResponse;
    [self updateNextButtonEnabled];
}

- (void)saveToResponse
{
    // Used by subclasses
}


- (void)removeFromResponse
{
    // Used by subclasses
}

- (void)updateNextButtonEnabled
{
    // Used by subclasses
    if ([self.question.type isEqualToString:@"confirm"]) {
        self.nextButton.enabled = NO;
    } else if (!self.question.required || self.hasResponse || [self.question.type isEqualToString:@"text"]) {
        self.nextButton.enabled = YES;
    } else {
        self.nextButton.enabled = NO;
    }
}


@end
