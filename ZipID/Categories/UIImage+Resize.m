//
//  UIImage+Resize.m
//
//  Created by Olivier Halligon on 12/08/09.
//  Copyright 2009 AliSoftware. All rights reserved.
//

#import "UIImage+Resize.h"

@implementation UIImage (ResizeCategory)

-(UIImage*)resizedImageToSize:(CGSize)dstSize
{
	CGImageRef imgRef = self.CGImage;
	// the below values are regardless of orientation : for UIImages from Camera, width>height (landscape)
	CGSize  srcSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef)); // not equivalent to self.size (which is dependant on the imageOrientation)!
	
    /* Don't resize if we already meet the required destination size. */
    if (CGSizeEqualToSize(srcSize, dstSize)) {
        return self;
    }
    
	CGFloat scaleRatio = dstSize.width / srcSize.width;
	UIImageOrientation orient = self.imageOrientation;
	CGAffineTransform transform = CGAffineTransformIdentity;
	switch(orient) {
			
		case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;
			
		case UIImageOrientationUpMirrored: //EXIF = 2
			transform = CGAffineTransformMakeTranslation(srcSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
			
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(srcSize.width, srcSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationDownMirrored: //EXIF = 4
			transform = CGAffineTransformMakeTranslation(0.0, srcSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
			
		case UIImageOrientationLeftMirrored: //EXIF = 5
			dstSize = CGSizeMake(dstSize.height, dstSize.width);
			transform = CGAffineTransformMakeTranslation(srcSize.height, srcSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI_2);
			break;  
			
		case UIImageOrientationLeft: //EXIF = 6  
			dstSize = CGSizeMake(dstSize.height, dstSize.width);
			transform = CGAffineTransformMakeTranslation(0.0, srcSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI_2);
			break;  
			
		case UIImageOrientationRightMirrored: //EXIF = 7  
			dstSize = CGSizeMake(dstSize.height, dstSize.width);
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI_2);
			break;  
			
		case UIImageOrientationRight: //EXIF = 8  
			dstSize = CGSizeMake(dstSize.height, dstSize.width);
			transform = CGAffineTransformMakeTranslation(srcSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI_2);
			break;  
			
		default:  
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];  
			
	}  
	
	/////////////////////////////////////////////////////////////////////////////
	// The actual resize: draw the image on a new context, applying a transform matrix
    if ([[UIScreen mainScreen] scale] == 2.0) {
        UIGraphicsBeginImageContextWithOptions(dstSize, YES, 2.0);
    } else {
        UIGraphicsBeginImageContext(dstSize);
    }
    
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
		CGContextScaleCTM(context, -scaleRatio, scaleRatio);
		CGContextTranslateCTM(context, -srcSize.height, 0);
	} else {  
		CGContextScaleCTM(context, scaleRatio, -scaleRatio);
		CGContextTranslateCTM(context, 0, -srcSize.height);
	}
	
	CGContextConcatCTM(context, transform);
	
	// we use srcSize (and not dstSize) as the size to specify is in user space (and we use the CTM to apply a scaleRatio)
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, srcSize.width, srcSize.height), imgRef);
	UIImage* resizedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return resizedImage;
}



/////////////////////////////////////////////////////////////////////////////



-(UIImage*)resizedImageToFitInSize:(CGSize)boundingSize scaleIfSmaller:(BOOL)scale
{
	// get the image size (independant of imageOrientation)
	CGImageRef imgRef = self.CGImage;
	CGSize srcSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef)); // not equivalent to self.size (which depends on the imageOrientation)!

	// adjust boundingSize to make it independant on imageOrientation too for farther computations
	UIImageOrientation orient = self.imageOrientation;  
	switch (orient) {
		case UIImageOrientationLeft:
		case UIImageOrientationRight:
		case UIImageOrientationLeftMirrored:
		case UIImageOrientationRightMirrored:
			boundingSize = CGSizeMake(boundingSize.height, boundingSize.width);
			break;
        default:
            // NOP
            break;
	}

	// Compute the target CGRect in order to keep aspect-ratio
	CGSize dstSize;
	
	if ( !scale && (srcSize.width < boundingSize.width) && (srcSize.height < boundingSize.height) ) {
		dstSize = srcSize; // no resize (we could directly return 'self' here, but we draw the image anyway to take image orientation into account)
	} else {		
		CGFloat wRatio = boundingSize.width / srcSize.width;
		CGFloat hRatio = boundingSize.height / srcSize.height;
		
		if (wRatio < hRatio) {
			dstSize = CGSizeMake(boundingSize.width, floorf(srcSize.height * wRatio));
		} else {
			dstSize = CGSizeMake(floorf(srcSize.width * hRatio), boundingSize.height);
		}
	}
		
	return [self resizedImageToSize:dstSize];
}





+ (UIImage *)imageWithImage:(UIImage *)image
               scaledToSize:(CGSize)newSize
                     inRect:(CGRect)rect
{
    //Determine whether the screen is retina
    if ([[UIScreen mainScreen] scale] == 2.0) {
        UIGraphicsBeginImageContextWithOptions(newSize, YES, 2.0);
    }
    else
    {
        UIGraphicsBeginImageContext(newSize);
    }
    
    //Draw image in provided rect
    [image drawInRect:rect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //Pop this context
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)imageWithImage:(UIImage *)image
          scaledToFitToSize:(CGSize)newSize
{
    //Only scale images down
    if (image.size.width < newSize.width && image.size.height < newSize.height) {
        return [image copy];
    }
    
    //Determine the scale factors
    CGFloat widthScale = newSize.width/image.size.width;
    CGFloat heightScale = newSize.height/image.size.height;
    
    CGFloat scaleFactor;
    
    //The smaller scale factor will scale more (0 < scaleFactor < 1) leaving the other dimension inside the newSize rect
    widthScale < heightScale ? (scaleFactor = widthScale) : (scaleFactor = heightScale);
    CGSize scaledSize = CGSizeMake(image.size.width * scaleFactor, image.size.height * scaleFactor);
    
    //Scale the image
    return [UIImage imageWithImage:image scaledToSize:scaledSize inRect:CGRectMake(0.0, 0.0, scaledSize.width, scaledSize.height)];
}

+ (UIImage *)imageWithImage:(UIImage *)image
         scaledToFillToSize:(CGSize)newSize
{
    //Only scale images down
    if (image.size.width < newSize.width && image.size.height < newSize.height) {
        return [image copy];
    }
    
    //Determine the scale factors
    CGFloat widthScale = newSize.width/image.size.width;
    CGFloat heightScale = newSize.height/image.size.height;
    
    CGFloat scaleFactor;
    
    //The larger scale factor will scale less (0 < scaleFactor < 1) leaving the other dimension hanging outside the newSize rect
    widthScale > heightScale ? (scaleFactor = widthScale) : (scaleFactor = heightScale);
    CGSize scaledSize = CGSizeMake(image.size.width * scaleFactor, image.size.height * scaleFactor);
    
    //Create origin point so that the center of the image falls into the drawing context rect (the origin will have negative component).
    CGPoint imageDrawOrigin = CGPointMake(0, 0);
    widthScale > heightScale ?  (imageDrawOrigin.y = (newSize.height - scaledSize.height) * 0.5) :
    (imageDrawOrigin.x = (newSize.width - scaledSize.width) * 0.5);
    
    
    //Create rect where the image will draw
    CGRect imageDrawRect = CGRectMake(imageDrawOrigin.x, imageDrawOrigin.y, scaledSize.width, scaledSize.height);
    
    //The imageDrawRect is larger than the newSize rect, where the imageDraw origin is located defines what part of
    //the image will fall into the newSize rect.
    return [UIImage imageWithImage:image scaledToSize:newSize inRect:imageDrawRect];
}

+ (UIImage*)roundedRectImageFromImage:(UIImage *)image
                                size:(CGSize)imageSize
                    withCornerRadius:(float)cornerRadius
{
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);   //  <= notice 0.0 as third scale parameter. It is important cause default draw scale ≠ 1.0. Try 1.0 - it will draw an ugly image..
    CGRect bounds=(CGRect){CGPointZero,imageSize};
    [[UIBezierPath bezierPathWithRoundedRect:bounds
                                cornerRadius:cornerRadius] addClip];
    [image drawInRect:bounds];
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return finalImage;
}

@end
