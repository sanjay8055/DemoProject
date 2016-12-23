//
//  ZPEmptyView.m
//  zipID
//
//  Created by Damien Hill on 1/11/2013.
//  Copyright (c) 2013 zipID. All rights reserved.
//

#import "ZPEmptyView.h"
#import "UIView+ZPAccessibilityId.h"

@interface ZPEmptyView ()

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *textLabel;

@end


@implementation ZPEmptyView

+ (id)loadInstanceFromNib
{
    UIView *result;
    NSArray* elements = [[NSBundle mainBundle] loadNibNamed:@"EmptyView" owner:nil options:nil];
    
    for (id anObject in elements) {
        if ([anObject isKindOfClass:[self class]]) {
            result = anObject;
            break;
        }
    }
    
    return result;
}

- (IBAction)executeCustomAction:(id)sender {
	self.customAction();
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

- (void)setText:(NSString *)text
{
    self.textLabel.text = text;
}

@end
