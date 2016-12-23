//
//  ZPOutlineButton.m
//  ZipID
//
//  Created by Damien Hill on 4/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "ZPOutlineButton.h"

@interface ZPOutlineButton ()

@property (nonatomic, retain) UIColor *outlineColor;

@end


@implementation ZPOutlineButton

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.layer.cornerRadius = 2;
        self.layer.borderWidth = 1;
        self.outlineColor = self.titleLabel.textColor;
        self.layer.borderColor = self.outlineColor.CGColor;
    }
    return self;
}


- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    UIColor *borderColor = self.outlineColor;
    if (highlighted) {
        borderColor = [self.outlineColor colorWithAlphaComponent:0.2];
    }
    self.layer.borderColor = borderColor.CGColor;
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    UIColor *borderColor = [UIColor colorWithHex:0xcccccc alpha:1];
    if (enabled) {
        borderColor = self.outlineColor;
    }
    self.layer.borderColor = borderColor.CGColor;
}

- (void)tintColorDidChange
{
    [super tintColorDidChange];
    self.layer.borderColor = self.tintColor.CGColor;
}

@end
