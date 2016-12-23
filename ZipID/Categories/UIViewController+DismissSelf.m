//
//  UIViewController+DismissSelf.m
//  ZipID
//
//  Created by Damien Hill on 2/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "UIViewController+DismissSelf.h"

@implementation UIViewController (DismissSelf)

- (IBAction)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)dismissAnimated:(BOOL)animated sender:(id)sender
{
    [self dismissViewControllerAnimated:animated completion:nil];
}

@end
