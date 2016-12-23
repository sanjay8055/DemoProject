//
//  ZPSettingsViewController.m
//  zipID
//
//  Created by Damien Hill on 13/09/13.
//  Copyright (c) 2013 zipID. All rights reserved.
//

#import "ZPSettingsViewController.h"
#import "Job.h"
#import "Agent.h"
#import "ZPSettingsCell.h"
#import "ZPAppResetService.h"
#import "ZPSubscriber.h"
#import "ZipID-Swift.h"

@interface ZPSettingsViewController () <UIAlertViewDelegate>

@property (nonatomic, retain) IBOutlet UITableViewCell *signOutCell;
@property (nonatomic, retain) IBOutlet UILabel *versionLabel;
@property (nonatomic, retain) IBOutlet UISwitch *testModeSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *autoCaptureSwitch;
@property (nonatomic, retain) IBOutlet UILabel *usernameLabel;
@property (nonatomic, retain) UIAlertView *signOutAlertView;
@property (nonatomic, retain) UIAlertView *resetAppAlertView;
@property (nonatomic, retain) IBOutlet UITableViewCell *testModeCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *autoCaptureCell;

@end


@implementation ZPSettingsViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.tableView.accessibilityIdentifier = @"Menu items";
    
    if ([ZPSubscriber sharedInstance].agentUserName) {
        self.usernameLabel.text = [ZPSubscriber sharedInstance].agentUserName;
    } else if ([ZPSubscriber sharedInstance].agentId) {
        self.usernameLabel.text = [ZPSubscriber sharedInstance].agentId;
    } else {
        self.usernameLabel.text = @"";
    }
    
    if (![ZPSubscriber hasPermission:PermissionNameTestMode]) {
        self.testModeCell.hidden = YES;
    }
    if (![ZPSubscriber isFeatureEnabled:ToggleNameNewCamera]) {
        self.autoCaptureCell.hidden = YES;
    }
     
	NSString *versionString = [NSString stringWithFormat:@"%@ Version %@ (build %@)",
                               [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"],
                               [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                               [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
    
    self.versionLabel.text = versionString;
	self.testModeSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"testMode"];
	self.autoCaptureSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"autoCapture"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[SEGAnalytics sharedAnalytics] screen:@"Settings"];
}

- (IBAction)signOut:(id)sender
{
    self.signOutAlertView = [[UIAlertView alloc] initWithTitle:@"Sign out?"
                                                        message:@"You will need an active internet connection to sign in again."
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Sign out", nil];
    [self.signOutAlertView show];
}

- (IBAction)tapResetApp:(id)sender
{
    self.resetAppAlertView = [[UIAlertView alloc] initWithTitle:@"Remove all ZipID data?"
                                                        message:@"This will permanently remove all ZipID data and settings from the device and sign you out."
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Remove", nil];
    [self.resetAppAlertView show];
}

- (IBAction)testModeSwitchChanged:(id)sender {
	[[NSUserDefaults standardUserDefaults] setBool:self.testModeSwitch.on forKey:@"testMode"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)autoCaptureSwitchChanged:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:self.autoCaptureSwitch.on forKey:@"autoCapture"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)showWelcome:(id)sender
{
    UIViewController *welcomeVC = [self getInitialVCForStoryboard:@"Welcome" universal:YES];
    [self presentViewController:welcomeVC animated:YES completion:nil];
}

- (IBAction)resetUploadQueue:(id)sender
{
    [[UploadManager sharedInstance] clearUploads];
    
    UIAlertView *resetUploadQueueAlert = [[UIAlertView alloc] initWithTitle:@"Upload queue has been reset"
                                                                    message:nil
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil];
    [resetUploadQueueAlert show];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController respondsToSelector:@selector(setContentPath:)]) {
        if ([sender isKindOfClass:ZPSettingsCell.class]) {
            ZPSettingsCell *cell = (ZPSettingsCell *)sender;
            NSString *contentPath = cell.contentPath;
            if ([segue.identifier isEqualToString:@"Guide"]) {
                if ([[ZPSubscriber sharedInstance].account.type isEqualToString:@"Broker"]) {
                    contentPath = @"broker-guide";
                } else {
                    contentPath = @"guide";
                }
            }
            [segue.destinationViewController performSelector:@selector(setContentPath:) withObject:contentPath];
            [segue.destinationViewController setTitle:cell.textLabel.text];
        }
    }
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == self.resetAppAlertView && buttonIndex == 1) {
        [[ZPAppResetService sharedInstance] resetApp:^{
            [self.navigationController popToRootViewControllerAnimated:NO];
            [self dismissAnimated:NO sender:nil];
        } failure:^(NSError *error) {
            [self dismiss:nil];
        }];
    } else if (alertView == self.signOutAlertView && buttonIndex == 1) {
        [ZPSubscriber signOut];
        [self dismissViewControllerAnimated:NO completion:nil];        
    }
}

#pragma mark - UITableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == self.signOutCell) {
        [self signOut:cell];
    }
}

@end
