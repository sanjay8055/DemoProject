//
//  ISHPermissionRequestPhotoCamera.m
//  ISHPermissionKit
//
//  Created by Felix Lamouroux on 27.06.14.
//  Copyright (c) 2014 iosphere GmbH. All rights reserved.
//

#import "ISHPermissionRequestPhotoCamera.h"
#import "ISHPermissionRequest+Private.h"

@import AVFoundation;

@implementation ISHPermissionRequestPhotoCamera

- (ISHPermissionState)permissionState {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
        return ISHPermissionStateUnsupported;
    }
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authStatus) {
        case AVAuthorizationStatusAuthorized:
            return ISHPermissionStateAuthorized;

        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            return ISHPermissionStateDenied;
            
        case AVAuthorizationStatusNotDetermined:
            return [self internalPermissionState];
    }

}

- (void)requestUserPermissionWithCompletionBlock:(ISHPermissionRequestCompletionBlock)completion {
    if (![self mayRequestUserPermissionWithCompletionBlock:completion]) {
        return;
    }
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            ISHPermissionState state = granted ? ISHPermissionStateAuthorized : ISHPermissionStateDenied;
            completion(self, state, nil);
        });
    }];
}
@end
