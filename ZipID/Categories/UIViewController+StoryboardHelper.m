//
//  UIViewController+StoryboardHelper.m
//  ZipID
//
//  Created by Damien Hill on 2/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "UIViewController+StoryboardHelper.h"

@implementation UIViewController (StoryboardHelper)

- (UIViewController *)getInitialVCForStoryboard:(NSString *)storyboardName
{
    storyboardName = [NSString stringWithFormat:@"%@_%@", [self getDeviceName], storyboardName];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
    UIViewController *vc = [storyboard instantiateInitialViewController];
    return vc;
}

- (UIViewController *)getView:(NSString *)viewName forStoryboard:(NSString *)storyboardName
{
    storyboardName = [NSString stringWithFormat:@"%@_%@", [self getDeviceName], storyboardName];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:viewName];
    return vc;
}

- (void)loadStoryboard:(NSString *)storyboardName
{
    storyboardName = [NSString stringWithFormat:@"%@_%@", [self getDeviceName], storyboardName];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
    UIViewController *vc = [storyboard instantiateInitialViewController];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)loadStoryboardAsFormSheet:(NSString *)storyboardName
{
    storyboardName = [NSString stringWithFormat:@"%@_%@", [self getDeviceName], storyboardName];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
    UIViewController *vc = [storyboard instantiateInitialViewController];
    [vc setModalPresentationStyle:UIModalPresentationFormSheet];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)pushStoryboard:(NSString *)storyboardName
{
    storyboardName = [NSString stringWithFormat:@"%@_%@", [self getDeviceName], storyboardName];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
    UIViewController *vc = [storyboard instantiateInitialViewController];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSString *)getDeviceName
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return @"iPad";
    } else {
        return @"iPhone";
    }
}


#pragma mark - Universal storyboard helpers

- (UIViewController *)getInitialVCForStoryboard:(NSString *)storyboardName universal:(BOOL)universal
{
    if (!universal) {
        return [self getInitialVCForStoryboard:storyboardName];
    } else {
        storyboardName = [NSString stringWithFormat:@"%@_%@", @"All", storyboardName];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
        UIViewController *vc = [storyboard instantiateInitialViewController];
        return vc;
    }
}

- (UIViewController *)getView:(NSString *)viewName forStoryboard:(NSString *)storyboardName universal:(BOOL)universal
{
    storyboardName = [NSString stringWithFormat:@"%@_%@", @"All", storyboardName];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:viewName];
    return vc;
}

- (void)loadStoryboard:(NSString *)storyboardName universal:(BOOL)universal
{
    storyboardName = [NSString stringWithFormat:@"%@_%@", @"All", storyboardName];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
    UIViewController *vc = [storyboard instantiateInitialViewController];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)loadStoryboardAsFormSheet:(NSString *)storyboardName universal:(BOOL)universal
{
    storyboardName = [NSString stringWithFormat:@"%@_%@", @"All", storyboardName];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
    UIViewController *vc = [storyboard instantiateInitialViewController];
    [vc setModalPresentationStyle:UIModalPresentationFormSheet];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)pushStoryboard:(NSString *)storyboardName universal:(BOOL)universal
{
    storyboardName = [NSString stringWithFormat:@"%@_%@", @"All", storyboardName];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
    UIViewController *vc = [storyboard instantiateInitialViewController];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
