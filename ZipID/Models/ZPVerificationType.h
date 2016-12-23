//
//  ZPVerificationType.h
//  ZipID
//
//  Created by Damien Hill on 8/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZPVerificationType : NSObject

@property (nonatomic, retain) NSString *verificationTypeId;
@property (nonatomic, assign) BOOL userSelectable;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *icon;
@property (nonatomic, retain) NSArray *questionSets;
@property (nonatomic, assign) BOOL voiWizard;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
