//
//  IPDFCameraViewController.h
//  InstaPDF
//
//  Created by Maximilian Mackh on 06/01/15.
//  Copyright (c) 2015 mackh ag. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IPDFCameraViewControllerDelegate

- (void)takeSnapshotWithPath:(NSString *) imageFilePath;
- (void)autoCaptureProgress:(float)progress;

@end

typedef NS_ENUM(NSInteger,IPDFCameraViewType)
{
    IPDFCameraViewTypeBlackAndWhite,
    IPDFCameraViewTypeNormal
};

@interface IPDFCameraViewController : UIView

- (void)setupCameraView;

- (void)start;
- (void)stop;

@property (nonatomic,assign,getter=isBorderDetectionEnabled) BOOL enableBorderDetection;
@property (nonatomic,assign,getter=isTorchEnabled) BOOL enableTorch;
@property (nonatomic, assign) BOOL enableAutoCapture;
@property (nonatomic, assign) float targetAspectRatio;
@property (nonatomic, strong) id <IPDFCameraViewControllerDelegate> delegate;

@property (nonatomic,assign) IPDFCameraViewType cameraViewType;

- (void)focusAtPoint:(CGPoint)point completionHandler:(void(^)())completionHandler;

- (void)captureImage;
- (void)resumeCapture;

@end
