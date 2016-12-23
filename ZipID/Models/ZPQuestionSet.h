//
//  ZPQuestionSet.h
//  ZipID
//
//  Created by Damien Hill on 2/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZPQuestionSet : NSObject

@property (nonatomic, retain) NSString *questionSetId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *shortName;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSArray *questions;
@property (nonatomic, retain) NSString *documentType;
@property (nonatomic, assign) BOOL userSelectable;
@property (nonatomic, assign) BOOL isSelected;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
