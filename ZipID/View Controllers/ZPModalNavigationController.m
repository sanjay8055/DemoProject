//
//  ZPModalNavigationController.m
//  ZipID
//
//  Created by Damien Hill on 30/09/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "ZPModalNavigationController.h"

@interface ZPModalNavigationController ()

@end

@implementation ZPModalNavigationController

// Fix for dismissing iPad in iOS7 from form sheet modal
// http://stackoverflow.com/questions/3124828/resignfirstresponder-not-hiding-keyboard-on-textfieldshouldreturn

- (BOOL)disablesAutomaticKeyboardDismissal
{
    return NO;
}

@end
