//
//  ZPImagePickerController.m
//  ZipID
//
//  Created by Damien Hill on 6/06/2016.
//  Copyright © 2016 ZipID. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZPImagePickerController.h"

@implementation ZPImagePickerController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self clearZoomSliderDelegateForClass:[self sliderClass] subviews:self.view.subviews];
}

- (void)clearZoomSliderDelegateForClass:(Class)sliderClass subviews:(NSArray *)subviews {
    for (UIView *subview in subviews) {
        if ([subview isKindOfClass:sliderClass] && [subview respondsToSelector:@selector(setDelegate:)]) {
            [subview performSelector:@selector(setDelegate:) withObject:nil];
            return;
        } else {
            [self clearZoomSliderDelegateForClass:sliderClass subviews:subview.subviews];
        }
    }
}

- (Class)sliderClass {
    for (NSString* prefix in @[@"CAM", @"CMK"]) {
        Class zoomClass = NSClassFromString([prefix stringByAppendingString:@"ZoomSlider"]);
        if (zoomClass != Nil) {
            return zoomClass;
        }
    }
    return Nil;
}

@end