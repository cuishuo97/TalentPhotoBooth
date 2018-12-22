//
//  wipeBackgroundViewController.m
//  TalentPhotoBooth
//
//  Created by 崔硕 on 2018/12/20.
//  Copyright © 2018 崔硕. All rights reserved.
//

#import "wipeBackgroundViewController.h"
#import "SVProgressHUD/SVProgressHUD.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "AFNetworking/AFNetworking.h"
#import "ToolKit.h"
#import "Base64Singleton.h"

@interface wipeBackgroundViewController () {
    NSString *accessToken;
}

@end
//24.428835fc7cc38ae1b90ca0a12b5e70a2.2592000.1548059108.282335-15236786
@implementation wipeBackgroundViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    accessToken = @"sjhd";
    [self getAccessToken];
    NSLog(@"out %@", accessToken);
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:@"请选择照片来源" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *selectAlbum = [UIAlertAction actionWithTitle:@"从手机相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 判断是否可以打开相册/相机/相簿
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) [SVProgressHUD showErrorWithStatus:@"无法打开相册"];
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum; // 设置控制器类型
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
- (IBAction)pressUpload:(id)sender {
    if (self.imageView.image == NULL) {
        [SVProgressHUD showErrorWithStatus:@"请先上传照片"];
        return;
    }
    NSData *imageData;
    imageData = [photoCompress resetSizeOfImageData:self.imageView.image maxSize:65];
    self.imageView.image = [UIImage imageWithData: imageData];
    
    NSData *data = UIImageJPEGRepresentation(self.imageView.image, 1);
    NSString *base = [[Base64Singleton sharedManager] base64Encode:data];
    
    if (self.imageView.image == NULL) {
        [SVProgressHUD showErrorWithStatus:@"请先上传照片"];
        return;
    }
    
    [ProgressHUD showLoadingMessage:@"正在合成" view:self.navigationController.view];
    //[MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    NSDictionary *dic = @{@"image":base
                          };
    
    AFHTTPSessionManager *http = [AFHTTPSessionManager manager];
    [http POST:@"https://aip.baidubce.com/rest/2.0/image-classify/v1/body_seg?access_token=24.428835fc7cc38ae1b90ca0a12b5e70a2.2592000.1548059108.282335-15236786" parameters:dic headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [ProgressHUD hideHUD:self.navigationController.view];
        [feedBackGenerator feedBack:@"SUCCESS"];
        NSLog(@"%@",responseObject);
        NSDictionary *dic = responseObject;
        NSDictionary *foreground = dic[@"foreground"];
        
        NSString *str_result = [NSString stringWithFormat:@"%@", foreground];
        
        UIImage *temp = [self stringToImage:str_result];
        self.imageView.image = temp;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [ProgressHUD hideHUD:self.navigationController.view];
        [feedBackGenerator feedBack:@"ERROR"];
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

- (IBAction)pressShare:(id)sender {
    if (self.imageView.image == NULL) {
        [SVProgressHUD showErrorWithStatus:@"请先上传照片"];
    }
    else {
        [self presentViewController:[shareViewController showShareVC:self.imageView.image] animated:YES completion:nil];
    }

}

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




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)getAccessToken {
    //static NSString *accessToken;
    NSDictionary *dic = @{@"grant_type":@"client_credentials",
                          @"client_id":@"GzQ2N47x2i9wkyfTP75o3FIh",
                          @"client_secret":@"PaQyEZcxm3dsPvyzWVzDThrw4q4ePtkM"
                          };
    
    AFHTTPSessionManager *http = [AFHTTPSessionManager manager];
    [http POST:@"https://aip.baidubce.com/oauth/2.0/token" parameters:dic headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //NSLog(@"%@", responseObject);
        NSDictionary *dic = responseObject;
        NSDictionary * result = dic[@"access_token"];
        
        accessToken = [NSString stringWithFormat:@"%@", result];
        NSLog(@"in %@", accessToken);
        
        

        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Fail");
    }];
    
    //NSLog(@"outtt %@", accessToken);
    //return self->accessToken;
 
}





@end
