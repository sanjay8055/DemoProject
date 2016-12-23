//
//  ZPImagePreviewViewController.m
//  ZipID
//
//  Created by Damien Hill on 9/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "ZPImagePreviewViewController.h"
#import "ZipID-Swift.h"

@interface ZPImagePreviewViewController () <UIScrollViewDelegate>

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@end


@implementation ZPImagePreviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ImageManager *imageManager = [[ImageManager alloc] init];
    self.imageView.image = [imageManager getImage:self.imageResponse.imageReference];
    
    if ([self.imageResponse.documentType isEqualToString:@"clientSignature"] ||
        [self.imageResponse.documentType isEqualToString:@"agentSignature"]) {
        self.view.backgroundColor = [UIColor whiteColor];
    }

    self.scrollView.contentSize = self.imageView.frame.size;

}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
}

@end
