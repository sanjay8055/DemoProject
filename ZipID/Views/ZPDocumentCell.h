//
//  ZPDocumentCell.h
//  ZipID
//
//  Created by Damien Hill on 8/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZPDocumentCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *documentNameLabel;
@property (nonatomic, assign) BOOL checked;

@end
