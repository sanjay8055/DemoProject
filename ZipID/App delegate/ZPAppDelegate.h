//
//  ZPAppDelegate.h
//  ZipID
//
//  Created by Damien Hill on 1/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (NSURL *)applicationDocumentsDirectory;

@end
