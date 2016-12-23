//
//  UIView+ZPAccessibilityId.m
//  ZipID
//
//  Created by Richard S on 2/11/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "UIView+ZPAccessibilityId.h"

@implementation UIView (ZPAccessibilityId)

- (NSString *)accessibilityId {
	return self.accessibilityIdentifier;
}

- (void)setAccessibilityId:(NSString *)accessibilityId {
	self.accessibilityIdentifier = accessibilityId;
}

@end
