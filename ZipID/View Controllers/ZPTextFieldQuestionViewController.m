//
//  ZPTextFieldQuestionViewController.m
//  ZipID
//
//  Created by Damien Hill on 13/05/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

#import "ZPTextFieldQuestionViewController.h"
#import "ZPQuestion.h"
#import "ZPTextResponse.h"

@interface ZPTextFieldQuestionViewController () <UIScrollViewDelegate>

// TODO: Remove hardcoding of these fields and instead create textfields from question object
@property (nonatomic, retain) IBOutletCollection(UITextField) NSArray *textFields;
@property (nonatomic, retain) IBOutlet UITextField *firmNameTextField;
@property (nonatomic, retain) IBOutlet UITextField *dateOfBirthTextField;

@end


@implementation ZPTextFieldQuestionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    // TODO: Render textfields from question object
    [self.firmNameTextField becomeFirstResponder];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
//    for (UITextField *textField in self.textFields) {
//        [textField resignFirstResponder];
//    }
}

- (void)saveToResponse
{
    NSMutableDictionary *textFieldResponses = [NSMutableDictionary dictionary];
    
    // Firm name
    if (self.firmNameTextField.text) {
        ZPTextResponse *firmName = [[ZPTextResponse alloc] init];
        firmName.text = self.firmNameTextField.text;
        firmName.key = @"firmName";
        firmName.label = @"Firm name";
        firmName.questionIndex = self.questionIndex;
        [textFieldResponses setObject:firmName forKey:firmName.key];
    }
       
    // Date of birth
    if (self.dateOfBirthTextField.text) {
        ZPTextResponse *dateOfBirth = [[ZPTextResponse alloc] init];
        dateOfBirth.text = self.dateOfBirthTextField.text;
        dateOfBirth.key = @"dateOfBirth";
        dateOfBirth.label = @"Date of birth";
        dateOfBirth.questionIndex = self.questionIndex;
        [textFieldResponses setObject:dateOfBirth forKey:dateOfBirth.key];
    }
    
    self.surveyResponse.textResponsesDictionary = textFieldResponses;
    [super saveToResponse];
}

- (void)removeFromResponse
{
    self.surveyResponse.textResponsesDictionary = nil;
    [super removeFromResponse];
}

@end
