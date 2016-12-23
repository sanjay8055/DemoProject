//
//  ZPPhotoQuestionViewController.m
//  ZipID
//
//  Created by Damien Hill on 2/04/2014.
//  Copyright (c) 2014 ZipID. All rights reserved.
//

@import ISHPermissionKit;
#import "ZPPhotoQuestionViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImage+Resize.h"
#import "ZPQuestion.h"
#import "ZPImageResponse.h"
#import "ZipID-Swift.h"
#import "ZPSubscriber.h"
#import "ZPImagePickerController.h"

@interface ZPPhotoQuestionViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, CameraTestDelegate, ISHPermissionsViewControllerDataSource>

@property (nonatomic) NSString *selectedImageReference;
@property (nonatomic, retain) IBOutlet UIImageView *previewImageView;
@property (nonatomic, retain) IBOutlet UIButton *clearButton;

- (IBAction)tapCameraButton:(id)sender;

@end


@implementation ZPPhotoQuestionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.clearButton.hidden = YES;
    self.previewImageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.selectedImageReference && self.previewImageView.image == nil) {
        [self loadPreviewImage:self.selectedImageReference];
    }
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    if (parent == nil) {
        if (self.selectedImageReference) {
            CLS_LOG(@"Removing image on navigating back");
            ImageManager *imageManager = [[ImageManager alloc] init];
            [imageManager removeImage:self.selectedImageReference];
        }
    }
    [super didMoveToParentViewController:parent];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self clearPreviewImage];
}

- (void)openCamera:(BOOL)animated
{
    CLS_LOG(@"Opening camera");
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
        [self selectTestImage];
        return;
    }
    
    // Check camera access is available
    ISHPermissionRequest *cameraPermissionRequest = [ISHPermissionRequest requestForCategory:ISHPermissionCategoryPhotoCamera];
    BOOL cameraAvailable = ([cameraPermissionRequest permissionState] == ISHPermissionStateAuthorized);
    if (cameraAvailable) {
        [self loadStandardCamera];
    } else {
        ISHPermissionsViewController *permissionsVC = [ISHPermissionsViewController permissionsViewControllerWithCategories:@[@(ISHPermissionCategoryPhotoCamera)] dataSource:self];
        __weak ZPPhotoQuestionViewController *photoQuestionVC = self;
        [permissionsVC setCompletionBlock:^{
            ISHPermissionRequest *locationPermissionRequest = [ISHPermissionRequest requestForCategory:ISHPermissionCategoryPhotoCamera];
            switch ([locationPermissionRequest permissionState]) {
                case ISHPermissionStateAuthorized:
                    [photoQuestionVC loadStandardCamera];
                    break;
                case ISHPermissionStateDenied:
                    [photoQuestionVC showPermissionHelp];
                    break;
                case ISHPermissionStateUnknown:
                    [photoQuestionVC showPermissionHelp];
                    break;
                default:
                    break;
            }
        }];
        if (permissionsVC) {
            permissionsVC.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentViewController:permissionsVC animated:YES completion:nil];
        } else {
            [self showPermissionHelp];
        }
    }
}

- (void)loadStandardCamera
{
    // Subclass to fix/work around iOS 8 + iOS 9 bug
    // http://stackoverflow.com/questions/26844432/how-to-find-out-what-causes-a-didhidezoomslider-error-on-ios-8
    ZPImagePickerController *cameraUI = [[ZPImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    cameraUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    cameraUI.allowsEditing = NO;
    cameraUI.delegate = self;
    [self presentViewController:cameraUI animated:YES completion:nil];
}

- (void)openTestCamera
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
        [self selectTestImage];
        return;
    }
       
    CameraTestViewController *vc = (CameraTestViewController *)[self getInitialVCForStoryboard:@"CameraTest" universal:YES];
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)tapCameraButton:(id)sender
{
    ZPQuestion *question = [self.job.questions objectAtIndex:self.questionIndex];
    BOOL autoCaptureEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"autoCapture"];
    if ([ZPSubscriber isFeatureEnabled:ToggleNameNewCamera] && autoCaptureEnabled && question.autoCapture) {
        [self openTestCamera];
    } else {
        [self openCamera:YES];
    }
}

- (IBAction)clearImage:(id)sender
{
    ImageManager *imageManager = [[ImageManager alloc] init];
    [imageManager removeImage:self.selectedImageReference];
    self.clearButton.hidden = YES;
    self.selectedImageReference = nil;
    self.previewImageView.image = nil;
    self.hasResponse = NO;
}

- (void)selectImage:(UIImage *)image
{
    CLS_LOG(@"Storing image");
    ImageManager *imageManager = [[ImageManager alloc] init];
    NSString *imageReference = [imageManager storeImage:image];
    if (self.selectedImageReference) {
        [imageManager removeImage:self.selectedImageReference];
    }
    self.selectedImageReference = imageReference;
    DebugLog(@"Stored image with reference %@", imageReference);

    [self loadPreviewImage:imageReference];
    
    self.clearButton.hidden = NO;
    self.hasResponse = YES;
}

- (void)loadPreviewImage:(NSString *)imageReference
{
    CLS_LOG(@"Loading preview image");
    ImageManager *imageManager = [[ImageManager alloc] init];
    UIImage *savedImage = [imageManager getImage:imageReference];
    self.previewImageView.image = savedImage;
}

- (void)clearPreviewImage
{
    self.previewImageView.image = nil;
}

/* Camera not available in simulator or tests so return a sample image instead */
- (void)selectTestImage
{
    ZPQuestion *question = [self.job.questions objectAtIndex:self.questionIndex];
    UIImage *testImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:question.testImage ofType:@"png"]];
    [self selectImage:testImage];
}

- (void)saveToResponse
{
    if (!self.selectedImageReference) {
        return;
    }

    CLS_LOG(@"Saving image to response");
    ZPQuestion *question = [self.job.questions objectAtIndex:self.questionIndex];
    
    ZPImageResponse *imageResponse = [[ZPImageResponse alloc] init];
    imageResponse.documentName = question.documentName;
    imageResponse.documentType = question.documentType;
    imageResponse.documentId = question.documentId;
    imageResponse.questionIndex = self.questionIndex;
    imageResponse.imageReference = self.selectedImageReference;
    
    if ([question.documentType isEqualToString:@"clientPhoto"]) {
        self.surveyResponse.clientPhoto = imageResponse;
    } else if ([question.documentType isEqualToString:@"id"]) {
        [self.surveyResponse.identificationDocumentsDictionary setObject:imageResponse forKey:[NSNumber numberWithInt:self.questionIndex]];
    } else if ([question.documentType isEqualToString:@"additional"]) {
        [self.surveyResponse.additionalDocumentsDictionary setObject:imageResponse forKey:[NSNumber numberWithInt:self.questionIndex]];
    } else if ([question.documentType isEqualToString:@"clientSignature"]) {
        self.surveyResponse.clientSignature = imageResponse;
    }
    
    [super saveToResponse];
}

- (void)removeFromResponse
{
    CLS_LOG(@"Removing image from response");
    ZPQuestion *question = [self.job.questions objectAtIndex:self.questionIndex];
    
    if ([question.documentType isEqualToString:@"clientPhoto"]) {
        self.surveyResponse.clientPhoto = nil;
    } else if ([question.documentType isEqualToString:@"id"]) {
        [self.surveyResponse.identificationDocumentsDictionary removeObjectForKey:[NSNumber numberWithInt:self.questionIndex]];
    } else if ([question.documentType isEqualToString:@"additional"]) {
        [self.surveyResponse.additionalDocumentsDictionary removeObjectForKey:[NSNumber numberWithInt:self.questionIndex]];
    }
}

- (void)showPermissionHelp
{
    PermissionRequestViewController *permissionsVC = (PermissionRequestViewController *)[self getInitialVCForStoryboard:@"Permissions" universal:YES];
    permissionsVC.permissionCategory = ISHPermissionCategoryPhotoCamera;
    permissionsVC.goToSettings = YES;
    permissionsVC.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:permissionsVC animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage;
    
    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        [self selectImage:originalImage];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CameraTestDelegate
- (void)didCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didSelectImage:(UIImage *)image
{
    [self selectImage:image];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ISHPermissionsViewControllerDataSource
- (ISHPermissionRequestViewController *)permissionsViewController:(ISHPermissionsViewController *)vc requestViewControllerForCategory:(ISHPermissionCategory)category
{
    return (PermissionRequestViewController *)[self getInitialVCForStoryboard:@"Permissions" universal:YES];
}

@end
