//
//  ZPStringHelper.h
//  ZipID
//
//  Created by Richard S on 16/11/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZPStringHelper : NSObject

+ (NSURL *)applicationDocumentsDirectory;
+ (NSString *)platformSpecificImageNameForImageAttributes:(NSString *)imageName;

@end
