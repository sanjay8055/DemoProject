//
//  ZPReportGeneratorUnit.m
//  ZipID
//
//  Created by Brett Dargan on 1/06/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ZPReportGenerator.h"
#import <CommonCrypto/CommonCrypto.h>
#import "XRSA.h"

@interface ZPReportGeneratorUnit : XCTestCase
//- (NSData *)encryptDataForData:(NSData *)data
//                           key:(NSData *)key
//                            iv:(NSData *)iv
//                  error:(NSError **)error;
//
//- (NSData *)decryptData:(NSData *)data
//                    key:(NSData *)key
//                     iv:(NSData *)iv
//                  error:(NSError **)error;

@end

@implementation ZPReportGeneratorUnit

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    //NSString *directory = NSHomeDirectory();
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testRSAEncodingOfBinaryToUTF8EncryptedToBase64
{
    
    NSLog(@"==================================================================================");
//    NSData *key = [self randomDataOfLength: 32];
//    NSData *key = [@"secret00secret00secret00secret00" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *key = 0000000000000000000000000000000000000000000000000000000000000000;
//    NSData *iv = 00000000000000000000000000000000;
    
//    NSData *key = [self randomDataOfLength: 32];
    NSString* keyStr = [[NSString alloc] initWithData:key encoding:NSUTF8StringEncoding];

    NSString *publicKeyPath = [[NSBundle mainBundle] pathForResource:@"ios-public-key-3" ofType:@"der"];
    XRSA *rsa = [[XRSA alloc] initWithPublicKey:publicKeyPath];

    if (rsa != nil) {
        NSString *directory = NSHomeDirectory();

        NSString *encKeyBase64 = [rsa encryptToString: keyStr];
        NSLog(@"RSA: encryptedKey1: %@", encKeyBase64);
        NSString *keyPath = [directory stringByAppendingPathComponent:@"test-encryption-key-b64.txt"];
        [encKeyBase64 writeToFile:keyPath atomically:true encoding:NSUTF8StringEncoding error:nil];
        NSLog(@"RSA: wrote file to %@", keyPath);
        NSLog(@"RSA key Hex: %@", [self toHexString:key]);
        
        NSString *encrypteddataPath = [directory stringByAppendingPathComponent:@"test-encrypteddata.txt"];
        

        NSData *encryptedKey = [rsa encryptWithData: key];
        [encryptedKey writeToFile:encrypteddataPath atomically:true];
        NSLog(@"RSA: wrote file to %@", encrypteddataPath);

//        NSData *iv = [self randomDataOfLength: 16];

        [encryptedKey writeToFile:encrypteddataPath atomically:true];
        //[self encryptWithData:[content dataUsingEncoding:NS StringEncoding]]
//          NSString *ivPath = [directory stringByAppendingPathComponent:@"test-encryption-iv-b64.txt"];
    
//        NSString *encKeyBase64 = [rsa encryptToString: keyStr];
        
        NSString *encKey2Base64 = [rsa encryptToString: keyStr];
        NSLog(@"RSA: encryptedKey2: %@", encKey2Base64);
        
    }
    NSLog(@"==================================================================================");
    

}

- (void) testCrypto
{
    NSLog(@"==================================================================================");
    
}



- (NSData *)randomDataOfLength:(size_t)length {
    NSMutableData *data = [NSMutableData dataWithLength:length];
    
    int result = SecRandomCopyBytes(kSecRandomDefault,
                                    length,
                                    data.mutableBytes);
    NSAssert(result == 0, @"Unable to generate random bytes: %d",
             errno);
    
    return data;
}


- (NSString *) toHexString: (NSData*) data {
    NSMutableString *string = [NSMutableString stringWithCapacity:data.length * 3];
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop){
        for (NSUInteger offset = 0; offset < byteRange.length; ++offset) {
            uint8_t byte = ((const uint8_t *)bytes)[byteRange.location + offset];
                [string appendFormat:@"%02x", byte];
        }
    }];
    return string;
}

@end
