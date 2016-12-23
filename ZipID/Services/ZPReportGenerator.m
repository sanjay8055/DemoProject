//
//  ZPReportGenerator.m
//  ZipID
//
//  Created by Damien Hill on 18/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "ZPReportGenerator.h"
#import "SSZipArchive.h"
#import <CommonCrypto/CommonCrypto.h>
#import <CommonCrypto/CommonKeyDerivation.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImage+Resize.h"
#import <PromiseKit/PromiseKit.h>
#import "XRSA.h"
#import <stdlib.h>
#import "ZipID-Swift.h"

#define JPG_QUALITY ((double) 0.3)

@implementation ZPReportGenerator

- (void)generateReportWithSuccess:(void (^)(void))success failure: (void (^)(void))failure
{
    CLS_LOG(@"Generating report");
    
    dispatch_promise(^{
        CLS_LOG(@"Creating report directory");
        [self createReportDirectory];
    }).then(^ {
        CLS_LOG(@"Writing report JSON to disk");
        [self writeReportJSONToDisk];
    }).then(^ {
        CLS_LOG(@"Creating client avatar");
        [self createClientAvatar];
    }).then(^ {
        CLS_LOG(@"Moving image files to report directory");
        [self moveImageFilesToReportDirectory];
    }).then(^ {
        CLS_LOG(@"Creating zip file");
        [self createZipFile];
    }).then(^ {
        CLS_LOG(@"Encrypting zip file");
        [self encryptZipFile];
    }).then(^ {
        CLS_LOG(@"Deleting source data");
        [self deleteSourceData];
        ImageManager *imageManager = [[ImageManager alloc] init];
        [imageManager removeAllImages];
    }).then(^ {
        CLS_LOG(@"Report generated successfully");
        success();
    }).catch(^ {
        CLS_LOG(@"Failed to generate report");
        failure();
    });
}

- (void)createReportDirectory
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSError *e = [[NSError alloc] init];
    [fileManager createDirectoryAtPath:[self reportSourcePath]
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:&e];
}

- (void)writeReportJSONToDisk
{
    DebugLog(@"Creating report json");
    NSString *filePath = [[self reportSourcePath] stringByAppendingPathComponent:@"report.json"];
    NSData *jsonData = [self.surveyResponse buildReportModel];

    NSError *error = [[NSError alloc] init];
    
    [jsonData writeToFile:filePath
                  options:NSDataWritingAtomic
                    error:&error];
}

- (void)moveImageFilesToReportDirectory {
    for (ZPImageResponse *imageResponse in self.surveyResponse.identificationDocuments) {
        [self moveImageFileToReportDirectory:imageResponse];
    }
    
    for (ZPImageResponse *imageResponse in self.surveyResponse.additionalDocuments) {
        [self moveImageFileToReportDirectory:imageResponse];
    }
    
    if (self.surveyResponse.clientPhoto) {
        [self moveImageFileToReportDirectory:self.surveyResponse.clientPhoto];
    }
    
    if (self.surveyResponse.clientSignature) {
        [self moveImageFileToReportDirectory:self.surveyResponse.clientSignature];
    }
    
    if (self.surveyResponse.agentSignature) {
        [self moveImageFileToReportDirectory:self.surveyResponse.agentSignature];
    }
}

- (void)moveImageFileToReportDirectory:(ZPImageResponse *)imageResponse
{
    CLS_LOG(@"Moving image file (%@) to report directory", imageResponse.imageName);
    NSURL *destUrl = [[self reportSourceUrl] URLByAppendingPathComponent:imageResponse.imageName];
    ImageManager *imageManager = [[ImageManager alloc] init];
    [imageManager moveImage:imageResponse.imageReference destUrl:destUrl];
}

- (void)createClientAvatar
{
    ImageManager *imageManager = [[ImageManager alloc] init];
    UIImage *clientPhoto = [imageManager getImage:self.surveyResponse.clientPhoto.imageReference];
    if (clientPhoto) {
        UIImage *avatarImage = [clientPhoto resizedImageToFitInSize:CGSizeMake(200, 200) scaleIfSmaller:YES];
        NSData *imageData = UIImageJPEGRepresentation(avatarImage, 0.7);
        NSString *filePath = [self clientAvatarPath];
        NSError *e = [[NSError alloc] init];
        [imageData writeToFile:filePath
                       options:NSDataWritingAtomic
                         error:&e];
    }
}

- (void)createZipFile
{
    [SSZipArchive createZipFileAtPath:[self reportZipPath] withContentsOfDirectory:[self reportSourcePath]];
}

- (void)encryptZipFile
{
    NSData *key = [self randomDataOfLength:kCCKeySizeAES256];
    NSData *iv = [self randomDataOfLength:kCCBlockSizeAES128];

    NSData *data = [NSData dataWithContentsOfFile:[self reportZipPath]];
    NSError *error;
    NSData *encryptedData = [self encryptDataForData:data key:key iv:iv error:&error];
    
    if (error) {
        DebugLog(@"Encryption error: %@", [error localizedDescription]);
        CLS_LOG(@"Encryption error: %@", [error localizedDescription]);
    }
    
    [encryptedData writeToFile:[self encryptedZipPath]
                   options:NSDataWritingAtomic
                     error:&error];
    
    DebugLog(@"wrote file to %@", [self encryptedZipPath]);
    if (error) {
        DebugLog(@"Encryption error: %@", [error localizedDescription]);
        CLS_LOG(@"Encryption error: %@", [error localizedDescription]);
    }

    //save key and IV together
//    NSString * keyIV = [ NSString stringWithFormat:@"%@,%@", [self toHexString:key], [self toHexString:iv]];
    
    NSString *publicKeyPath = [[NSBundle mainBundle] pathForResource:@"ios-public-key-3" ofType:@"der"];
    XRSA *rsa = [[XRSA alloc] initWithPublicKey:publicKeyPath];
    
    if (rsa != nil) {
        DebugLog(@"key Hex: %@",[self toHexString:key]);
        NSData *encryptedKey = [rsa encryptWithData: key];
        NSString *base64EncKey = [encryptedKey base64EncodedStringWithOptions:0];
        DebugLog(@"encryptedKey: %@", base64EncKey);
        [base64EncKey writeToFile:[self encryptedKeyPath] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        DebugLog(@"wrote key to: %@", [self encryptedKeyPath]);
        
        DebugLog(@"iv Hex: %@",[self toHexString:iv]);
        NSData *encryptedIV = [rsa encryptWithData: iv];
        NSString *base64encIV = [encryptedIV base64EncodedStringWithOptions:0];
        [base64encIV writeToFile:[self encryptedIVPath] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        DebugLog(@"wrote file to %@", [self encryptedIVPath]);
        
    } else {
        DebugLog(@"XRSA Error");
        CLS_LOG(@"XRSA Error");
    }
}

- (NSData *)randomDataOfLength:(size_t)length {
    NSMutableData *data = [NSMutableData dataWithLength:length];
    
    int result = 0;
    result = SecRandomCopyBytes(kSecRandomDefault,
                                    length,
                                    data.mutableBytes);
    NSAssert(result == 0, @"Unable to generate random bytes: %d", errno);
    
    return data;
}

- (NSString *) toHexString: (NSData*) data {
    NSMutableString *string = [NSMutableString stringWithCapacity:data.length * 3];
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop){
        for (NSUInteger offset = 0; offset < byteRange.length; ++offset) {
            uint8_t byte = ((const uint8_t *)bytes)[byteRange.location + offset];
            if (string.length == 0)
                [string appendFormat:@"%02x", byte];
            else
                [string appendFormat:@" %02x", byte];
        }
    }];
    return string;
}

- (void)deleteSourceData
{
    DebugLog(@"Deleting source data");
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSError *error = [[NSError alloc] init];
    [fileManager removeItemAtPath:[self reportSourcePath] error:&error];
    [fileManager removeItemAtPath:[self reportZipPath] error:&error];
}

- (NSData *)encryptDataForData:(NSData *)data
                           key:(NSData *)key
                            iv:(NSData *)iv
                         error:(NSError **)error
{
    NSAssert(key, @"key must not be NULL");
    NSAssert(iv, @"IV must not be NULL");
    
    size_t outLength;
    NSMutableData *
    cipherData = [NSMutableData dataWithLength:data.length +
                  kCCKeySizeAES128];
    //should this be key size?
    
    CCCryptorStatus
    result = CCCrypt(kCCEncrypt,
                     kCCAlgorithmAES,
                     kCCOptionPKCS7Padding,
                     key.bytes,
                     kCCKeySizeAES256,
                     iv.bytes,
                     data.bytes,
                     data.length,
                     cipherData.mutableBytes,
                     cipherData.length,
                     &outLength);
    
    if (result == kCCSuccess) {
        cipherData.length = outLength;
    }
    else {
        return nil;
    }
    
    return cipherData;
}


- (NSData *)decryptData:(NSData *)cipherData
                    key:(NSData *)key
                     iv:(NSData *)iv
                  error:(NSError **)error
{
    
    size_t bufferSize = [cipherData length] + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);
    size_t decryptedSize = 0;
    
    CCCryptorStatus result = CCCrypt(kCCDecrypt,
                                     kCCAlgorithmAES,
                                     kCCOptionPKCS7Padding,
                                     key.bytes,
                                     kCCKeySizeAES256,
                                     iv.bytes,
                                     cipherData.bytes,
                                     cipherData.length,
                                     buffer,
                                     bufferSize,
                                     &decryptedSize );
    
    
    if ( result == kCCSuccess ) {
		return [NSData dataWithBytesNoCopy:buffer length:decryptedSize];
    } else {
        free(buffer);
        return nil;
    }
    
}

#pragma mark - Helpers



#pragma mark - Paths

- (NSString *)keyPath
{
    return [[self applicationDocumentsDirectory].path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", self.surveyResponse.job.jobGUID]];
}

- (NSString *)encryptedZipPath
{
    return [[self applicationDocumentsDirectory].path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip.enc", self.surveyResponse.job.jobGUID]];
}

- (NSString *)encryptedKeyPath
{
    return [[self applicationDocumentsDirectory].path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt.enc", self.surveyResponse.job.jobGUID]];
}

- (NSString *)encryptedIVPath
{
    return [[self applicationDocumentsDirectory].path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-iv.txt.enc", self.surveyResponse.job.jobGUID]];
}

- (NSString *)decipheredZipPath
{
    return [[self applicationDocumentsDirectory].path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-orig-dec.zip", self.surveyResponse.job.jobGUID]];
}


- (NSString *)reportZipPath
{
    return [[self applicationDocumentsDirectory].path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip", self.surveyResponse.job.jobGUID]];
}

- (NSString *)reportSourcePath
{
    return [[self applicationDocumentsDirectory].path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", self.surveyResponse.job.jobGUID]];
}

- (NSURL *)reportSourceUrl
{
    return [[self applicationDocumentsDirectory].URLByStandardizingPath URLByAppendingPathComponent:[NSString stringWithFormat:@"%@", self.surveyResponse.job.jobGUID]];
}


- (NSString *)clientAvatarPath
{
    return [[self applicationDocumentsDirectory].path stringByAppendingPathComponent:[NSString stringWithFormat:@"avatar-%@.jpg", self.surveyResponse.job.jobGUID]];
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

@end
