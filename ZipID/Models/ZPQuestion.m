    //
//  ZPQuestion.m
//  ZipID
//
//  Created by Damien Hill on 2/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "ZPQuestion.h"

@implementation ZPQuestion

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        self.question = [dictionary objectForKey:@"question"];
        self.detailText = [dictionary objectForKey:@"detailText"];
        self.urlToLoad = [dictionary objectForKey:@"urlToLoad"];
        self.type = [dictionary objectForKey:@"type"];
        self.required = [dictionary objectForKey:@"required"] ? YES : NO;
        self.title = [dictionary objectForKey:@"title"];
        self.options = [dictionary objectForKey:@"options"];
        self.autoCapture = [dictionary objectForKey:@"autoCapture"] ? YES : NO;
    }
    return self;
}

- (NSString *)getViewName
{
    NSString *viewName = nil;
    if ([self.type isEqualToString:@"photo"]) {
        viewName = @"PhotoQuestion";
    } else if ([self.type isEqualToString:@"signature"]) {
        viewName = @"SignatureQuestion";
    } else if ([self.type isEqualToString:@"yes"]) {
        viewName = @"CheckboxQuestion";
    } else if ([self.type isEqualToString:@"text"]) {
        viewName = @"TextQuestion";
    } else if ([self.type isEqualToString:@"textfield"]) {
        viewName = @"TextfieldQuestion";
    } else if ([self.type isEqualToString:@"confirm"]) {
        viewName = @"ConfirmQuestion";
    } else if ([self.type isEqualToString:@"confirmDeny"]) {
        viewName = @"ConfirmDenyQuestion";
    } else if ([self.type isEqualToString:@"multichoice"]) {
        viewName = @"MultiChoiceQuestion";
    }
	
    return viewName;
}

@end
