//
//  ZPVerificationCompleteViewController.m
//  ZipID
//
//  Created by Damien Hill on 6/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "ZPVerificationCompleteViewController.h"
#import "ZPNavigationBarWithProgress.h"
#import "ZPClientListViewController.h"

@interface ZPVerificationCompleteViewController ()

- (IBAction)dismissVerification:(id)sender;

@end


@implementation ZPVerificationCompleteViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	ZPNavigationBarWithProgress *navBar = (ZPNavigationBarWithProgress *)self.navigationController.navigationBar;
	[navBar updateProgress:1];
	[self.navigationItem setHidesBackButton:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[SEGAnalytics sharedAnalytics] screen:@"Verification complete"];
}

- (IBAction)dismissVerification:(id)sender
{
    CLS_LOG(@"Dismissing complete view controller");
    BOOL foundClientList = NO;
    for (UIViewController *vc in self.navigationController.childViewControllers) {
        if ([vc isKindOfClass:ZPClientListViewController.class]) {
            foundClientList = YES;
            [self.navigationController popToViewController:vc animated:YES];
            break;
        }
    }
    
    if (!foundClientList) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }

}

@end
