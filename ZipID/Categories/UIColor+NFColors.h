//
//  UIColor+NFColors.h
//  WotifIPhoneApp
//
//  Created by Damien Hill on 30/01/12.
//  Copyright (c) 2012 Wotif.com Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (NFColors)
// Create a new UIColor instance using the following long value (see
// UIColor#colorWithHex for an example) and desired alpha value. 
// 1.0 for opaque, 0.0 for transparent.
// Example: Light gray color of EFEFEF [UIColor colorWithHex:0xefefef alpha:1.0]
+ (UIColor *)colorWithHex:(long)hexColor alpha:(float)opacity;

@end
