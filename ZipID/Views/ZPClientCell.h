//
//  ZPClientCell.h
//  zipID
//
//  Created by Damien Hill on 1/11/2013.
//  Copyright (c) 2013 zipID. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZPClientCell : UITableViewCell

@property (nonatomic) IBOutlet UIImageView *completedIcon;
@property (nonatomic) IBOutlet UIProgressView *progressView;
@property (nonatomic) IBOutlet UILabel *statusLabel;
@property (nonatomic) IBOutlet UILabel *practiceLabel;

@end
