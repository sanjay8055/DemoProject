//
//  ZPImageResponse.h
//  ZipID
//
//  Created by Damien Hill on 9/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZPImageResponse : NSObject

@property (nonatomic, retain) NSString *imageReference;
@property (nonatomic, retain) NSString *documentId;
@property (nonatomic, retain) NSString *documentType;
@property (nonatomic, retain) NSString *documentName;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, assign) int questionIndex;

- (NSString *)imageName;

@end
