//
//  UIViewController+HideTitleView.m
//  ZipID
//
//  Created by Damien Hill on 6/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "UIViewController+HideTitleView.h"

@implementation UIViewController (HideTitleView)

- (void)hideTitleView
{
    // Hack to hide the title view but keep the title for use in back button
    UIView *emptyTitleView = [[UIView alloc] init];
    emptyTitleView.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = emptyTitleView;
}

@end
