//
//  ZPLocationService.h
//  ZipID
//
//  Created by Damien Hill on 15/06/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface ZPLocationService : NSObject

+ (ZPLocationService *)sharedInstance;

- (void)startUpdating;
- (void)stopUpdating;
- (CLLocation *)getCurrentLocation;
+ (BOOL)isEnabled;

@end
