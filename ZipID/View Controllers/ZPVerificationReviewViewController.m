//
//  ZPVerificationReviewViewController.m
//  ZipID
//
//  Created by Damien Hill on 2/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

@import ISHPermissionKit;
#import "ZPVerificationReviewViewController.h"
#import "ZPNavigationBarWithProgress.h"
#import "ZPReviewDocumentCell.h"
#import "ZPReportGenerator.h"
#import "ZPLoadingView.h"
#import "ZPLocationService.h"
#import "ZipID-Swift.h"

@interface ZPVerificationReviewViewController ()

@property (nonatomic, retain) ZPImageResponse *imageResponse;
@property (nonatomic, retain) ZPLoadingView *loadingView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *submitButton;

- (IBAction)submit:(id)sender;

@end


@implementation ZPVerificationReviewViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [[SEGAnalytics sharedAnalytics] track:@"Verification Review Screen"
                               properties:@{ @"Response ID": self.job.jobGUID,
                                             @"Verification type": self.job.verificationType }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[SEGAnalytics sharedAnalytics] screen:@"Verification review"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZPNavigationBarWithProgress *navBar = (ZPNavigationBarWithProgress *)self.navigationController.navigationBar;
    [navBar updateProgress:0.9];
}

- (IBAction)submit:(id)sender
{
    CLS_LOG(@"Saving and encrypting report");
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    [props setObject:self.job.jobGUID forKey:@"Response ID"];
    [props setObject:self.job.verificationType forKey:@"Verification type"];
    #ifndef ENTERPRISE
        [props setObject:[NSNumber numberWithFloat:9.00] forKey:@"revenue"];
    #endif
    [[SEGAnalytics sharedAnalytics] track:@"Verification Completed" properties:[NSDictionary dictionaryWithDictionary:props]];
    
    self.loadingView = [ZPLoadingView loadInstanceFromNib];
    self.loadingView.loadingText = @"Saving report";
    [self.loadingView showAnimated:YES overView:self.view];
    self.submitButton.enabled = NO;
    
    self.job.jobStatusRaw = JobStatusWaitingForUpload;
    self.job.dateCompleted = [NSDate date];
    
    
    ISHPermissionRequest *locationPermissionRequest = [ISHPermissionRequest requestForCategory:ISHPermissionCategoryLocationWhenInUse];
    BOOL locationServicesAvailable = ([locationPermissionRequest permissionState] == ISHPermissionStateAuthorized);
    if (locationServicesAvailable) {
        CLLocation *currentLocation = [[ZPLocationService sharedInstance] getCurrentLocation];
        DebugLog(@"Final location: %f %f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
        if (currentLocation) {
            [self.job setGeoDataWithLocation:currentLocation];
        }
        [[ZPLocationService sharedInstance] stopUpdating];
    }
    
    ZPReportGenerator *reportGenerator = [[ZPReportGenerator alloc] init];
    reportGenerator.surveyResponse = self.surveyResponse;
    [reportGenerator generateReportWithSuccess:^{
        CLS_LOG(@"Report encryption successful");
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"verificationCompleted"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.loadingView hideContent:YES];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            if (success) {
                CLS_LOG(@"Success saving report model: %@", [error localizedDescription]);
                [[UploadManager sharedInstance] startBackgroundUpload:self.job];
                [self performSegueWithIdentifier:@"Complete" sender:self];
            } else if (error) {
                CLS_LOG(@"Error saving report model: %@", [error localizedDescription]);
                [self.loadingView hideAnimated:YES];
                self.submitButton.enabled = YES;
            }
        }];
    } failure:^{
        CLS_LOG(@"Report save and encryption failed");
        [self.loadingView hideAnimated:YES];
        self.submitButton.enabled = YES;
    }];
	
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ImagePreview"]) {
        UINavigationController *navVc = (UINavigationController *)segue.destinationViewController;
        UIViewController *vc = navVc.childViewControllers[0];
        if ([vc respondsToSelector:@selector(setImageResponse:)]) {
            [vc performSelector:@selector(setImageResponse:) withObject:self.imageResponse];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger rows = 0;
    switch (section) {
        case 0:
            rows = self.surveyResponse.identificationDocuments.count;
            break;
        case 1:
            rows = self.surveyResponse.additionalDocuments.count;
            break;
        case 2:
            rows = self.surveyResponse.clientPhoto ? 1 : 0;
            break;
        case 3:
            rows = self.surveyResponse.clientSignature ? 1 : 0;
            break;
        case 4:
            rows = self.surveyResponse.agentSignature ? 1 : 0;
            break;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"IdentificationDocumentCell";
    
    ZPImageResponse *imageResponse = nil;
    switch (indexPath.section) {
        case 0:
            imageResponse = self.surveyResponse.identificationDocuments[indexPath.row];
            break;
        case 1:
            imageResponse = self.surveyResponse.additionalDocuments[indexPath.row];
            break;
        case 2:
            cellIdentifier = @"ClientPhotoCell";
            imageResponse = self.surveyResponse.clientPhoto;
            break;
        case 3:
            cellIdentifier = @"SignatureCell";
            imageResponse = self.surveyResponse.clientSignature;
            break;
        case 4:
            cellIdentifier = @"SignatureCell";
            imageResponse = self.surveyResponse.agentSignature;
            break;
    }
    
    
    ZPReviewDocumentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    ImageManager *imageManager = [[ImageManager alloc] init];
    cell.documentImage.image = [imageManager getImage:imageResponse.imageReference];
    cell.documentName.text = imageResponse.documentName;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    switch (section) {
        case 0:
            title = self.surveyResponse.identificationDocuments.count > 0 ? @"Identification documents" : nil;
            break;
        case 1:
            title = self.surveyResponse.additionalDocuments.count > 0 ? @"Additional documents" : nil;
            break;
        case 2:
            title = self.surveyResponse.clientPhoto ? @"Client photo" : nil;
            break;
        case 3:
            title = self.surveyResponse.clientSignature ? @"Client signature" : nil;
            break;
        case 4:
            title = self.surveyResponse.agentSignature ? @"Agent signature" : nil;
            break;
    }
    return title;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight = 90;
    switch (indexPath.section) {
        case 2:
            rowHeight = 180;
            break;
        case 3:
            rowHeight = 120;
            break;
        case 4:
            rowHeight = 120;
            break;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        rowHeight = rowHeight * 2;
    }
    return rowHeight;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZPImageResponse *imageResponse = nil;
    switch (indexPath.section) {
        case 0:
            imageResponse = self.surveyResponse.identificationDocuments[indexPath.row];
            break;
        case 1:
            imageResponse = self.surveyResponse.additionalDocuments[indexPath.row];
            break;
        case 2:
            imageResponse = self.surveyResponse.clientPhoto;
            break;
        case 3:
            imageResponse = self.surveyResponse.clientSignature;
            break;
        case 4:
            imageResponse = self.surveyResponse.agentSignature;
            break;
    }
    self.imageResponse = imageResponse;
    
    [self performSegueWithIdentifier:@"ImagePreview" sender:self];
    
    return indexPath;
}

@end
