//
//  ZPConfirmQuestionViewController.m
//  ZipID
//
//  Created by Richard S on 16/11/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "ZPConfirmQuestionViewController.h"

@interface ZPConfirmQuestionViewController ()

@property (nonatomic, retain) UIButton *confirmButton;

@end

@implementation ZPConfirmQuestionViewController

- (void)viewDidLoad {
	[super viewDidLoad];
    self.hasResponse = NO;
    self.confirmButton.enabled = YES;
}

- (IBAction)didConfirm:(id)sender {
	[self next:self];
    self.confirmButton.enabled = NO;
}

@end