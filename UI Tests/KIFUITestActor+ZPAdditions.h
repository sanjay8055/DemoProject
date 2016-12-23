//
//  KIFUITestActor+ZPAdditions.h
//  ZipID
//
//  Created by Damien Hill on 5/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "KIFUITestActor.h"

@interface KIFUITestActor (ZPAdditions)

- (void)login;
- (void)logout;
- (void)resetApp;
- (void)resetAppViaUI;
- (void)tollLogin;
- (void)remoteJobLogin;
- (void)stubTollJobs;

@end
