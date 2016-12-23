//
//  ZPLoadingView.h
//  zipID
//
//  Created by Damien Hill on 13/09/13.
//  Copyright (c) 2013 zipID. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TryAgainAction)();

@protocol ZPLoadingViewProtocol

- (void)loadingViewDidDismiss;

@end

@interface ZPLoadingView : UIView

@property (nonatomic, retain) NSString *loadingText;
@property (nonatomic, weak) id <ZPLoadingViewProtocol> delegate;
@property (nonatomic, retain) NSString *errorText;
@property (nonatomic, copy) TryAgainAction tryAgainAction;

+ (id)loadInstanceFromNib;

- (void)showAnimated:(BOOL)animated overView:(UIView *)sourceView;
- (void)hideAnimated:(BOOL)animated;
- (void)hideContent:(BOOL)animated;
- (void)haltLoadingDueToError;

@end
