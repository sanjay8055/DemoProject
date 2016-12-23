//
//  ZPQuestionSet.m
//  ZipID
//
//  Created by Damien Hill on 2/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "ZPQuestionSet.h"
#import "ZPQuestion.h"

@implementation ZPQuestionSet

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        self.questionSetId = [dictionary objectForKey:@"questionSetId"];
        self.name = [dictionary objectForKey:@"name"];
        self.shortName = [dictionary objectForKey:@"shortName"];
        self.title = [dictionary objectForKey:@"title"];
        self.documentType = [dictionary objectForKey:@"documentType"];
        self.questions = [self createQuestions:(NSArray *)[dictionary objectForKey:@"questions"]];
		self.userSelectable = [[dictionary objectForKey:@"userSelectable"] boolValue];
    }
    return self;
}

- (NSArray *)createQuestions:(NSArray *)questionsArray
{
    NSMutableArray *questionsMutable = [NSMutableArray array];
    for (NSDictionary *questionDictionary in questionsArray) {
        ZPQuestion *question = [[ZPQuestion alloc] initWithDictionary:questionDictionary];
        [questionsMutable addObject:question];
        if (self.shortName) {
            question.title = self.shortName;
        }
        if (self.documentType) {
            question.testImage = [self testImageForQuestionSet:self.questionSetId];
            question.documentType = self.documentType;
            question.documentName = self.name;
        }
        question.documentId = self.questionSetId;
    }
    return [NSArray arrayWithArray:questionsMutable];
}

- (NSString *)testImageForQuestionSet:(NSString *)questionSetId
{
    if ([questionSetId isEqualToString:@"APP"] ||
        [questionSetId isEqualToString:@"FPV"] ||
        [questionSetId isEqualToString:@"FPN"]) {
        return @"test-passport";
    } else if ([questionSetId isEqualToString:@"ADL"]) {
        return @"test-drivers-licence";
    } else if ([questionSetId isEqualToString:@"ADL"]) {
        return @"test-drivers-licence";
    } else if ([questionSetId isEqualToString:@"MRG"]) {
        return @"test-marriage-certificate";
    } else if ([questionSetId isEqualToString:@"BTH"]) {
        return @"test-birth-certificate";
    } else if ([questionSetId isEqualToString:@"MED"]) {
        return @"test-medicare";
    } else if ([questionSetId isEqualToString:@"clientPhoto"]) {
        return @"test-client-photo";
    } else if ([questionSetId isEqualToString:@"clientAuthorisation"]) {
        return @"test-client-authorisation";
    } else {
        return @"test";
    }
}

@end
