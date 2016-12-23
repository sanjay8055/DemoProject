//
//  ZPImageResponse.m
//  ZipID
//
//  Created by Damien Hill on 9/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "ZPImageResponse.h"

@implementation ZPImageResponse

- (NSString *)imageName
{
    return [NSString stringWithFormat:@"%u-%@.jpg", self.questionIndex, self.documentId];
}

@end
