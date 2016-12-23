//
//  ZPConfirmDenyQuestionViewController.m
//  ZipID
//
//  Created by Brett Dargan on 3/12/2015.
//  Copyright © 2015 ZipID. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ZPConfirmDenyQuestionViewController.h"
#import "ZPQuestion.h"
#import "ZPTextResponse.h"
#import "GRMustache.h"
#import "Job+Formatters.h"
#import "ZipID-Swift.h"
@import SafariServices;

@interface ZPConfirmDenyQuestionViewController () <UIWebViewDelegate>

@property (nonatomic, retain) ZPQuestion *question;
@property (nonatomic, retain) IBOutlet UIButton *button1;
@property (nonatomic, retain) IBOutlet UIButton *button2;
@property (nonatomic, retain) IBOutlet UIWebView *detailWebView;
@property (nonatomic, retain) NSString *selectedResponse;

@end

@implementation ZPConfirmDenyQuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nextButton.enabled = NO;
    
    self.selectedResponse = @"";
    
    self.question = self.job.questions[self.questionIndex];
    
    if (self.question.detailText) {
        NSString *renderedDetail = [GRMustacheTemplate renderObject:[self.job dictionaryForMergeFields] fromString:self.question.detailText error:NULL];

        // Load HTML template and add in our detail text
        renderedDetail = [MarkingbirdObjc render:renderedDetail];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"WebView Assets/templates/main" ofType:@"html"];
        NSString *htmlContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        htmlContent = [htmlContent stringByReplacingOccurrencesOfString:@"{{{body}}}" withString:renderedDetail];
        NSString *basePath = [[NSBundle mainBundle] pathForResource:@"WebView Assets" ofType:nil];
        NSURL *baseURL = [NSURL fileURLWithPath:basePath];
        [self.detailWebView loadHTMLString:htmlContent baseURL:baseURL];
    }

    

    if (self.question.options.count > 0) {
        NSDictionary *option = self.question.options[0];
        [self.button1 setTitle:[option objectForKey:@"label"] forState:UIControlStateNormal];
    } else {
        self.button1.hidden = YES;
    }
    
    if (self.question.options.count > 1) {
        NSDictionary *option = self.question.options[1];
        [self.button2 setTitle:[option objectForKey:@"label"] forState:UIControlStateNormal];
    } else {
        self.button2.hidden = YES;
        for (NSLayoutConstraint *constraint in self.view.constraints) {
            if ([constraint.identifier isEqualToString:@"ButtonSpacing"] || [constraint.identifier isEqualToString:@"ButtonsEqualWidth"]) {
                [self.view removeConstraint:constraint];
            }
        }
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.button1
                                                              attribute:NSLayoutAttributeLeadingMargin
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeLeadingMargin
                                                             multiplier:1
                                                               constant:10]];
    }
}

- (IBAction)didSelectOption:(id)sender
{
    if (sender == self.button1) {
        NSDictionary *option = self.question.options[0];
        self.selectedResponse = [option objectForKey:@"value"];
        [self next:self];
    } else if (sender == self.button2) {
        NSDictionary *option = self.question.options[1];
        self.selectedResponse = [option objectForKey:@"value"];
        [self next:self];
    }
}

- (void)saveToResponse
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE d 'of' MMMM YYYY"];
    
    //TODO: assume this is addtionalStep
    ZPTextResponse *confirmDenyResponse = [[ZPTextResponse alloc] init];
    confirmDenyResponse.text = [NSString stringWithFormat:@"%@ by %@ on %@",
                                self.selectedResponse,
                                [self.job nameAsString],
                                [dateFormatter stringFromDate:[NSDate date]]];
    confirmDenyResponse.key = self.question.documentId;
    confirmDenyResponse.label = self.question.title;
    confirmDenyResponse.question = self.question.detailText;
    
    [self.surveyResponse.additionalStepsResponsesDictionary setObject:confirmDenyResponse forKey:@"macqPrivacyConsent"];
    [super saveToResponse];
    
}

- (void)removeFromResponse
{
    [self.surveyResponse.textResponsesDictionary removeObjectForKey:@"macqPrivacyConsent"];
    [super removeFromResponse];
}

#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeOther) {
        return YES;
    } else {
        if(NSClassFromString(@"SFSafariViewController")) {
            SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:request.URL];
            [self presentViewController:safari animated:YES completion:nil];
        } else {
            [[UIApplication sharedApplication] openURL:request.URL];
        }
        return NO;
    }
}

@end