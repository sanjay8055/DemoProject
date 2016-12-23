//
//  ZPClientListViewController.m
//  ZipID
//
//  Created by Damien Hill on 18/10/13.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "ZPClientListViewController.h"
#import "UIViewController+StoryboardHelper.h"
#import "ZPClientCell.h"
#import "ZPEmptyView.h"
#import "Job.h"
#import "Job+Formatters.h"
#import "Job+LocalAccessors.h"
#import "ZPJobsManager.h"
#import "ZPLoadingView.h"
#import "ZPSubscriber.h"
#import "UIColor+NFColors.h"
#import "UIView+ZPAccessibilityId.h"
#import "ZipID-Swift.h"
#import <DateTools/DateTools.h>
#import "UIImage+Resize.h"
#import "ZPApiClient.h"

//remove
#import "ZPQuestionSet.h"
#import "ZPQuestionSet+LocalAccessors.h"

typedef enum {
    JobListCompleted,
    JobListInProgress
} JobListView;


@interface ZPClientListViewController () <ZPLoadingViewProtocol, UISearchBarDelegate>

@property (nonatomic, retain) Job *job;
@property (nonatomic, retain) ZPEmptyView *emptyView;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *addButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *menuButton;
@property (nonatomic, retain) IBOutlet UISegmentedControl *jobViewSegmentedControl;
@property (nonatomic, assign) JobListView jobListView;
@property (nonatomic, strong) ZPLoadingView *loadingView;

@property (nonatomic, retain) NSArray *jobGroups;
@property (nonatomic, strong) UIRefreshControl *refreshIndicator;

@property (nonatomic, assign) BOOL isSearching;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) NSTimer *updateUploadProgressTimer;

@property (nonatomic, retain) IBOutlet UILabel *practiceContentBody;
@property (nonatomic, retain) IBOutlet UIButton *practiceContentButton;
@property (nonatomic, retain) IBOutlet UIView *guideContentView;

@end


@implementation ZPClientListViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.navigationItem.hidesBackButton = YES;
    
    // Disable back gesture to prevent issues with signature view controller
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }

	self.tableView.accessibilityIdentifier = @"Client list";
	self.addButton.accessibilityLabel = @"New job";
	self.menuButton.accessibilityLabel = @"Menu";
	self.searchBar.accessibilityLabel = @"Search for a job";

	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        self.navigationController.toolbar.tintColor = [UIColor colorWithHex:0x8DC43D alpha:1.0];
	}

	self.jobListView = JobListInProgress;
	self.loadingView = [ZPLoadingView loadInstanceFromNib];
	self.loadingView.delegate = self;
	
	self.tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
	
	UIGestureRecognizer *viewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
	viewTap.cancelsTouchesInView = NO;
	[self.view addGestureRecognizer:viewTap];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUploadJobSuccessfully:) name:@"uploadComplete" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSignOut:) name:@"didSignOut" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSaveJob:) name:@"didSaveJob" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSubscriberPermissionsUpdated) name:@"subscriberPersmissionsUpdated" object:nil];
	
	[self handleSubscriberPermissionsUpdated];
    [self resizePracticeModeContent];
    
    self.navigationController.navigationBar.translucent = NO;
    
    if ([ZPSubscriber hasPermission:PermissionNameFetchJobs]) { // if the subscriber is allowed to fetch jobs
        [self fetchRemoteJobsWithLoading:NO];
        self.searchBar.placeholder = @"Name, address or job number";
    }
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (self.navigationController.navigationBarHidden) {
		[self.navigationController setNavigationBarHidden:NO animated:YES];
	}
	if (self.navigationController.toolbarHidden) {
        [self.navigationController setToolbarHidden:NO animated:NO];
	}
	self.job = nil;
	[self loadJobs];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	if (!self.navigationController.toolbarHidden) {
		[self.navigationController setToolbarHidden:YES animated:YES];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.updateUploadProgressTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                                      target:self
                                                                    selector:@selector(updateUploadProgress)
                                                                    userInfo:nil
                                                                     repeats:YES];
    [[SEGAnalytics sharedAnalytics] screen:@"Verification list"];
    [self resizePracticeModeContent];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.updateUploadProgressTimer && self.updateUploadProgressTimer.isValid) {
        [self.updateUploadProgressTimer invalidate];
        self.updateUploadProgressTimer = nil;
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
         [self resizePracticeModeContent];
    }];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	UIViewController *vc = nil;
	if ([segue.destinationViewController isKindOfClass:UINavigationController.class]) {
		UINavigationController *navVc = (UINavigationController *)segue.destinationViewController;
		vc = [[navVc childViewControllers] objectAtIndex:0];
	} else {
		vc = [segue destinationViewController];
	}
	if ([vc respondsToSelector:@selector(setJob:)]) {
		[vc performSelector:@selector(setJob:) withObject:self.job];
	}
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([segue.identifier isEqualToString:@"Guide"]) {
        if ([segue.destinationViewController respondsToSelector:@selector(setContentPath:)]) {
            NSString *contentPath = @"guide";
            if ([[ZPSubscriber sharedInstance].account.type isEqualToString:@"Broker"]) {
                contentPath = @"broker-guide";
            }
            [segue.destinationViewController performSelector:@selector(setContentPath:) withObject:contentPath];
            [segue.destinationViewController setTitle:@"Guide"];
        }
    }
#pragma clang diagnostic pop
}

- (void)dismissKeyboard:(id)sender {
	[self.view endEditing:YES];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Job Loading
- (IBAction)createJob {
	[self performSegueWithIdentifier:@"createJob" sender:self];
}

- (void)refreshJobs {
	[self.refreshIndicator endRefreshing];
	if ([ZPSubscriber hasPermission:PermissionNameFetchJobs]) { // if the subscriber is allowed to fetch jobs
		[self fetchRemoteJobsWithLoading:YES];
	} else {
		[self loadJobs];
	}
}

- (void)fetchRemoteJobsWithLoading:(BOOL)showLoading {
	__weak typeof(self) weakSelf = self;
	self.loadingView.tryAgainAction = ^{
		[weakSelf fetchRemoteJobsWithLoading:showLoading];
	};
	
	if (showLoading) {
		[self showLoadingWithTitle:@"Fetching clients" andErrorTitle:@"Error fetching clients"];
	}
	
	[[ZPJobsManager sharedInstance] fetchAndProcessJobsWithCompletion:^(BOOL success) {
		if (success) {
			[weakSelf loadJobs];
			[self hideLoading];
		} else {
			[weakSelf.loadingView haltLoadingDueToError];
		}
	}];
}

- (void)loadJobs {
    JobsSortOrder sortOrder = JobsSortOrderDateCreated;
    if ([ZPSubscriber hasPermission:PermissionNameFetchJobs]) {
        sortOrder = JobsSortOrderFirstName;
    }
	switch (self.jobListView) {
		case JobListInProgress:
            self.jobGroups = self.searchBar.text.length > 0 ? [Job findInProgressWithSearchString:self.searchBar.text sortedBy:sortOrder] : [Job findInProgressSortedBy:sortOrder];
			break;
			
		case JobListCompleted:
			self.jobGroups = self.searchBar.text.length > 0 ? [Job findCompletedWithSearchString:self.searchBar.text sortedBy:sortOrder] : [Job findCompletedSortedBy:sortOrder];
			break;
	}
	
	[self.tableView reloadData];
	[self checkNumberOfJobs];
    [self showPracticeContent];
}

- (void)checkNumberOfJobs {
	
	if (self.isSearching && self.jobGroups.count <= 0) {
		[self showEmptyView];
		return;
	}
	
	if ([Job totalJobCount] <= 0 && [ZPSubscriber hasPermission:PermissionNameAdhoc]) {
		[self showWelcomeView];
		return;
	}
	
	if (self.jobGroups.count <= 0) {
		[self showEmptyView];
	} else if (self.emptyView) {
		[self.emptyView removeFromSuperview];
		self.emptyView = nil;
	}
}

- (void)didUploadJobSuccessfully:(NSNotification *)notification
{
    if ([[notification.userInfo objectForKey:@"success"] boolValue] == YES) {
        self.jobListView = JobListCompleted;
        [self.jobViewSegmentedControl setSelectedSegmentIndex:1];
        [self loadJobs];
    }
}

- (void)didSaveJob:(NSNotification *)notification
{
	self.jobListView = JobListInProgress;
	[self.jobViewSegmentedControl setSelectedSegmentIndex:0];
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		self.job = nil;
		[self loadJobs];
	}
}

- (void)updateUploadProgress
{
    [self.tableView reloadData];
}

#pragma mark Permission Handling

- (void)handleSubscriberPermissionsUpdated
{
	[self handleAdhocPermission];
	[self handleRefreshSetup];
}

- (void)handleRefreshSetup {
	if ([ZPSubscriber hasPermission:PermissionNameFetchJobs]) {
		if (!self.refreshIndicator) {
			self.refreshIndicator = [[UIRefreshControl alloc] init];
            UIColor *color = [UIColor colorWithHex:0x797979 alpha:1];
			self.refreshIndicator.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to load jobs" attributes:@{ NSForegroundColorAttributeName : color }];
			[self.refreshIndicator addTarget:self action:@selector(refreshJobs) forControlEvents:UIControlEventValueChanged];
            
            UITableViewController *tableViewController = [[UITableViewController alloc] init];
            tableViewController.tableView = self.tableView;
            tableViewController.refreshControl = self.refreshIndicator;
		}
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchRemoteJobsWithLoading:) name:@"applicationDidBecomeActive" object:nil];
	} else {
		self.refreshIndicator = nil;
		[[NSNotificationCenter defaultCenter] removeObserver:self name:@"applicationDidBecomeActive" object:nil];
	}
}

- (void)handleAdhocPermission {
    NSArray *brokerFor = [ZPSubscriber sharedInstance].brokerFor;
	if ([ZPSubscriber hasPermission:PermissionNameAdhoc] && brokerFor.count > 0) {
		UIBarButtonItem *plus = [[UIBarButtonItem alloc]
                                 initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                 target:self
                                 action:@selector(createJob)];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            plus = [[UIBarButtonItem alloc] initWithTitle:@"New client"
                                                    style:UIBarButtonItemStyleDone
                                                   target:self
                                                   action:@selector(createJob)];
        }
		self.navigationItem.rightBarButtonItem = plus;
		self.navigationItem.rightBarButtonItem.accessibilityLabel = @"New job";
		self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithHex:0x8DC43D alpha:1];
	} else if ([ZPSubscriber hasPermission:PermissionNameFetchJobs]) {
        UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc]
                                          initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                          target:self
                                          action:@selector(refreshJobs)];
        self.navigationItem.rightBarButtonItem = refreshButton;
        self.navigationItem.rightBarButtonItem.accessibilityLabel = @"Refresh jobs";
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithHex:0x8DC43D alpha:1];
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)didSignOut:(NSNotification *)notification {
	[self.navigationController popToRootViewControllerAnimated:NO];
}

#pragma mark Loading Screens
- (void)loadingViewDidDismiss {
	[self.navigationController setToolbarHidden:NO];
	self.navigationItem.leftBarButtonItem.enabled = YES;
	self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)showLoadingWithTitle:(NSString *)title andErrorTitle:(NSString *)errorTitle {
	self.loadingView.loadingText = title;
	self.loadingView.errorText = errorTitle;
	[self.loadingView showAnimated:YES overView:self.view];
	[self.navigationController setToolbarHidden:YES];
	self.navigationItem.leftBarButtonItem.enabled = NO;
	self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)hideLoading {
	[self.loadingView hideAnimated:YES];
	[self.navigationController setToolbarHidden:NO];
	self.navigationItem.leftBarButtonItem.enabled = YES;
	self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)showWelcomeView {
	if (!self.emptyView) {
		self.emptyView = [ZPEmptyView loadInstanceFromNib];
		__weak typeof(self) weakSelf = self;
		if ([ZPSubscriber hasPermission:PermissionNameFetchJobs]) {
			[self.emptyView.customActionButton setTitle:@"Fetch jobs" forState:UIControlStateNormal];
			self.emptyView.customAction = ^{
				[weakSelf fetchRemoteJobsWithLoading:YES];
			};
		} else {
			[self.emptyView.customActionButton removeFromSuperview];
		}
		self.emptyView.frame = self.view.bounds;
		[self.view addSubview:self.emptyView];
	}
}

- (void)showEmptyView {
	
    if (self.emptyView) {
        [self.emptyView removeFromSuperview];
    }
    self.emptyView = [ZPEmptyView loadInstanceFromNib];
    
    if ([ZPSubscriber hasPermission:PermissionNameFetchJobs]) {
        
        self.emptyView.customActionButton.alpha = self.jobListView == JobListCompleted ? 0 : 1;
        
        __weak typeof(self) weakSelf = self;
        [self.emptyView.customActionButton setTitle:@"Fetch jobs" forState:UIControlStateNormal];
        self.emptyView.customAction = ^{
            [weakSelf fetchRemoteJobsWithLoading:YES];
        };
    } else {
        [self.emptyView.customActionButton removeFromSuperview];
    }
    
	NSString *title;
	if (self.jobListView == JobListInProgress) {
		title = @"No jobs";
		if ([ZPSubscriber hasPermission:PermissionNameAdhoc]) {
			self.emptyView.text = @"Add a new job by tapping the plus button in the top right.";
		} else if ([ZPSubscriber hasPermission:PermissionNameFetchJobs]) {
			self.emptyView.text = @"Try loading jobs by pressing the button below.";
		}
	} else {
		title = @"No completed jobs";
		self.emptyView.text = @"Once you have successfully uploaded jobs they will appear here.";
	}
	
	if (self.isSearching) {
		title = [NSString stringWithFormat:@"%@ found", title];
	}
	
	self.emptyView.title = title;
	
	self.emptyView.frame = self.view.bounds;
	[self.view insertSubview:self.emptyView belowSubview:self.searchBar];
}

- (void)showPracticeContent
{
    #if ENTERPRISE
    self.tableView.tableHeaderView = nil;
    if (self.guideContentView) {
        [self.guideContentView removeFromSuperview];
        self.guideContentView = nil;
    }
    return;
    #endif
    
    BOOL verificationCompleted = [[NSUserDefaults standardUserDefaults] objectForKey:@"verificationCompleted"] != nil;
    BOOL verificationUploaded = [[NSUserDefaults standardUserDefaults] objectForKey:@"verificationUploaded"] != nil;
    BOOL practiceCompleted = [[NSUserDefaults standardUserDefaults] objectForKey:@"practiceCompleted"] != nil;
    if (verificationCompleted && verificationUploaded && practiceCompleted) {
        self.tableView.tableHeaderView = nil;
        if (self.guideContentView) {
            [self.guideContentView removeFromSuperview];
            self.guideContentView = nil;
        }
    } else {
        CLS_LOG(@"Showing practice mode content");
        NSMutableAttributedString *practiceContent;
        NSString *heading;
        NSString *body;
        if (!verificationCompleted) {
            if ([ZPSubscriber sharedInstance].agentFirstName) {
                heading = [NSString stringWithFormat:@"Welcome %@.", [ZPSubscriber sharedInstance].agentFirstName];
            } else {
                heading = @"Welcome";
            }
            body = @"Tap below to begin your practice report. It only takes a few minutes to become an expert.";
        } else if (!verificationUploaded) {
            heading = @"Report encrypted.";
            body = @"We’re securely uploading your report.";
        } else {
            heading = @"Success!";
            body = @"Sign in to download your report at the ZipID website.";
        }
        practiceContent = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", heading, body]];
        [practiceContent addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:15] range:NSMakeRange(0, heading.length)];
        self.practiceContentBody.attributedText = practiceContent;
        [self resizePracticeModeContent];
    }
}

- (void)resizePracticeModeContent
{
    if (self.tableView.tableHeaderView != nil) {
        self.practiceContentBody.preferredMaxLayoutWidth = self.practiceContentBody.bounds.size.width;
       
        UIView *headerView = self.tableView.tableHeaderView;
        CGFloat height = [headerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        
        CGRect headerFrame = headerView.frame;
        headerFrame.size.height = height;
        headerView.frame = headerFrame;
        self.tableView.tableHeaderView = headerView;
    }
}

- (void)dismissPracticeModeContent
{
    self.tableView.tableHeaderView = nil;
}

- (NSString *)getLastUpdatedString
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"jobsUpdatedDate"]) {
        return @"";
    } else {
        NSDate *lastUpdatedDate = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:@"jobsUpdatedDate"];
        if (lastUpdatedDate.timeIntervalSinceNow < -60) {
            return [NSString stringWithFormat:@"Updated %@", [lastUpdatedDate.timeAgoSinceNow lowercaseString]];
        } else {
            return @"Updated just now";
        }
    }
}

#pragma mark General
- (IBAction)loadSettings:(id)sender
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[self loadStoryboardAsFormSheet:@"Settings" universal:YES];
	} else {
		[self loadStoryboard:@"Settings" universal:YES];
	}
}

- (IBAction)changeJobListView:(id)sender
{
    switch (self.jobViewSegmentedControl.selectedSegmentIndex) {
        case 0:
            self.jobListView = JobListInProgress;
            break;
        case 1:
            self.jobListView = JobListCompleted;
            break;
    }
    [self loadJobs];
}

#pragma mark - Jobs Table view data source
- (NSArray *)jobsForSection:(NSInteger)section
{
	NSDictionary *jobGroup = [self.jobGroups objectAtIndex:section];
	NSArray *jobs = [jobGroup objectForKey:@"jobs"];
	return jobs;
}

- (Job *)jobForIndexPath:(NSIndexPath *)indexPath
{
    NSInteger offset = 0;
    if ([ZPSubscriber hasPermission:PermissionNameFetchJobs]) {
        offset = 1;
    }
    
	NSArray *jobs = [self jobsForSection:indexPath.section - offset];
	Job *job = [jobs objectAtIndex:indexPath.row];
	return job;
}

- (void)selectCellAtIndexPath:(NSIndexPath *)indexPath
{
    if ([ZPSubscriber hasPermission:PermissionNameFetchJobs] && indexPath.section == 0) {
        return;
    } else {
        self.job = [self jobForIndexPath:indexPath];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([ZPSubscriber hasPermission:PermissionNameFetchJobs]) {
        return self.jobGroups.count + 1;
    } else {
        return self.jobGroups.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger offset = 0;
    if ([ZPSubscriber hasPermission:PermissionNameFetchJobs]) {
        offset = 1;
        if (section == 0) {
            return 1;
        }
    }
    return [self jobsForSection:section - offset].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Updated cell
    if ([ZPSubscriber hasPermission:PermissionNameFetchJobs] && indexPath.section == 0) {
        NSString *cellIdentifier = @"LastUpdatedCell";       
        LastUpdatedCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.lastUpdatedLabel.text = [self getLastUpdatedString];
        return cell;
    } else {
        
        Job *job = [self jobForIndexPath:indexPath];
        
        NSString *cellIdentifier = @"JobCell";
        ZPClientCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        
        cell.textLabel.text = [job nameAsString];
        cell.progressView.hidden = YES;
        
        if (job.practice) {
            cell.practiceLabel.layer.cornerRadius = 4;
            [cell.practiceLabel.layer setMasksToBounds:YES];
            cell.practiceLabel.hidden = NO;
        } else {
            cell.practiceLabel.hidden = YES;
        }
        
        switch (job.jobStatusRaw) {
            case JobStatusWaiting:
                cell.detailTextLabel.text = @"Awaiting selection of documents";
                break;
            case JobStatusReady:
                cell.detailTextLabel.text = @"Ready to verify";
                break;
            case JobStatusCompleted:
                cell.detailTextLabel.text = @"Complete";
                break;
            case JobStatusWaitingForUpload:
                cell.detailTextLabel.text = @"Waiting to upload";
                break;
           case JobStatusUploadInProgress:
                cell.detailTextLabel.text = @"Uploading report...";
                break;
        }
        
        if ([ZPSubscriber hasPermission:PermissionNameFetchJobs] && job.appointmentSuburb && job.jobId) {
            cell.statusLabel.text = cell.detailTextLabel.text;
            cell.statusLabel.hidden = NO;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ – %@", job.appointmentSuburb, job.jobId];
        } else {
            cell.statusLabel.hidden = YES;
        }
        

        NSString *maleIconName = @"ClientIconMale";
        NSString *femaleIconName = @"ClientIconFemale";
        if (job.jobStatusRaw == JobStatusCompleted || job.jobStatusRaw == JobStatusWaitingForUpload  || job.jobStatusRaw == JobStatusUploadInProgress) {
            maleIconName = @"ClientIconMaleVerified";
            femaleIconName = @"ClientIconFemaleVerified";
        }
        if (job.genderRaw == GenderFemale) {
            cell.imageView.image = [UIImage imageNamed:femaleIconName];
        } else {
            cell.imageView.image = [UIImage imageNamed:maleIconName];
        }
        
        if (job.jobStatusRaw == JobStatusCompleted || job.jobStatusRaw == JobStatusWaitingForUpload  || job.jobStatusRaw == JobStatusUploadInProgress) {
            UIImage *clientPhoto = [job getClientPhoto];
            clientPhoto = [UIImage imageWithImage:clientPhoto scaledToFillToSize:CGSizeMake(36, 36)];
            clientPhoto = [UIImage roundedRectImageFromImage:clientPhoto size:CGSizeMake(36, 36) withCornerRadius:18];
            cell.imageView.image = clientPhoto;
            cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        }
        
        cell.completedIcon.hidden = job.jobStatusRaw != JobStatusCompleted;
        
        cell.accessibilityLabel = @"Client";
        cell.accessibilityValue = [job nameAsString];
        
        if ([[UploadManager sharedInstance] inProgress:job.jobGUID]) {
            float percentComplete = [[UploadManager sharedInstance] getProgress:job.jobGUID];
            cell.progressView.hidden = NO;
            [cell.progressView setProgress:percentComplete animated:NO];
        } else {
            cell.progressView.hidden = YES;
            [cell.progressView setProgress:0 animated:NO];
        }
        
        return cell;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self selectCellAtIndexPath:indexPath];
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSInteger offset = 0;
    if ([ZPSubscriber hasPermission:PermissionNameFetchJobs]) {
        offset = 1;
        if (section == 0) {
            return nil;
        }
    }

    NSDictionary *jobGroup = [self.jobGroups objectAtIndex:section - offset];
    return [jobGroup objectForKey:@"title"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([ZPSubscriber hasPermission:PermissionNameFetchJobs] && indexPath.section == 0) {
        return 30;
    } else {
        return tableView.rowHeight;
    }
}

#pragma mark UISearchBar
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	self.isSearching = NO;
	if (searchText.length > 0) {
		self.isSearching = YES;
	}
	[self loadJobs];
}

@end
