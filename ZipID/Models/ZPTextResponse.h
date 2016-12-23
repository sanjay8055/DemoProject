//
//  ZPTextResponse.h
//  ZipID
//
//  Created by Damien Hill on 27/05/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZPTextResponse : NSObject

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *label;
@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *question;
@property (nonatomic, assign) int questionIndex;

@end
