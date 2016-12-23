//
//  ZPMainViewController.m
//  ZipID
//
//  Created by Damien Hill on 6/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "ZPMainViewController.h"
#import "UIViewController+StoryboardHelper.h"
#import "ZPLoadingView.h"
#import "ZPApiClient+Methods.h"
#import "ZPSubscriber.h"
#import "ZPWebContentViewController.h"
#import "UIAlertView+Blocks.h"
#import "ZPLoginViewController.h"
#import "ZPClientListViewController.h"

@interface ZPMainViewController ()

@property (nonatomic, retain) ZPLoadingView *loadingView;
@property (nonatomic, assign) BOOL loginChecked;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

- (IBAction)login:(id)sender;

@end


@implementation ZPMainViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshView:)
                                                 name:@"didResetAppState"
                                               object:nil];
	
    [self onAppStart];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reauthenticateInvalidToken) name:@"tokenInvalid" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkSignIn) name:@"checkSignIn" object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) versionCheck
{
    CLS_LOG(@"Checking if app version is valid");
    [[ZPApiClient sharedInstance] checkVersionWithSuccess:^(NSString *versionNumber, NSURL *updateURL) {
        [[[UIAlertView alloc] initWithTitle:@"New version available"
                                    message:@"A new version of the ZipID app is available. To continue submitting verifications please update now."
                           cancelButtonItem:[RIButtonItem itemWithLabel:@"Later" action:nil]
                           otherButtonItems:[RIButtonItem itemWithLabel:@"Update now" action:^{
            [[UIApplication sharedApplication] openURL:updateURL];
        }], nil] show];
    } failure:^(NSError *error) {
        CLS_LOG(@"Version check error: %@", [error localizedDescription]);
    }];
}

- (void) onAppStart
{
    // Show welcome view on first run
    BOOL isFirstRun = [[NSUserDefaults standardUserDefaults] objectForKey:@"welcomeViewed"] == nil;
    if (isFirstRun) {
        CLS_LOG(@"Showing first run content");
        UIViewController *welcomeVC = [self getInitialVCForStoryboard:@"Welcome" universal:YES];
        [self presentViewController:welcomeVC animated:NO completion:nil];
    }
    
    self.loadingView = [ZPLoadingView loadInstanceFromNib];
    self.loadingView.loadingText = @"";
    
    [self versionCheck];
    
    if (!self.loginChecked) {
        self.loginChecked = YES;
        [self checkSignIn];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	[self.navigationController setToolbarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)refreshView:(NSNotification *)notification
{
    DebugLog(@"refreshView called");
	[self onAppStart];
	[self viewWillAppear:false];
	[self viewDidAppear:false];
}

- (void)reauthenticateInvalidToken {
    DebugLog(@"if loginCheck wasn't performed, don't reauthenticate? %d", (BOOL)self.loginChecked);
	if (!self.loginChecked) {
        return;
	}
	
	UINavigationController *navVC = [[UINavigationController alloc] init];
	ZPLoginViewController *loginVC = (ZPLoginViewController *)[self getView:@"loginViewController" forStoryboard:@"Main" universal:YES];
	[navVC pushViewController:loginVC animated:NO];
	loginVC.requiresReauthenticationInModal = YES;

    //added the below, so it is part of the view controller, not very confident that this is the main issue?
    [self.view.window.rootViewController.navigationController addChildViewController:navVC];
	[self presentViewController:navVC animated:YES completion:nil];
}

- (void)showLoadingView
{
    [self.loadingView showAnimated:NO overView:self.view];
}

- (void)hideLoadingView
{
    [self.loadingView hideAnimated:YES];
}

- (IBAction)login:(id)sender
{
    [self pushStoryboard:@"Clients" universal:YES];
}

- (void)checkSignIn {
    CLS_LOG(@"Checking sign in");
	if ([ZPSubscriber isSignedIn]) {
        
        NSMutableArray *VCs = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        
        BOOL ZPClientListControllerLoaded = FALSE;

        for(int i = 0; i < VCs.count; i++) {
            UIViewController *vc = VCs[i];
            
            if ([vc isKindOfClass:[ZPClientListViewController class]]) {
                ZPClientListControllerLoaded = TRUE;
                break;
            }
        }

        if (!ZPClientListControllerLoaded) {
            UIViewController *vc = [self getInitialVCForStoryboard:@"Clients" universal:YES];
            CLS_LOG(@"Pushing clients view controller");
            [self.navigationController pushViewController:vc animated:NO];
        }

        CLS_LOG(@"Checking if auth token is valid");
		[[ZPApiClient sharedInstance] validateTokenWithSuccess:^{
            CLS_LOG(@"Auth token valid or no internet connection");
			[[NSNotificationCenter defaultCenter] postNotificationName:@"subscriberPersmissionsUpdated" object:self];
		} failure:^(NSError *error) {
            CLS_LOG(@"Auth token error: %@", [error localizedDescription]);
			[[NSNotificationCenter defaultCenter] postNotificationName:@"tokenInvalid" object:self];
            //reload the client list.
		}];
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *vc;
    if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navVC = segue.destinationViewController;
        vc = [navVC.childViewControllers objectAtIndex:0];
    } else {
        vc = segue.destinationViewController;
    }
    
    if ([segue.identifier isEqualToString:@"Terms"] && [vc respondsToSelector:@selector(setContentPath:)]) {
        [vc performSelector:@selector(setContentPath:) withObject:@"terms"];
        [vc setTitle:@"Terms of use"];
    }
    
    if ([segue.identifier isEqualToString:@"About"] && [vc respondsToSelector:@selector(setContentPath:)]) {
        [vc performSelector:@selector(setContentPath:) withObject:@"about"];
        [vc setTitle:@"About"];
    }
    
    if ([segue.identifier isEqualToString:@"Signup"] && [vc respondsToSelector:@selector(setContentPath:)]) {
        [vc performSelector:@selector(setContentPath:) withObject:@"signup"];
        [vc setTitle:@"Sign up"];
    }
}


@end
