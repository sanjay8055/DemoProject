//
//  ZPLocationService.m
//  ZipID
//
//  Created by Damien Hill on 15/06/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "ZPLocationService.h"

@interface ZPLocationService() <CLLocationManagerDelegate>

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *currentLocation;

@end


@implementation ZPLocationService

static ZPLocationService *_sharedInstance;

- (id)init
{
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = 100; // Will only send us updates when difference between 2 updates is greater than 100 metres

        //iOS 7/8 support for location permissions
        SEL requestSelector = NSSelectorFromString(@"requestWhenInUseAuthorization");
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined &&
            [self.locationManager respondsToSelector:requestSelector]) {
            ((void (*)(id, SEL))[self.locationManager methodForSelector:requestSelector])(self.locationManager, requestSelector);
            [self.locationManager startUpdatingLocation];
        } else {
            [self.locationManager startUpdatingLocation];
        }
    }
    return self;
}

+ (ZPLocationService *)sharedInstance
{
    if (_sharedInstance == nil) {
        _sharedInstance = [[ZPLocationService alloc] init];
    }
    return _sharedInstance;
}

+ (BOOL)isEnabled
{
    return [CLLocationManager locationServicesEnabled];
}

- (void)startUpdating
{
    DebugLog(@"Started updating location");
    [self.locationManager startUpdatingLocation];
}

- (void)stopUpdating
{
    DebugLog(@"Stopped updating location");
    [self.locationManager stopUpdatingLocation];
}

- (CLLocation *)getCurrentLocation
{
    return self.currentLocation;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = [locations lastObject];
    if (![newLocation isEqual:self.currentLocation]) {
        DebugLog(@"New location: %f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
        self.currentLocation = newLocation;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    DebugLog(@"Failed to get location: %@", [error description]);
}

@end
