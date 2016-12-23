//
//  ImageManager.swift
//  ZipID
//
//  Created by Damien Hill on 29/02/2016.
//  Copyright © 2016 ZipID. All rights reserved.
//

import Foundation

@objc class ImageManager: NSObject {

    let JPG_QUALITY: CGFloat = 0.3
    let IMAGES_PATH = "/images/"
    
    func storeImage(image: UIImage) -> String? {
        let rotatedImage = fixImageRotation(image)
        let imageReference = NSUUID().UUIDString
        if let imageUrl = getImageUrl(imageReference),
            jpegData = UIImageJPEGRepresentation(rotatedImage, JPG_QUALITY)
        {
            let options: NSDataWritingOptions = [
                .DataWritingFileProtectionComplete,
                .DataWritingAtomic]
            do {
                try jpegData.writeToURL(imageUrl, options: options)
            } catch let error as NSError {
                print("Could not write file to disk: \(error)")
                return nil
            }
            return imageReference
        } else {
            return nil
        }
    }
    
    func getImage(imageReference: String) -> UIImage? {
        var image: UIImage? = nil
        if let imageUrl = getImageUrl(imageReference) {
            if let loadedImage = UIImage(contentsOfFile: imageUrl.path!) {
                image = loadedImage
            }
        }
        return image
    }
    
    func imageExists(imageReference: String) -> Bool {
        var exists = false
        if let imageUrl = getImageUrl(imageReference) {
            let fileManager = NSFileManager.defaultManager()
            if let imagePath = imageUrl.path {
                exists = fileManager.fileExistsAtPath(imagePath)
            }
        }
        return exists
    }
    
    func moveImage(imageReference: String, destUrl: NSURL) {
        let fileManager = NSFileManager.defaultManager()
        if let sourceUrl = getImageUrl(imageReference) {
            do {
                try fileManager.moveItemAtURL(sourceUrl, toURL: destUrl)
            } catch let error as NSError {
                print("Could not clear directory: \(error)")
            }
        }
    }
    
    func removeImage(imageReference: String) {
        if self.imageExists(imageReference) {
            let fileManager = NSFileManager.defaultManager()
            if let imageUrl = getImageUrl(imageReference) {
                do {
                    try fileManager.removeItemAtURL(imageUrl)
                } catch let error as NSError {
                    print("Could not remove image: \(error)")
                }
            }
        }
    }
    
    func removeAllImages() {
        let fileManager = NSFileManager.defaultManager()
        if let imagesPath = getImagesDirectoryUrl() {
            do {
                let directoryContents = try fileManager.contentsOfDirectoryAtPath(imagesPath.path!)
                for path in directoryContents {
                    let fullPath = imagesPath.URLByAppendingPathComponent(path)
                    try fileManager.removeItemAtURL(fullPath!)
                }
            } catch let error as NSError {
                print("Could not clear directory: \(error)")
            }
        }
    }
    
    private func fixImageRotation(image: UIImage) -> UIImage {
        if image.imageOrientation == .Up {
            return image
        }
        var transform = CGAffineTransformIdentity
        
        // We need to calculate the proper transformation to make the image upright.
        // Step 1: Rotate if Left/Right/Down
        switch image.imageOrientation {
        case .Down, .DownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
        case .Left, .LeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
        case .Right, .RightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2))
        default: break
        }
        
        // Step 2: Flip if mirrored
        switch image.imageOrientation {
        case .UpMirrored, .DownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
        case .LeftMirrored, .RightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
        default: break
        }
        
        // Step 3: Now we draw the underlying CGImage into a new context, applying the transform calculated above.
        let ctx = CGBitmapContextCreate(nil, Int(image.size.width), Int(image.size.height),
            CGImageGetBitsPerComponent(image.CGImage!), 0,
            CGImageGetColorSpace(image.CGImage!)!,
            CGImageGetBitmapInfo(image.CGImage!).rawValue)
        CGContextConcatCTM(ctx!, transform)
        switch image.imageOrientation {
        case .Left, .LeftMirrored, .Right, .RightMirrored:
            CGContextDrawImage(ctx!, CGRectMake(0, 0, image.size.height, image.size.width), image.CGImage!)
        default:
            CGContextDrawImage(ctx!, CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage!)
        }
        
        // And now we just create a new UIImage from the drawing context
        if let cgimg = CGBitmapContextCreateImage(ctx!) {
            return UIImage(CGImage: cgimg)
        } else {
            return image
        }
    }
    
    // MARK: Path URLs
    private func getImageUrl(imageReference: String) -> NSURL? {
        return getImagesDirectoryUrl()?.URLByAppendingPathComponent(imageReference + ".jpg")
    }
    
    private func getImagesDirectoryUrl() -> NSURL? {
        let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0])
        let imagesPath = documentsPath.URLByAppendingPathComponent(IMAGES_PATH)
        do {
            try NSFileManager.defaultManager().createDirectoryAtPath(imagesPath!.path!, withIntermediateDirectories: true, attributes: nil)
            return imagesPath
        } catch let error as NSError {
            print("Unable to create directory \(error.debugDescription)")
            return nil
        }
    }
    
}
