//
//  ZPClientDetailsViewController.m
//  ZipID
//
//  Created by Damien Hill on 4/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#include "TargetConditionals.h"
@import ISHPermissionKit;
#import "ZipID-Swift.h"
#import "ZPClientDetailsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ZPNavigationBarWithProgress.h"
#import "UIViewController+HideTitleView.h"
#import "Job+Formatters.h"
#import "ZPQuestionSet.h"
#import "ZPQuestionSet+LocalAccessors.h"
#import "ZPApiClient+Methods.h"
#import "ZPLocationService.h"
#import "ZPModalViewControllerProtocol.h"
#import "ZPStringHelper.h"
#import "UIImage+Resize.h"

@interface ZPClientDetailsViewController () <ZPModalViewControllerProtocol, ISHPermissionsViewControllerDataSource>

@property (nonatomic, retain) IBOutlet UILabel *clientNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *jobIdLabel;
@property (nonatomic, retain) IBOutlet UILabel *jobStatusLabel;
@property (nonatomic, retain) IBOutlet UIImageView *clientImageView;
@property (nonatomic, retain) IBOutlet UIButton *beginVerificationButton;
@property (nonatomic, retain) IBOutlet UILabel *practiceLabel;
@property (nonatomic, retain) IBOutlet UILabel *practiceContentLabel;
@property (nonatomic, retain) IBOutlet UILabel *documentsHeadingLabel;
@property (nonatomic, retain) IBOutlet UILabel *requiredDocumentsLabel;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *editBarButtonItem;
@property (nonatomic, retain) IBOutlet UIButton *actionButton;
@property (nonatomic, retain) IBOutlet UIView *uploadProgressView;
@property (nonatomic, retain) IBOutlet UILabel *uploadProgressLabel;
@property (nonatomic, retain) IBOutlet UIProgressView *progressView;
@property (atomic, assign) UIBackgroundTaskIdentifier bgTask;
@property (nonatomic, retain) NSTimer *uploadProgressTimer;

- (IBAction)primaryAction:(id)sender;

@end


@implementation ZPClientDetailsViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadViews];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.uploadProgressTimer = [NSTimer scheduledTimerWithTimeInterval: 0.5
                                                                target: self
                                                              selector: @selector(updateUploadProgress:)
                                                              userInfo: nil
                                                               repeats: YES];
    [self updateUploadProgress:NO];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUploadComplete:) name:@"uploadComplete" object:nil];
    [[SEGAnalytics sharedAnalytics] screen:@"Verification detail"];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.uploadProgressTimer && self.uploadProgressTimer.isValid) {
        [self.uploadProgressTimer invalidate];
        self.uploadProgressTimer = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadViews
{
    // Deleted jobs
    if (!self.job.jobGUID) {
        [self.navigationController popViewControllerAnimated:NO];
        return;
    }
    
    // Fetched jobs - disable edit button until we fully support this
    if (self.job.jobId) {
//        self.editBarButtonItem.enabled = NO;
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    self.practiceLabel.hidden = !self.job.practice;
    self.practiceLabel.layer.cornerRadius = 4;
    [self.practiceLabel.layer setMasksToBounds:YES];
    self.practiceContentLabel.hidden = !(self.job.practice && self.job.jobStatusRaw == JobStatusReady);
        
    [self updateTitleAndStatus];
    [self renderRequiredDocuments];
    
    if (self.job.jobStatusRaw == JobStatusCompleted || self.job.jobStatusRaw == JobStatusWaitingForUpload || self.job.jobStatusRaw == JobStatusUploadInProgress) {
        UIImage *clientPhoto = [self.job getClientPhoto];
        clientPhoto = [UIImage imageWithImage:clientPhoto scaledToFillToSize:self.clientImageView.frame.size];
        clientPhoto = [UIImage roundedRectImageFromImage:clientPhoto size:self.clientImageView.frame.size withCornerRadius:self.clientImageView.frame.size.height / 2];
        self.clientImageView.image = clientPhoto;
        self.clientImageView.layer.masksToBounds = YES;
        self.clientImageView.layer.borderWidth = 0;
        self.clientImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        switch (self.job.genderRaw) {
            case GenderFemale:
                self.clientImageView.image = [UIImage imageNamed:@"ClientIconFemaleLarge"];
                break;
            case GenderMale:
                self.clientImageView.image = [UIImage imageNamed:@"ClientIconMaleLarge"];
                break;
            case GenderNotSpecified:
                self.clientImageView.image = [UIImage imageNamed:@"ClientIconFemaleLarge"];
                break;
        }
    }
    
    ZPNavigationBarWithProgress *navBar = (ZPNavigationBarWithProgress *)self.navigationController.navigationBar;
    [navBar updateProgress:0];
    
    ISHPermissionRequest *locationPermissionRequest = [ISHPermissionRequest requestForCategory:ISHPermissionCategoryLocationWhenInUse];
    BOOL locationServicesAvailable = ([locationPermissionRequest permissionState] == ISHPermissionStateAuthorized);
    if (locationServicesAvailable) {
        [[ZPLocationService sharedInstance] stopUpdating];
    }
}

- (void)updateTitleAndStatus
{
	self.clientNameLabel.text = [self.job nameAsString];
	self.jobIdLabel.text = [self.job jobIdAsString];

    if (self.job.jobStatusRaw == JobStatusCompleted || self.job.jobStatusRaw == JobStatusWaitingForUpload || self.job.jobStatusRaw == JobStatusUploadInProgress) {
        NSString *completedDateString = [NSString stringWithFormat:@"Verified at %@ on %@", self.job.completedTimeAsString, self.job.completedDateAsString];
        self.jobStatusLabel.text = completedDateString;
    } else {
        self.jobStatusLabel.text = [self.job jobStatusAsString];
    }
    
	self.title = self.job.firstName;
	[self hideTitleView];
    
    // This can happen if a verification type is missing in the json
    if (!self.job.verificationTypeObj) {
        self.job.jobStatusRaw = JobStatusWaiting;
    }

	switch (self.job.jobStatusRaw) {
        case JobStatusWaiting:
            [self.actionButton setTitle:@"Select documents" forState:UIControlStateNormal];
            [self.actionButton setAccessibilityLabel:@"Select documents"];
            self.documentsHeadingLabel.text = @"NO DOCUMENTS SELECTED";
            [self showActionButton];
            [self hideProgressView];
            break;
        case JobStatusReady:
            [self.actionButton setTitle:@"Begin verification" forState:UIControlStateNormal];
            [self.actionButton setAccessibilityLabel:@"Begin verification"];
            self.documentsHeadingLabel.text = @"REQUIRED DOCUMENTS";
            [self showActionButton];
            [self hideProgressView];
            break;
        case JobStatusUploadInProgress:
            self.documentsHeadingLabel.text = @"CAPTURED DOCUMENTS";
            float percentComplete = [[UploadManager sharedInstance] getProgress:self.job.jobGUID];
            self.uploadProgressLabel.text = [NSString stringWithFormat:@"%.0f%%", percentComplete * 100];
            [self.progressView setProgress:percentComplete animated:NO];
            [self showProgressView];
            [self hideActionButton];
            break;
        case JobStatusWaitingForUpload:
            [self.actionButton setTitle:@"Upload report" forState:UIControlStateNormal];
            [self.actionButton setAccessibilityLabel:@"Upload report"];
            self.documentsHeadingLabel.text = @"CAPTURED DOCUMENTS";
            [self showActionButton];
            [self hideProgressView];
            break;
        case JobStatusCompleted:
            [self.actionButton setTitle:@"How can I access the report?" forState:UIControlStateNormal];
            [self.actionButton setAccessibilityLabel:@"How can I access the report?"];
            self.documentsHeadingLabel.text = @"CAPTURED DOCUMENTS";
            [self showActionButton];
            [self hideProgressView];
            break;
	}
	
}

- (void)renderRequiredDocuments
{
	NSString *requiredDocumentsString = [[self.job getRequiredDocumentsAsArray] componentsJoinedByString:@"\n"];
    
	NSMutableAttributedString *requiredDocumentsAttrString = [[NSMutableAttributedString alloc] initWithString:requiredDocumentsString];
	NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
	style.lineSpacing = 12;
	style.alignment = NSTextAlignmentCenter;
	[requiredDocumentsAttrString addAttribute:NSParagraphStyleAttributeName
                                        value:style
                                        range:NSMakeRange(0, requiredDocumentsString.length)];
	
	self.requiredDocumentsLabel.attributedText = requiredDocumentsAttrString;
}

- (IBAction)primaryAction:(id)sender
{
    switch (self.job.jobStatusRaw) {
        case JobStatusWaiting:
            [self selectDocuments];
            break;
        case JobStatusReady:
            [[SEGAnalytics sharedAnalytics] track:@"Verification Started"
                                       properties:@{ @"Response ID": self.job.jobGUID,
                                                     @"Verification type": self.job.verificationType }];
            [self startVerification];
            break;
        case JobStatusUploadInProgress:
            [self showReportAccess];
            break;
        case JobStatusWaitingForUpload:
            [self uploadResponse];
            break;
        case JobStatusCompleted:
            [self showReportAccess];
            break;
    }
}

- (void)selectDocuments
{
    [self performSegueWithIdentifier:@"Edit" sender:self];
}

- (void)showReportAccess
{
    [self performSegueWithIdentifier:@"ReportAccess" sender:self];
}

- (void)startVerification
{
    // Check location services are available
    ISHPermissionState permissionState = [[ISHPermissionRequest requestForCategory:ISHPermissionCategoryLocationWhenInUse] permissionState];
    if (permissionState == ISHPermissionStateAuthorized || ![ZPSubscriber hasPermission:PermissionNameLocationServicesRequired]) {
        [self selectAgent];
    } else {
        ISHPermissionsViewController *permissionsVC = [ISHPermissionsViewController permissionsViewControllerWithCategories:@[@(ISHPermissionCategoryLocationWhenInUse)] dataSource:self];
        __weak ZPClientDetailsViewController *clientDetailsVC = self;
        [permissionsVC setCompletionBlock:^{
            ISHPermissionRequest *locationPermissionRequest = [ISHPermissionRequest requestForCategory:ISHPermissionCategoryLocationWhenInUse];
            switch ([locationPermissionRequest permissionState]) {
                case ISHPermissionStateAuthorized:
                    [clientDetailsVC selectAgent];
                    break;
                default:
                    break;
            }
        }];
        if (permissionsVC) {
            permissionsVC.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentViewController:permissionsVC animated:YES completion:nil];
        } else {
            [self showPermissionHelp];
        }
    }
}

- (void)showPermissionHelp
{
    PermissionRequestViewController *permissionsVC = (PermissionRequestViewController *)[self getInitialVCForStoryboard:@"Permissions" universal:YES];
    permissionsVC.permissionCategory = ISHPermissionCategoryLocationWhenInUse;
    permissionsVC.goToSettings = YES;
    permissionsVC.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:permissionsVC animated:YES completion:nil];
}

- (void)selectAgent
{
    if ([ZPLocationService isEnabled]) {
        self.job.dateStarted = [NSDate date];

        UIViewController *vc = [self getView:@"AgentList" forStoryboard:@"Agent" universal:YES];
        [vc performSelector:@selector(setJob:) withObject:self.job];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [self showPermissionHelp];
    }
}

- (void)showProgressView
{
    self.uploadProgressView.alpha = 1;
    self.uploadProgressView.hidden = NO;
}

- (void)hideProgressView
{
    self.uploadProgressView.alpha = 0;
    self.uploadProgressView.hidden = YES;
    self.uploadProgressLabel.text = @"";
    [self.progressView setProgress:0 animated:NO];
}

- (void)hideActionButton
{
    self.actionButton.alpha = 0;
    self.actionButton.hidden = YES;
    self.actionButton.enabled = NO;
}

- (void)showActionButton
{
    self.actionButton.alpha = 1;
    self.actionButton.hidden = NO;
    self.actionButton.enabled = YES;
}

- (void)uploadResponse
{
    [self hideActionButton]; // Prevent duplicate uploads
    if (self.job.jobStatusRaw == JobStatusUploadInProgress) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UploadManager sharedInstance] uploadJobWithCompletion:self.job completion:^(BOOL success, NSError *error) {
            if (!success) {
                if (error.code == ZipErrorUnauthorized && [error.domain isEqualToString:@"au.com.zipid.zipid"]) {
                    DebugLog(@"Not authorized, showing login prompt");
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkSignIn" object:nil];
                } else {
                    DebugLog(@"Network error");
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Upload failed"
                                                                        message:@"Couldn't connect to ZipID."
                                                                       delegate:self
                                                              cancelButtonTitle:@"Ok"
                                                              otherButtonTitles:nil];
                    [alertView show];
                }
            }
        }];
    });
}

- (void)updateUploadProgress:(BOOL)animated
{
    [self updateTitleAndStatus];
}

- (void)handleUploadComplete:(NSNotification *)notification
{
    if (![[notification.userInfo objectForKey:@"jobGUID"] isEqualToString:self.job.jobGUID]) return;
    
    BOOL success = [[notification.userInfo objectForKey:@"success"] boolValue];
    if (!success) {
        // To Do: Show failed alert?
//        self.actionButton.enabled = YES;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Upload failed"
                                                            message:@"An error occurred uploading the report to ZipID."
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    } else {
        DebugLog(@"Upload success");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Upload success"
                                                            message:@"Successfully uploaded report to ZipID."
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    [self updateTitleAndStatus];
}

- (void)saveContext
{
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
        } else if (error) {
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *vc = nil;
    if ([segue.destinationViewController isKindOfClass:UINavigationController.class]) {
        UINavigationController *navVC = segue.destinationViewController;
        vc = navVC.childViewControllers[0];
    } else {
        vc = segue.destinationViewController;
    }
    
    if ([vc respondsToSelector:@selector(setJob:)]) {
        [vc performSelector:@selector(setJob:) withObject:self.job];
    }
    if ([vc respondsToSelector:@selector(setDelegate:)]) {
        [vc performSelector:@selector(setDelegate:) withObject:self];
    }
}

#pragma mark - ZPModalViewController
- (void)modalDidDismiss:(UIViewController *)viewController
{
    [self loadViews];
}

#pragma mark - ISHPermissionsViewControllerDataSource
- (ISHPermissionRequestViewController *)permissionsViewController:(ISHPermissionsViewController *)vc requestViewControllerForCategory:(ISHPermissionCategory)category
{
    return (PermissionRequestViewController *)[self getInitialVCForStoryboard:@"Permissions" universal:YES];
}

@end
