//
//  ZPTextField.m
//  zipID
//
//  Created by Damien Hill on 4/09/13.
//  Copyright (c) 2013 zipID. All rights reserved.
//

#import "ZPTextField.h"

@implementation ZPTextField

// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 10, 10);
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 10, 10);
}

@end
