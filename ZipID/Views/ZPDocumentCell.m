//
//  ZPDocumentCell.m
//  ZipID
//
//  Created by Damien Hill on 8/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "ZPDocumentCell.h"

@interface ZPDocumentCell ()

@property (nonatomic, retain) IBOutlet UIImageView *selectedIcon;

@end


@implementation ZPDocumentCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    if (selected) {
        self.selectedIcon.image = [UIImage imageNamed:@"ClientCompleteIcon24"];
    } else {
        self.selectedIcon.image = nil;
    }

}


@end
