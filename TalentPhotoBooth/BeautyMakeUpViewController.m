//  美妆
//  BeautyMakeUpViewController.m
//  TalentPhotoBooth
//
//  Created by 崔硕 on 2018/12/8.
//  Copyright © 2018 崔硕. All rights reserved.
//

#import "BeautyMakeUpViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "AFNetworking/AFNetworking.h"
#import "SVProgressHUD/SVProgressHUD.h"
#import <CommonCrypto/CommonDigest.h>
#import "ToolKit.h"
#import "ScrollPicker/MLPickerScrollView.h"
#import "ScrollPicker/MLDemoItem.h"
#import "ScrollPicker/MLDemoModel.h"

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
    NSLog(@"哈哈哈哈哈%ld",(long)_pickerScollView.seletedIndex);
    // Do any additional setup after loading the view.
    //NSLog(@"%@",[self currentTimeStr]);
    //NSLog(@"%@", [self return16LetterAndNumber]); [NSNumber numberWithInteger:2110462408]
    
    NSDictionary *dic_ = @{@"app_id": [NSNumber numberWithInt:2110462408],
                           @"time_stamp":[NSNumber numberWithInteger:[self currentTimeStr]],
                           @"nonce_str":[self return16LetterAndNumber],
                           @"cosmetic":[NSNumber numberWithInteger:1],
                           @"image":@"...",
                           //@"sign":@""
                          };
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:dic_];
    
    NSLog(@"%@", dic);
    
    NSString *sign = [self getReqSign:dic];
    
    [dic setObject:sign forKey:@"sign"];
    
   NSLog(@"%@", dic);
    
    
    //[dic setValue:sign forKey:@"app_id"];  [self image2DataURL:self.imageView.image] @"app_id":[NSNumber numberWithInteger:2110462408],
    //dic[@"sign"] = @"HEllo";[self image2DataURL:self.imageView.image]
    
    AFHTTPSessionManager *http = [AFHTTPSessionManager manager];
    [http POST:@"https://api.ai.qq.com/fcgi-bin/ptu/ptu_facecosmetic" parameters:dic headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Success");
        NSLog(@"%@", responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Fail");
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


//获取当前时间戳
- (NSInteger)currentTimeStr{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];//获取当前时间0秒后的时间
    NSTimeInterval time=[date timeIntervalSince1970]*1;// *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    return [timeString intValue];
}

-(NSString *)return16LetterAndNumber{
    //定义一个包含数字，大小写字母的字符串
    NSString * strAll = @"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    //定义一个结果
    NSString * result = [[NSMutableString alloc]initWithCapacity:16];
    for (int i = 0; i < 16; i++)
    {
        //获取随机数
        NSInteger index = arc4random() % (strAll.length-1);
        char tempStr = [strAll characterAtIndex:index];
        result = (NSMutableString *)[result stringByAppendingString:[NSString stringWithFormat:@"%c",tempStr]];
    }
    
    return result;
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

-(NSString *)getReqSign:(NSDictionary *)dic {
    NSString *app_key = @"&app_key=JQLepkbvA5IlFfxA";
    
    NSArray *keyArray = [dic allKeys];
    
    NSArray *sortArray = [keyArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    
    NSMutableArray *valueArray = [NSMutableArray array];
    for (NSString *sortString in sortArray) {
        [valueArray addObject:[dic objectForKey:sortString]];
    }
    
     NSMutableArray *signArray = [NSMutableArray array];
    for (int i = 0; i<sortArray.count; i++) {
        NSString *keyValueStr = [NSString stringWithFormat:@"%@=%@",sortArray[i],valueArray[i]];
        [signArray addObject:keyValueStr];
    }
    
    NSString *sign = [signArray componentsJoinedByString:@"&"];
    
    sign = [sign stringByAppendingString:app_key];
    
    sign = [self md5:sign];
    
    sign = [sign uppercaseStringWithLocale:[NSLocale currentLocale]];
    
    NSLog(@"%@", sign);
    
    return sign;
    
}


- (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
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

- (void)setUpSureButton
{
    sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sureButton.frame = CGRectMake(15, SCREEN_HEIGHT - 200, SCREEN_WIDTH - 30, 44);
    sureButton.backgroundColor = kRGB236;
    sureButton.layer.cornerRadius = 22;
    sureButton.layer.masksToBounds = YES;
    [sureButton setTitle:@"确定" forState:UIControlStateNormal];
    [sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sureButton addTarget:self action:@selector(clickSure) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sureButton];
}

#pragma mark - Action
- (void)clickSure
{
    NSLog(@"确定--选择折扣Index为%ld",(long)_pickerScollView.seletedIndex);
    
    NSString *title;
    for (int i = 0; i < data.count; i++) {
        MLDemoModel *model = [data objectAtIndex:i];
        if (model.dicountIndex == _pickerScollView.seletedIndex) {
            title = model.dicountTitle;
        }
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    [alert show];
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
