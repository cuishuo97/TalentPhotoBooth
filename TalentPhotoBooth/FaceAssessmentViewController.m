//
//  FaceAssessmentViewController.m
//  TalentPhotoBooth
//
//  Created by 崔硕 on 2018/12/21.
//  Copyright © 2018 崔硕. All rights reserved.
//

#import "FaceAssessmentViewController.h"
#import "AFNetworking/AFNetworking.h"
#import "ToolKit.h"
#import "SVProgressHUD/SVProgressHUD.h"
#import "Base64Singleton.h"

@interface FaceAssessmentViewController ()

@end

@implementation FaceAssessmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    [ProgressHUD showLoadingMessage:@"正在合成" view:self.navigationController.view];
    NSData *imageData;
    imageData = [photoCompress resetSizeOfImageData:self.imageView.image maxSize:65];
    self.imageView.image = [UIImage imageWithData: imageData];
    
    NSData *data = UIImageJPEGRepresentation(self.imageView.image, 1);
    NSString *base = [[Base64Singleton sharedManager] base64Encode:data];
    NSDictionary *_dic = @{@"app_id":[NSNumber numberWithInt:2110462408],
                           @"time_stamp":[NSNumber numberWithInteger:[[Utility getTimeStamp] integerValue]],
                           @"nonce_str":[Utility return32String],
                           @"image":base
                           };
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:_dic];
    
    NSString *sign = [Utility getReqSign:dic];
    
    [dic setObject:sign forKey:@"sign"];
    
    AFHTTPSessionManager *http = [AFHTTPSessionManager manager];
    NSDictionary *header = @{@"Content-Type":@"application/x-www-form-urlencoded"}; //是否需要加入请求头？
    [http POST:@"https://api.ai.qq.com/fcgi-bin/ptu/ptu_faceage" parameters:dic
       headers:nil
      progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
          [ProgressHUD hideHUD:self.navigationController.view];
          [feedBackGenerator feedBack:@"SUCCESS"];
          NSLog(@"response%@", responseObject);
          NSDictionary *dic = responseObject;
          NSDictionary *data = dic[@"data"];
          NSDictionary *image = data[@"image"];
          //NSLog(@"image!!!%@", image);
          
          NSString *image_str = [NSString stringWithFormat:@"%@", image];
          //NSLog(@"%@", image_str);
          self.imageView.image = [Utility stringToImage:image_str];
          
          
      } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
          [feedBackGenerator feedBack:@"ERROR"];
          NSLog(@"Fail");
          NSLog(@"%@", [error localizedDescription]);
                  [SVProgressHUD showErrorWithStatus:[@"合成失败\n" stringByAppendingString:[error localizedDescription]]];
      }];
}

- (IBAction)pressShare:(id)sender {
    if (self.imageView.image == NULL) {
        [SVProgressHUD showErrorWithStatus:@"请先上传照片"];
        return;
    }
                [self presentViewController:[shareViewController showShareVC:self.imageView.image] animated:YES completion:nil];
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


@end
