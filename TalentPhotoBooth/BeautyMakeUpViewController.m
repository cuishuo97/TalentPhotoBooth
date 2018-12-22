//  美妆
//  BeautyMakeUpViewController.m
//  TalentPhotoBooth
//
//  Created by 崔硕 on 2018/12/8.
//  Copyright © 2018 崔硕. All rights reserved.
//

#import "BeautyMakeUpViewController.h"
#import "AFNetworking/AFNetworking.h"
#import "SVProgressHUD/SVProgressHUD.h"
#import "ToolKit.h"
#import "ScrollPicker/MLPickerScrollView.h"
#import "ScrollPicker/MLDemoItem.h"
#import "ScrollPicker/MLDemoModel.h"
#import "Base64Singleton.h"

#define kItemH 110
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define MLColor(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define kRGB236 MLColor(236, 73, 73, 1.0)

@interface BeautyMakeUpViewController ()<MLPickerScrollViewDataSource,MLPickerScrollViewDelegate,UIAlertViewDelegate>
{
    MLPickerScrollView *_pickerScollView;
    NSMutableArray *data;
    UIButton *sureButton;
}

@end

@implementation BeautyMakeUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    
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
- (IBAction)pressShare:(id)sender {
    if (self.imageView.image == NULL) {
        [SVProgressHUD showErrorWithStatus:@"请先上传照片"];
        return;
    }
        [self presentViewController:[shareViewController showShareVC:self.imageView.image] animated:YES completion:nil];
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
                           @"cosmetic":[self getSelectedIndex],
                           @"image":base
                           };
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:_dic];
    
    NSString *sign = [Utility getReqSign:dic];
    
    [dic setObject:sign forKey:@"sign"];
    
    AFHTTPSessionManager *http = [AFHTTPSessionManager manager];

    [http POST:@"https://api.ai.qq.com/fcgi-bin/ptu/ptu_facecosmetic" parameters:dic
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
          [ProgressHUD hideHUD:self.navigationController.view];
          [feedBackGenerator feedBack:@"ERROR"];
          NSLog(@"Fail");
          NSLog(@"%@", [error localizedDescription]);
                  [SVProgressHUD showErrorWithStatus:[@"合成失败\n" stringByAppendingString:[error localizedDescription]]];
      }];
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

-(NSNumber *) getSelectedIndex {
    return [NSNumber numberWithInteger:(long)_pickerScollView.seletedIndex+1];
}

#pragma mark - UI
- (void)setUpUI
{
    // 1.数据源
    data = [NSMutableArray array];
    NSArray *titleArray = @[@"芭比粉",@"清透",@"烟灰",@"自然",@"樱花粉",@"原宿红",@"闪亮",@"粉紫",@"粉嫩"];
    NSArray *titleImageArray = @[@"makeup_babifen",@"makeup_qingtou",@"makeup_yanhui",@"makeup_ziran",@"makeup_yinghuafen",@"makeup_yuansuhong",@"makeup_shanliang",@"makeup_fenzi",@"makeup_fennen"];
    
    for (int i = 0; i < titleArray.count; i++) {
        MLDemoModel *model = [[MLDemoModel alloc] init];
        model.dicountTitle = [titleArray objectAtIndex:i];
        model.dicountImageName = [titleImageArray objectAtIndex:i];
        [data addObject:model];
    }
    
    // 2.初始化
    _pickerScollView = [[MLPickerScrollView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 130, SCREEN_WIDTH, kItemH)];
    //_pickerScollView.backgroundColor = [UIColor lightGrayColor];
    _pickerScollView.itemWidth = _pickerScollView.frame.size.width / 5; //刚好显示5个的宽度
    _pickerScollView.itemHeight = kItemH;
    _pickerScollView.firstItemX = (_pickerScollView.frame.size.width - _pickerScollView.itemWidth) * 0.5;
    _pickerScollView.dataSource = self;
    _pickerScollView.delegate = self;
    [self.view addSubview:_pickerScollView];
    
    // 3.刷新数据
    [_pickerScollView reloadData];
    
    // 4.滚动到对应折扣
    self.discount = 0;//(NSInteger)arc4random()%10;
    /*if (self.discount) {
     NSInteger number = 0;
     for (int i = 0; i < data.count; i++) {
     MLDemoModel *model = [data objectAtIndex:i];
     if (model.dicountIndex == self.discount) {
     number = i;
     }
     }
     */
    NSInteger number = _discount;
    _pickerScollView.seletedIndex = number;
    [_pickerScollView scollToSelectdIndex:number];
    
}

#pragma mark - dataSource
- (NSInteger)numberOfItemAtPickerScrollView:(MLPickerScrollView *)pickerScrollView
{
    return data.count;
}

- (MLPickerItem *)pickerScrollView:(MLPickerScrollView *)pickerScrollView itemAtIndex:(NSInteger)index
{
    // creat
    MLDemoItem *item = [[MLDemoItem alloc] initWithFrame:CGRectMake(0, 0, pickerScrollView.itemWidth, pickerScrollView.itemHeight)];
    
    // assignment
    MLDemoModel *model = [data objectAtIndex:index];
    model.dicountIndex = index;//标记数据模型上的index 取出来赋值也行
    item.title = model.dicountTitle;
    item.imageName = model.dicountImageName;
    [item setGrayTitle];
    
    // tap
    item.PickerItemSelectBlock = ^(NSInteger d){
        [_pickerScollView scollToSelectdIndex:d];
    };
    
    return item;
}

- (void)pickerScrollView:(MLPickerScrollView *)menuScrollView
   didSelecteItemAtIndex:(NSInteger)index{
    
    NSLog(@" 点击后代理回调：didSelecteItemAtIndex :%ld",index);
    
}

#pragma mark - delegate
- (void)itemForIndexChange:(MLPickerItem *)item
{
    [item changeSizeOfItem];
}

- (void)itemForIndexBack:(MLPickerItem *)item
{
    [item backSizeOfItem];
}



@end

