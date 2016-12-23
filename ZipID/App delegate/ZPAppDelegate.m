//
//  ZPAppDelegate.m
//  ZipID
//
//  Created by Damien Hill on 1/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "ZPAppDelegate.h"
#import "ZPTextField.h"
#import <AFNetworkActivityLogger/AFNetworkActivityLogger.h>
#import "Job.h"
#import "Job+LocalAccessors.h"
#import "ZPPersistentEndpoint.h"
#import "ZPJobsManager.h"
#import <AFNetworking/AFNetworkReachabilityManager.h>
#import "ZPClientListViewController.h"
#import "ZPLoginViewController.h"
#import "ZPSettingsViewController.h"
#import "ZPMainViewController.h"
#import "ZPSubscriber.h"
#import "ZipID-Swift.h"
#import "ZPAppResetService.h"

@implementation ZPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    #if DEBUG
        DebugLog(@"Debug defined");
    #endif
    #if DEV
        DebugLog(@"DEV defined");
    #endif
    #if TEST
        DebugLog(@"TEST defined");
    #endif
    #if PROD
        DebugLog(@"PROD defined");
    #endif
    #if ENTERPRISE
        DebugLog(@"ENTERPRISE defined");
    #endif
    
    CLS_LOG(@"Setting up core data stack");
    [MagicalRecord setupAutoMigratingCoreDataStack];
    
    // Reset app for test builds
    #if DEV
    if ([[[NSProcessInfo processInfo] arguments] containsObject:@"RESET_APP"]) {
        DebugLog(@"Resetting app based on environment argument");
        [[ZPAppResetService sharedInstance] resetApp];
    }
    #endif
    
    #if !DEBUG
    [Fabric with:@[[Crashlytics class]]];
    if ([ZPSubscriber isSignedIn]) {
        [CrashlyticsKit setUserIdentifier:[ZPSubscriber sharedInstance].agentUserName];
    }
    #endif
    
    CLS_LOG(@"Clearing images directory");
    ImageManager *imageManager = [[ImageManager alloc] init];
    [imageManager removeAllImages];
    
    // Analytics
    CLS_LOG(@"Setting up analytics");
    NSString *analyticsWriteKey = @"K4rinCmrbTAjLYSG0lqZWFLrw5ATpSXa"; // Dev/Test key
    NSUInteger flushAt = 1;
    #if PROD
        analyticsWriteKey = @"A1HS0k6vk5htl5H1pDGom1DLkoRhh01Y"; // Prod key
        flushAt = 20;
    #endif
    SEGAnalyticsConfiguration *analyticsConfig = [SEGAnalyticsConfiguration configurationWithWriteKey:analyticsWriteKey];
    analyticsConfig.trackApplicationLifecycleEvents = YES;
    analyticsConfig.flushAt = flushAt;
    [SEGAnalytics setupWithConfiguration:analyticsConfig];
    
    CLS_LOG(@"Loading persistent endpoints");
    [self loadPersistentEndpoints];

    CLS_LOG(@"Performing update tasks");
	[self performUpdateTasks];
	[self setAppearanceDefaults];

    // Clear practice mode if user has completed steps
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"practiceCompleted"] == nil) {
        BOOL verificationCompleted = [[NSUserDefaults standardUserDefaults] objectForKey:@"verificationCompleted"] != nil;
        BOOL verificationUploaded = [[NSUserDefaults standardUserDefaults] objectForKey:@"verificationUploaded"] != nil;
        if (verificationCompleted && verificationUploaded) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"practiceCompleted"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    // Clear practice mode if first run and user has already added jobs
    BOOL practiceClientAdded = [[NSUserDefaults standardUserDefaults] objectForKey:@"practiceClientAdded"] != nil;
    if (!practiceClientAdded && [Job totalJobCount] > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"practiceClientAdded"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"verificationCompleted"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"verificationUploaded"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"practiceCompleted"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    #if DEV
    NSURL *documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
	NSLog(@"Documents Directory: %@", documentsDirectory);
    #endif

    CLS_LOG(@"Starting AFNetworking Reachability monitoring");
	[[AFNetworkReachabilityManager sharedManager] startMonitoring];

	return YES;
}

- (void)performUpdateTasks {
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *appBuild = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    
    BOOL isSameVersion = [[[NSUserDefaults standardUserDefaults] objectForKey:@"appVersion"] isEqualToString:appVersion];
    BOOL isSameBuild = [[[NSUserDefaults standardUserDefaults] objectForKey:@"appBuild"] isEqualToString:appBuild];
    
    if (isSameVersion && isSameBuild) return;
    
    if (!isSameVersion) {
        [[NSUserDefaults standardUserDefaults] setObject:appVersion forKey:@"appVersion"];
    }
    
    if (!isSameBuild) {
        [[NSUserDefaults standardUserDefaults] setObject:appBuild forKey:@"appBuild"];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    CLS_LOG(@"Application will terminate");
    [MagicalRecord cleanUp];
    ImageManager *imageManager = [[ImageManager alloc] init];
    [imageManager removeAllImages];
    [[SEGAnalytics sharedAnalytics] flush];
}

- (void)setAppearanceDefaults
{
    UIImage *textFieldBackground = [UIImage imageNamed:@"UITextFieldBackground"];
    textFieldBackground = [textFieldBackground resizableImageWithCapInsets:UIEdgeInsetsMake(4,4,4,4)];
    [[ZPTextField appearance] setBackground:textFieldBackground];
    [[ZPTextField appearance] setBorderStyle:UITextBorderStyleNone];
}

#pragma mark - Application's Documents directory
#define MY_BACKGROUND_SCREEN_TAG 1001
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [blurView setFrame:self.window.frame];
    blurView.tag = MY_BACKGROUND_SCREEN_TAG;
    
    [self.window addSubview:blurView];
    [[SEGAnalytics sharedAnalytics] flush];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    UIView *view = [self.window viewWithTag:MY_BACKGROUND_SCREEN_TAG];
    if (view != nil) {
        [UIView animateWithDuration:0.1 animations:^{
            [view setAlpha:0];
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
        }];
    }
    [[SEGAnalytics sharedAnalytics] flush];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    CLS_LOG(@"Application will enter foreground");
    UIViewController *rootVC = [application.keyWindow rootViewController];
    if ([rootVC isKindOfClass:UINavigationController.class]) {
        UINavigationController *navVC = (UINavigationController *)rootVC;
        if (navVC.viewControllers.count > 0) {
            UIViewController *vc = [navVC.viewControllers lastObject];
            if ([vc isKindOfClass:ZPClientListViewController.class]
                || [vc isKindOfClass:ZPLoginViewController.class]
                || [vc isKindOfClass:ZPSettingsViewController.class]
                || [vc isKindOfClass:ZPMainViewController.class]) {
                    CLS_LOG(@"Send application did become active notification");
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"applicationDidBecomeActive" object:self];
                    CLS_LOG(@"Send check sign in notification");
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkSignIn" object:self];
                    [self loadPersistentEndpoints];
            }
        }
    }
}

- (void)loadPersistentEndpoints
{
    CLS_LOG(@"Loading persistent endpoints");
    NSArray *endpoints = @[
                           @{@"path": @"questions", @"file": @"questions"},
                           @{@"path": @"verification-types", @"file": @"verification-types"},
                           @{@"path": @"toggles", @"file": @"toggles"},
                           @{@"path": @"document-pickers", @"file": @"document-pickers"}
                           ];
    [ZPPersistentEndpoint sharedInstance].endPointsToLoad = endpoints;
    [ZPPersistentEndpoint refreshDefaultsWithCompletion:^{
        CLS_LOG(@"Persistent endpoints loaded");
    }];

}
@end
