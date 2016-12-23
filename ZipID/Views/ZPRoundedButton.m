//
//  ZPRoundedButton.m
//  ZipID
//
//  Created by Damien Hill on 4/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "ZPRoundedButton.h"

@implementation ZPRoundedButton

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.layer.cornerRadius = 2;
    }
    return self;
}

@end
