//
//  ZPWelcomeViewController.m
//  ZipID
//
//  Created by Damien Hill on 29/08/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "ZPWelcomeViewController.h"

@interface ZPWelcomeViewController () <UIScrollViewDelegate>

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *pages;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;
@property (nonatomic, strong) IBOutlet UIButton *skipButton;
@property (nonatomic, strong) IBOutlet UIButton *startTutorialButton;
@property (nonatomic, retain) IBOutlet UIView *header;
@property (nonatomic, retain) IBOutlet UIView *footer;

@property (nonatomic, assign) BOOL hasStartedTutorial;

@end


@implementation ZPWelcomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.currentPage = 0;
    self.pageControl.numberOfPages = self.pages.count;
    self.footer.alpha = 0;
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    [self updateViews];    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[SEGAnalytics sharedAnalytics] screen:@"Welcome"];
}

- (IBAction)dismiss:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"welcomeViewed"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [super dismiss:sender];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (IBAction)nextPage:(id)sender
{
    CGFloat targetX = (self.currentPage + 1) * self.view.bounds.size.width;
    CGRect targetRect = CGRectMake(targetX, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [self.scrollView scrollRectToVisible:targetRect animated:YES];
}

- (void)updateViews
{
    if (self.currentPage > 0) {
        self.hasStartedTutorial = YES;
    }
    
    float fractionalPage = self.scrollView.contentOffset.x / self.view.bounds.size.width;
    
    if (fractionalPage <= 1) {
        
        // Get % of transition
        float page1AnimationPosition = (self.scrollView.contentOffset.x / self.view.bounds.size.width) * 100;
        if (page1AnimationPosition < 0) {
            page1AnimationPosition = 0;
        } else if (page1AnimationPosition > 100) {
            page1AnimationPosition = 100;
        }
        self.footer.alpha = page1AnimationPosition / 100;
        self.startTutorialButton.alpha = 1 - self.footer.alpha;
        return;
    }
    
    
    float lastPageStart = self.view.bounds.size.width * (self.pages.count - 2);
    
    // Get % of transition
    float lastPageAnimationPosition = ((self.scrollView.contentOffset.x - lastPageStart) / self.view.bounds.size.width) * 100;
    if (lastPageAnimationPosition < 0) {
        lastPageAnimationPosition = 0;
    }
    
    // Show / hide the header and footer
    float alpha = 1 - (lastPageAnimationPosition / 100);
    self.header.alpha = alpha;
    self.footer.alpha = alpha;
}

#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float fractionalPage = scrollView.contentOffset.x / CGRectGetWidth(self.view.frame);
    NSInteger page = roundf(fractionalPage);
    
    if (self.currentPage != page && page < self.pages.count) {
        self.currentPage = page;
        self.pageControl.currentPage = self.currentPage;
    }
    
    [self updateViews];
}

@end
