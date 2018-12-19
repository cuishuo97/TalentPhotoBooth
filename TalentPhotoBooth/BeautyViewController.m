//  美颜
//  BeautyViewController.m
//  TalentPhotoBooth
//
//  Created by 崔硕 on 2018/12/8.
//  Copyright © 2018 崔硕. All rights reserved.
//

#import "BeautyViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "AFNetworking/AFNetworking.h"
#import "SVProgressHUD/SVProgressHUD.h"
#import "ToolKit.h"
//#import "MBProgressHUD/MBProgressHUD.h"



@interface BeautyViewController ()

@end

@implementation BeautyViewController
- (IBAction)pressTest:(id)sender {
    if (self.imageView.image == NULL) {
        [SVProgressHUD showErrorWithStatus:@"请先"];
    }
    else {
            [self presentViewController:[shareViewController showShareVC:self.imageView.image] animated:YES completion:nil];
    }

}

- (IBAction)pressSelectPhoto:(id)sender {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:@"请选择照片来源" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *selectAlbum = [UIAlertAction actionWithTitle:@"从手机相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 判断是否可以打开相册/相机/相簿
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) [SVProgressHUD showErrorWithStatus:@"无法打开相册"];
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; // 设置控制器类型
        // UIImagePickerController继承UINavigationController实现UINavigationDelegate和UIImagePickerControllerDelegate
        picker.delegate = self; // 设置代理
        
        [self presentViewController:picker animated:YES completion:nil];
    }];
    
    UIAlertAction *selectCamera = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 判断是否可以打开相册/相机/相簿
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) [SVProgressHUD showErrorWithStatus:@"无法打开相册"];
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera; // 设置控制器类型
        // UIImagePickerController继承UINavigationController实现UINavigationDelegate和UIImagePickerControllerDelegate
        picker.delegate = self; // 设置代理
        
        [self presentViewController:picker animated:YES completion:nil];
    }];
    
    UIAlertAction *selectCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
        nil;
    }];
    
    [actionSheet addAction:selectAlbum];
    [actionSheet addAction:selectCamera];
    [actionSheet addAction:selectCancel];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

// 判断设备是否有摄像头
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

// 前面的摄像头是否可用
- (BOOL) isFrontCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

// 后面的摄像头是否可用
- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}


// 判断是否支持某种多媒体类型：拍照，视频
- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0){
        NSLog(@"Media type is empty.");
        return NO;
    }
    NSArray *availableMediaTypes =[UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL*stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

// 检查摄像头是否支持录像
- (BOOL) doesCameraSupportShootingVideos{
    return [self cameraSupportsMedia:(NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypeCamera];
}

// 检查摄像头是否支持拍照
- (BOOL) doesCameraSupportTakingPhotos{
    return [self cameraSupportsMedia:( NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

#pragma mark ~~~~~~~~~~ 相册文件选取相关 ~~~~~~~~~~
// 相册是否可用
- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary];
}

// 是否可以在相册中选择视频
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self cameraSupportsMedia:( NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

// 是否可以在相册中选择视频
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self cameraSupportsMedia:( NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

#pragma mark -- <UIImagePickerControllerDelegate>--
// 获取图片后的操作
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    // 销毁控制器
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    // 设置图片
    self.imageView.image = info[UIImagePickerControllerOriginalImage];
}

- (IBAction)pressUpload:(id)sender {
    
    if (self.imageView.image == NULL) {
        [SVProgressHUD showErrorWithStatus:@"照片？？？"];
        return;
    }
    
    [ProgressHUD showLoadingMessage:@"正在合成" view:self.navigationController.view];
    //[MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    NSData *imageData;
    imageData = [photoCompress resetSizeOfImageData:self.imageView.image maxSize:300];
    self.imageView.image = [UIImage imageWithData: imageData];
    
    NSString *str_original_image = [self image2DataURL:self.imageView.image];
    
    NSDictionary *dic = @{@"api_key" : @"41UmWTHFupY8jw-BRJ-mxP5qCJs8c5cu",
                          @"api_secret" : @"OF-wi5ImcMqS8W_P3wcO2q1xICkVuv2Y",
                          @"image_base64":str_original_image,
                          @"whitening":[NSNumber numberWithInt:[self.lblWhiteningRate.text intValue]],
                          @"smoothing":[NSNumber numberWithInt:[self.lblSmoothingRate.text intValue]]
                          };
        
    AFHTTPSessionManager *http = [AFHTTPSessionManager manager];
    [http POST:@"https://api-cn.faceplusplus.com/facepp/beta/beautify" parameters:dic headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //[SVProgressHUD dismiss];
        [ProgressHUD hideHUD:self.navigationController.view];
        [feedBackGenerator feedBack:@"SUCCESS"];
        NSDictionary *dic = responseObject;
        NSDictionary *result = dic[@"result"];
        
        NSString *str_result = [NSString stringWithFormat:@"%@", result];
        
        UIImage *temp = [self stringToImage:str_result];
        self.imageView.image = temp;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [ProgressHUD hideHUD:self.navigationController.view];
        NSLog(@"失败");
        NSLog(@"%@",[error localizedDescription]);
        [SVProgressHUD showErrorWithStatus:[@"合成失败\n" stringByAppendingString:[error localizedDescription]]];
    }];
}

- (BOOL) imageHasAlpha: (UIImage *) image
{
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(image.CGImage);
    return (alpha == kCGImageAlphaFirst ||
            alpha == kCGImageAlphaLast ||
            alpha == kCGImageAlphaPremultipliedFirst ||
            alpha == kCGImageAlphaPremultipliedLast);
}

// 图片转64base字符串
- (NSString *) image2DataURL: (UIImage *) image
{
    NSData *imageData = nil;
    NSString *mimeType = nil;
    
    if ([self imageHasAlpha: image]) {
        imageData = UIImagePNGRepresentation(image);
        mimeType = @"image/png";
    } else {
        imageData = UIImageJPEGRepresentation(image, 1.0f);
        mimeType = @"image/jpeg";
    }
    
    return [NSString stringWithFormat:@"data:%@;base64,%@", mimeType,
            [imageData base64EncodedStringWithOptions: 0]];
    
}

- (UIImage *)stringToImage:(NSString *)str {
    
    NSData * imageData =[[NSData alloc] initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    UIImage *photo = [UIImage imageWithData:imageData ];
    
    return photo;
    
}
- (IBAction)changedWhiteningRate:(id)sender {
    self.lblWhiteningRate.text = [NSString stringWithFormat:@"%.0f",self.sliderWhiteningRate.value];
}
- (IBAction)changedSmoothingRate:(id)sender {
    self.lblSmoothingRate.text = [NSString stringWithFormat:@"%.0f",self.sliderSmoothingRate.value];
}

@end
