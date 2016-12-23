//
//  UIViewController+StoryboardHelper.h
//  ZipID
//
//  Created by Damien Hill on 2/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

@interface UIViewController (StoryboardHelper)

- (UIViewController *)getInitialVCForStoryboard:(NSString *)storyboardName;
- (UIViewController *)getView:(NSString *)viewName forStoryboard:(NSString *)storyboardName;
- (void)loadStoryboard:(NSString *)storyboardName;
- (void)pushStoryboard:(NSString *)storyboardName;
- (void)loadStoryboardAsFormSheet:(NSString *)storyboardName;

- (UIViewController *)getInitialVCForStoryboard:(NSString *)storyboardName universal:(BOOL)universal;
- (UIViewController *)getView:(NSString *)viewName forStoryboard:(NSString *)storyboardName universal:(BOOL)universal;
- (void)loadStoryboard:(NSString *)storyboardName universal:(BOOL)universal;
- (void)pushStoryboard:(NSString *)storyboardName universal:(BOOL)universal;
- (void)loadStoryboardAsFormSheet:(NSString *)storyboardName universal:(BOOL)universal;

@end
