//
//  UIColor+NFColors.m
//  WotifIPhoneApp
//
//  Created by Damien Hill on 30/01/12.
//  Copyright (c) 2012 Wotif.com Pty Ltd. All rights reserved.
//
#import <UIKit/UIKit.h>

@implementation UIColor(NFColors)
+ (UIColor *)colorWithHex:(long)hexColor alpha:(float)opacity
{
    float red = ((float)((hexColor & 0xFF0000) >> 16))/255.0;
    float green = ((float)((hexColor & 0xFF00) >> 8))/255.0;
    float blue = ((float)(hexColor & 0xFF))/255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:opacity]; 
}  

@end 