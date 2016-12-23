//
//  ZPEmptyView.h
//  zipID
//
//  Created by Damien Hill on 1/11/2013.
//  Copyright (c) 2013 zipID. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CustomAction)();

@interface ZPEmptyView : UIView

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, copy) CustomAction customAction;
@property (nonatomic, strong) IBOutlet UIButton *customActionButton;

+ (id)loadInstanceFromNib;

@end
