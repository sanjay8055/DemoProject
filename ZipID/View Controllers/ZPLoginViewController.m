//
//  ZPLoginViewController.m
//  zipID
//
//  Created by Damien Hill on 12/09/13.
//  Copyright (c) 2013 zipID. All rights reserved.
//

#import "ZPLoginViewController.h"
#import "ZPLoadingView.h"
#import "ZPApiClient+Methods.h"
#import "ZPWebContentViewController.h"
#import "ZPSubscriber.h"
#import "ZipID-Swift.h"
#import "Job+LocalAccessors.h"

@interface ZPLoginViewController () <UIAlertViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UIButton *signInButton;
@property (nonatomic, strong) IBOutlet UITextField *agentIdTextfield;
@property (nonatomic, strong) IBOutlet UITextField *passwordTextfield;
@property (nonatomic, strong) ZPLoadingView *loadingView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *termsBottomSpaceConstraint;
@property (nonatomic, strong) IBOutlet UIButton *passwordToggleButton;
@property (nonatomic, strong) IBOutlet UIButton *rememberUsernameButton;

- (IBAction)signIn:(id)sender;

@end


@implementation ZPLoginViewController

- (void)viewDidLoad {
	[super viewDidLoad];
    CLS_LOG(@"Login view loaded");
    
    if ([ZPSubscriber sharedInstance].lastUsedUsername) {
        self.agentIdTextfield.text = [ZPSubscriber sharedInstance].lastUsedUsername;
    }
    [self.rememberUsernameButton setSelected:[ZPSubscriber sharedInstance].rememberUsername];

    BOOL showPassword = [[[NSUserDefaults standardUserDefaults] valueForKey:@"showPasswordToggle"] boolValue];
    [UIView performWithoutAnimation:^{
        if (showPassword) {
            [self.passwordToggleButton setTitle:@"HIDE" forState:UIControlStateNormal];
            [self.passwordTextfield setSecureTextEntry:NO];
        } else {
            [self.passwordToggleButton setTitle:@"SHOW" forState:UIControlStateNormal];
            [self.passwordTextfield setSecureTextEntry:YES];
        }
    }];
    
	[self handleReauthenticationUI];
}

- (void)handleReauthenticationUI
{
    CLS_LOG(@"Presenting reauth UI");
	if (self.requiresReauthenticationInModal) {
		self.agentIdTextfield.text = [ZPSubscriber sharedInstance].agentUserName;
		self.agentIdTextfield.enabled = NO;
		self.agentIdTextfield.textColor = [UIColor lightGrayColor];
        [self.passwordTextfield becomeFirstResponder];
	} else {
		self.navigationItem.leftBarButtonItem = nil;
	}
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self.agentIdTextfield.text isEqualToString:@""]) {
        [self.agentIdTextfield becomeFirstResponder];
    } else {
        [self.passwordTextfield becomeFirstResponder];
    }
    [[SEGAnalytics sharedAnalytics] screen:@"Login"];
}

- (IBAction)signOut:(id)sender
{
	[ZPSubscriber signOut];
	[super dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)signIn:(id)sender
{
    CLS_LOG(@"Tapped sign in button");
    self.signInButton.enabled = NO;
    if ([self isAgentIdValid] && [self isPasswordValid]) {
        [self.agentIdTextfield resignFirstResponder];
        [self.passwordTextfield resignFirstResponder];
        
        self.loadingView = [ZPLoadingView loadInstanceFromNib];
        self.loadingView.loadingText = @"Signing in";
        [self.loadingView showAnimated:YES overView:self.view];
    
        [self authenticate];
    } else {
        
        NSString *alertTitle, *alertMessage, *alertButton;
        if (![self isAgentIdValid]) {
            alertTitle = NSLocalizedString(@"SIGNIN_INVALID_EMAIL_TITLE", nil);
            alertMessage = NSLocalizedString(@"SIGNIN_INVALID_EMAIL_MESSAGE", nil);
            alertButton = NSLocalizedString(@"SIGNIN_INVALID_EMAIL_BUTTON", nil);
        } else if (![self isPasswordValid]) {
            alertTitle = NSLocalizedString(@"SIGNIN_INVALID_PASSWORD_TITLE", nil);
            alertMessage = NSLocalizedString(@"SIGNIN_INVALID_PASSWORD_MESSAGE", nil);
            alertButton = NSLocalizedString(@"SIGNIN_INVALID_PASSWORD_BUTTON", nil);
        }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                            message:alertMessage
                                                           delegate:self
                                                  cancelButtonTitle:alertButton
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (BOOL)isAgentIdValid
{
    return self.agentIdTextfield.text.length > 0;
}

- (BOOL)isPasswordValid
{
    return self.passwordTextfield.text.length > 0;
}

- (void)authenticate
{
    [self.loadingView hideContent:YES];
    
    NSString *username = [self.agentIdTextfield.text lowercaseString];
    NSString *password = self.passwordTextfield.text;
    
    DebugLog(@"Signing in");
    [[ZPApiClient sharedInstance] loginWithUsername:username password:password success:^{
        DebugLog(@"Signed in successfully");
        CLS_LOG(@"Signed in successfully");
        [self handleLoginSuccess];
        self.passwordTextfield.text = @"";
    } failure:^(NSError * error) {        
        DebugLog(@"Error signing in: %@", [error localizedDescription]);
        CLS_LOG(@"Error signing in: %@", [error localizedDescription]);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AUTHENTICATION_FAILED_TITLE", nil)
                                                            message:[error localizedDescription]
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        [self.loadingView hideAnimated:YES];
        self.loadingView = nil;
    }];
    
}

- (void)handleLoginSuccess {
	if (self.requiresReauthenticationInModal) {
		[self dismissViewControllerAnimated:YES completion:nil];
	} else {
        #if !ENTERPRISE
        BOOL practiceClientAdded = [[NSUserDefaults standardUserDefaults] objectForKey:@"practiceClientAdded"] != nil;
        if (!practiceClientAdded) {
            // Existing user
            if ([Job totalJobCount] > 0) {
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"practiceClientAdded"];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"verificationCompleted"];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"verificationUploaded"];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"practiceCompleted"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self pushStoryboard:@"Clients" universal:YES];
            } else {
                // First time run of app
                CLS_LOG(@"Adding practice client");
                [ClientService createPractice];
                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError * _Nullable error) {
                    CLS_LOG(@"Practice client added");
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"practiceClientAdded"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [self pushStoryboard:@"Clients" universal:YES];
                }];
            }
        } else {
            [self pushStoryboard:@"Clients" universal:YES];
        }
        #else
        [self pushStoryboard:@"Clients" universal:YES];
        #endif
	}
}

- (IBAction)togglePasswordVisible:(id)sender
{
    BOOL secure = !self.passwordTextfield.secureTextEntry;
    NSString *label = secure ? @"SHOW" : @"HIDE";
    [UIView performWithoutAnimation:^{
        [self.passwordToggleButton setTitle:label forState:UIControlStateNormal];
    }];
    BOOL isFirstResponder = self.passwordTextfield.isFirstResponder;
    if (isFirstResponder) [self.passwordTextfield resignFirstResponder];
    
    [self.passwordTextfield setSecureTextEntry:secure];
    [self.passwordTextfield becomeFirstResponder];
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:!secure] forKey:@"showPasswordToggle"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)forgottenPassword:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://zipid.com.au/subscriber/request-password-reset?iframe=true"]];
}

- (IBAction)toggleRememberUsername:(id)sender {
    BOOL rememberUsername = [ZPSubscriber sharedInstance].rememberUsername;
    [self.rememberUsernameButton setSelected:!rememberUsername];
    [[ZPSubscriber sharedInstance] setRememberUsername:!rememberUsername];
}

#pragma mark - Alert view delegate
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    self.signInButton.enabled = YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.passwordTextfield) {
        [self signIn:textField];
    } else if (textField == self.agentIdTextfield) {
        [self.passwordTextfield becomeFirstResponder];
    }
    return NO;
}

#pragma mark - Segues
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
    
    if ([segue.identifier isEqualToString:@"ForgotPassword"] && [vc respondsToSelector:@selector(setContentPath:)]) {
        [vc performSelector:@selector(setContentPath:) withObject:@"support"];
        [vc setTitle:@"Forgot password"];
    }
}

@end
