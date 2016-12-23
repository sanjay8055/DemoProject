//
//  ZPVerificationType.m
//  ZipID
//
//  Created by Damien Hill on 8/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "ZPVerificationType.h"

@implementation ZPVerificationType

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        self.verificationTypeId = [dictionary objectForKey:@"verificationTypeId"];
        self.name = [dictionary objectForKey:@"name"];
        if ([dictionary objectForKey:@"icon"]) {
            self.icon = [dictionary objectForKey:@"icon"];
        }
        self.questionSets = [dictionary objectForKey:@"questions"];
        self.userSelectable = [[dictionary objectForKey:@"userSelectable"] boolValue];
        if ([[dictionary objectForKey:@"documentWizard"] isEqualToString:@"voi"]) {
            self.voiWizard = YES;
        } else {
            self.voiWizard = NO;
        }
    }
    return self;
}

@end
