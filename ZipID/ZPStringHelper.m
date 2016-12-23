//
//  ZPStringHelper.m
//  ZipID
//
//  Created by Richard S on 16/11/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "ZPStringHelper.h"

@implementation ZPStringHelper

+ (NSString *)platformSpecificImageNameForImageAttributes:(NSString *)imageName {
	NSString *scale = [UIScreen mainScreen].scale > 1 ? [NSString stringWithFormat:@"@%ix", (int)[UIScreen mainScreen].scale] : @"";
	NSString *platform = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"~iPad" : @"";
	NSString *formattedName = [NSString stringWithFormat:@"%@_%@%@", [[imageName lastPathComponent] stringByDeletingPathExtension], scale, platform];
	if ([[imageName lastPathComponent] pathExtension]) {
		NSString *fileType = [NSString stringWithFormat:@".%@", [[imageName lastPathComponent] pathExtension]];
		formattedName = [formattedName stringByAppendingString:fileType];
	}
	return formattedName;
}

+ (NSURL *)applicationDocumentsDirectory {
	return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
																								 inDomains:NSUserDomainMask] lastObject];
}

@end
