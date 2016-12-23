//
//  ZPWebContentViewController.m
//  ZipID
//
//  Created by Damien Hill on 8/06/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "ZPWebContentViewController.h"

#if DEV || TEST
@interface NSURLRequest (DummyInterface)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host;
+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host;

@end
#endif

@interface ZPWebContentViewController () <UIWebViewDelegate, NSURLConnectionDelegate>

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) NSString *baseUrl;

@end


@implementation ZPWebContentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
#if DEV
    self.baseUrl = @"https://localhost:3001/app-content/";
    //    baseUrl = @"https://10.0.1.7:3001/";
#elif TEST
    self.baseUrl = @"https://test.zipid.com.au/app-content/";
#elif PROD
    self.baseUrl = @"https://zipid.com.au/app-content/";
#endif
    
    [self loadContent];
}

- (void)loadContent
{
    self.webView.hidden = YES;
    if (self.contentPath) {
        NSString *urlString = [NSString stringWithFormat:@"%@%@", self.baseUrl, self.contentPath];
        NSURL *requestUrl = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:requestUrl];
        
    #if DEV || TEST
        [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[requestUrl host]];
    #endif
        
        self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
        [self.webView loadRequest:request];
    }
}

#pragma mark = UIWebView delegate
- (BOOL)webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType
{
    if (inType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    webView.hidden = NO;
    webView.alpha = 0;
    [UIView animateWithDuration:0.26 animations:^{
        self.activityIndicator.alpha = 0;
        self.webView.alpha = 1;
    } completion:^(BOOL finished) {
        self.activityIndicator.hidden = YES;
        [self.activityIndicator stopAnimating];
    }];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    // TODO: handle errors
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.activityIndicator.hidden = YES;
    [self.activityIndicator stopAnimating];
    DebugLog(@"Error accessing server");
}

@end
