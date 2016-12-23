//
//  ZPLoadingView.m
//  zipID
//
//  Created by Damien Hill on 13/09/13.
//  Copyright (c) 2013 zipID. All rights reserved.
//

#import "ZPLoadingView.h"

@interface ZPLoadingView ()

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) IBOutlet UIButton *tryAgainButton;
@property (nonatomic, strong) IBOutlet UIButton *cancelButton;

@end


@implementation ZPLoadingView

+ (id)loadInstanceFromNib
{
    UIView *result;
    NSArray *elements = [[NSBundle mainBundle] loadNibNamed:@"LoadingView" owner:nil options:nil];
    
    for (id anObject in elements) {
        if ([anObject isKindOfClass:[self class]]) {
            result = anObject;
            break;
        }
    }
    
    return result;
}

- (void)haltLoadingDueToError {
	self.titleLabel.text = self.errorText;
	[UIView animateWithDuration:0.25 animations:^{
		self.activityIndicator.alpha = 0;
		self.tryAgainButton.alpha = 1;
		self.cancelButton.alpha = 1;
	}];
}

- (IBAction)tryAgain:(id)sender {
	self.tryAgainAction();
	
	[self.activityIndicator startAnimating];
	self.titleLabel.text = self.loadingText;
	[UIView animateWithDuration:0.25 animations:^{
		self.activityIndicator.alpha = 1;
		self.tryAgainButton.alpha = 0;
		self.cancelButton.alpha = 0;
	}];
}

- (IBAction)dismiss:(id)sender {
	[self.delegate loadingViewDidDismiss];
	[self hideAnimated:YES];
}

- (void)showAnimated:(BOOL)animated overView:(UIView *)sourceView
{
		self.titleLabel.text = self.loadingText;
		self.tryAgainButton.alpha = 0;
		self.cancelButton.alpha = 1;
    self.frame = sourceView.bounds;
    if (!animated) {
        [sourceView addSubview:self];
    } else {
        self.alpha = 0;
        self.transform = CGAffineTransformMakeScale(0.9, 0.9);
        [sourceView addSubview:self];
        [UIView animateWithDuration:0.26
                         animations:^{
                             self.alpha = 1;
                             self.transform = CGAffineTransformIdentity;
                         }];
    }
}

- (void)hideAnimated:(BOOL)animated
{
    if (!animated) {
        [self removeFromSuperview];
    } else {
        [UIView animateWithDuration:0.26
                         animations:^{
                             self.alpha = 0;
                             self.transform = CGAffineTransformMakeScale(1.05, 1.05);
                         } completion:^(BOOL finished) {
														 self.transform = CGAffineTransformIdentity;
                             [self removeFromSuperview];
                         }];
    }
}

- (void)hideContent:(BOOL)animated
{
    if (!animated) {
        self.activityIndicator.hidden = YES;
        self.titleLabel.hidden = YES;
    } else {
        [UIView animateWithDuration:0.26
                         animations:^{
                             self.activityIndicator.alpha = 0;
                             self.titleLabel.alpha = 0;
                         } completion:^(BOOL finished) {
                             self.activityIndicator.hidden = YES;
                             self.titleLabel.hidden = YES;
                         }];
    }
}


@end
