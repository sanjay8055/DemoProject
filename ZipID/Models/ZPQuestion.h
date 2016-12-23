//
//  ZPQuestion.h
//  ZipID
//
//  Created by Damien Hill on 2/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZPQuestion : NSObject

@property (nonatomic, retain) NSString *question;
@property (nonatomic, retain) NSString *detailText;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, assign) BOOL required;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *urlToLoad;
@property (nonatomic, retain) NSString *testImage;
@property (nonatomic, retain) NSString *documentId;
@property (nonatomic, retain) NSString *documentType;
@property (nonatomic, retain) NSString *documentName;
@property (nonatomic, retain) NSArray *options;
@property (nonatomic, assign) BOOL autoCapture;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (NSString *)getViewName;

@end
