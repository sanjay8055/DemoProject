//
//  ZPNavigationBarWithProgress.m
//  zipID
//
//  Created by Damien Hill on 27/09/13.
//  Copyright (c) 2013 zipID. All rights reserved.
//

#import "ZPNavigationBarWithProgress.h"

@interface ZPNavigationBarWithProgress()

@property (nonatomic, retain) UIProgressView *progressView;

@end


@implementation ZPNavigationBarWithProgress

- (void)layoutSubviews
{
	[super layoutSubviews];
	if (!self.progressView && SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
		self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, 3)];
		self.progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.progressView.tintColor = [UIColor colorWithHex:0x8DC53E alpha:1];
		self.progressView.trackTintColor = [UIColor colorWithHex:0xE1E1E1 alpha:1];
		self.progressView.progress = 0;
		self.progressView.hidden = YES;
		[self addSubview:self.progressView];
	}
}

- (void)updateProgress:(float)progress
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        if (progress <= 0 || progress >= 1) {
            if (!self.progressView.hidden) {
                [UIView animateWithDuration:0.26 animations:^{
                    self.progressView.alpha = 0;
                } completion:^(BOOL finished) {
                    self.progressView.hidden = YES;
                }];
            }
        } else {
            self.progressView.alpha = 1;
            self.progressView.hidden = NO;
        }
        
        [self.progressView setProgress:progress animated:YES];
    }
}

@end
