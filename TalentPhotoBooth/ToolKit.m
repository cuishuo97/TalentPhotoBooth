//  工具包封装
//  ToolKit.m
//  TalentPhotoBooth
//
//  Created by 崔硕 on 2018/12/14.
//  Copyright © 2018 崔硕. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import "ToolKit.h"
#import "MBProgressHUD/MBProgressHUD.h"
#import "NSString +URL.h"
#import <CommonCrypto/CommonDigest.h>

//Taptic Engine 触感反馈封装
@implementation feedBackGenerator

+ (void) feedBack: (NSString *) parameter {
    NSArray *items = @[@"MEDIUM", @"SUCCESS", @"ERROR"];
    
    NSInteger num = [items indexOfObject:parameter];
    
    switch (num) {
        case 0:
        {    UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle: UIImpactFeedbackStyleMedium];
            [generator prepare];
            [generator impactOccurred];
            
            NSLog(@"中等feedback");
            break;
        }
            
            
        case 1:
        {
            UINotificationFeedbackGenerator *gengertor = [[UINotificationFeedbackGenerator alloc] init];
            
            [gengertor prepare];
            [gengertor notificationOccurred:UINotificationFeedbackTypeSuccess];
            NSLog(@"Success feedback");
            break;
        }
            
        case 2:
        {
            UINotificationFeedbackGenerator *gengertor2 = [[UINotificationFeedbackGenerator alloc] init];
            
            [gengertor2 prepare];
            [gengertor2 notificationOccurred:UINotificationFeedbackTypeError];
            NSLog(@"Error feedback");
            break;
        }
            
        default:
            break;
    }
}

@end

//图片压缩封装
@implementation photoCompress

+ (NSData *)resetSizeOfImageData:(UIImage *)sourceImage maxSize:(NSInteger)maxSize {
    //先判断当前质量是否满足要求，不满足再进行压缩
    __block NSData *finallImageData = UIImageJPEGRepresentation(sourceImage,1.0);
    NSUInteger sizeOrigin   = finallImageData.length;
    NSUInteger sizeOriginKB = sizeOrigin / 1000;
    
    if (sizeOriginKB <= maxSize) {
        return finallImageData;
    }
    
    //获取原图片宽高比
    CGFloat sourceImageAspectRatio = sourceImage.size.width/sourceImage.size.height;
    //先调整分辨率
    CGSize defaultSize = CGSizeMake(1024, 1024/sourceImageAspectRatio);
    UIImage *newImage = [self newSizeImage:defaultSize image:sourceImage];
    
    finallImageData = UIImageJPEGRepresentation(newImage,1.0);
    
    //保存压缩系数
    NSMutableArray *compressionQualityArr = [NSMutableArray array];
    CGFloat avg   = 1.0/250;
    CGFloat value = avg;
    for (int i = 250; i >= 1; i--) {
        value = i*avg;
        [compressionQualityArr addObject:@(value)];
    }
    
    /*
     调整大小
     说明：压缩系数数组compressionQualityArr是从大到小存储。
     */
    //思路：使用二分法搜索
    finallImageData = [self halfFuntion:compressionQualityArr image:newImage sourceData:finallImageData maxSize:maxSize];
    //如果还是未能压缩到指定大小，则进行降分辨率
    while (finallImageData.length == 0) {
        //每次降100分辨率
        CGFloat reduceWidth = 100.0;
        CGFloat reduceHeight = 100.0/sourceImageAspectRatio;
        if (defaultSize.width-reduceWidth <= 0 || defaultSize.height-reduceHeight <= 0) {
            break;
        }
        defaultSize = CGSizeMake(defaultSize.width-reduceWidth, defaultSize.height-reduceHeight);
        UIImage *image = [self newSizeImage:defaultSize
                                      image:[UIImage imageWithData:UIImageJPEGRepresentation(newImage,[[compressionQualityArr lastObject] floatValue])]];
        finallImageData = [self halfFuntion:compressionQualityArr image:image sourceData:UIImageJPEGRepresentation(image,1.0) maxSize:maxSize];
    }
    return finallImageData;
}


#pragma mark 调整图片分辨率/尺寸（等比例缩放）
+ (UIImage *)newSizeImage:(CGSize)size image:(UIImage *)sourceImage {
    CGSize newSize = CGSizeMake(sourceImage.size.width, sourceImage.size.height);
    
    CGFloat tempHeight = newSize.height / size.height;
    CGFloat tempWidth = newSize.width / size.width;
    
    if (tempWidth > 1.0 && tempWidth > tempHeight) {
        newSize = CGSizeMake(sourceImage.size.width / tempWidth, sourceImage.size.height / tempWidth);
    } else if (tempHeight > 1.0 && tempWidth < tempHeight) {
        newSize = CGSizeMake(sourceImage.size.width / tempHeight, sourceImage.size.height / tempHeight);
    }
    
    UIGraphicsBeginImageContext(newSize);
    [sourceImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
#pragma mark 二分法
+ (NSData *)halfFuntion:(NSArray *)arr image:(UIImage *)image sourceData:(NSData *)finallImageData maxSize:(NSInteger)maxSize {
    NSData *tempData = [NSData data];
    NSUInteger start = 0;
    NSUInteger end = arr.count - 1;
    NSUInteger index = 0;
    
    NSUInteger difference = NSIntegerMax;
    while(start <= end) {
        index = start + (end - start)/2;
        
        finallImageData = UIImageJPEGRepresentation(image,[arr[index] floatValue]);
        
        NSUInteger sizeOrigin = finallImageData.length;
        NSUInteger sizeOriginKB = sizeOrigin / 1024;
        NSLog(@"当前降到的质量：%ld", (unsigned long)sizeOriginKB);
        NSLog(@"\nstart：%zd\nend：%zd\nindex：%zd\n压缩系数：%lf", start, end, (unsigned long)index, [arr[index] floatValue]);
        
        if (sizeOriginKB > maxSize) {
            start = index + 1;
        } else if (sizeOriginKB < maxSize) {
            if (maxSize-sizeOriginKB < difference) {
                difference = maxSize-sizeOriginKB;
                tempData = finallImageData;
            }
            if (index<=0) {
                break;
            }
            end = index - 1;
        } else {
            break;
        }
    }
    return tempData;
}

@end

@implementation shareViewController

+ (UIActivityViewController *) showShareVC : (UIImage *) image {
    NSString *text = @"分享内容";
    UIImage *img = image;
    //NSURL *url = [NSURL URLWithString:@"https://www.baidu.com"];
    NSArray *activityItems = @[text, image];
    
    UIActivityViewController *activityViewController =    [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    //[presentViewController:activityViewController animated:YES completion:nil];
    
    return activityViewController;
    
    // 选中活动列表类型
//    [activityViewController setCompletionWithItemsHandler:^(NSString * __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError){
//        NSLog(@"act type %@",activityType);
//    }];
}

@end

@implementation ProgressHUD
    static MBProgressHUD *hud;

+ (void) showMessage {
    NSLog(@"ss");
}

+ (void) showLoadingMessage: (NSString *) message view:(UIView *) view {
    hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = message;
}

+ (void) hideHUD: (UIView *) view{
    [MBProgressHUD hideHUDForView:view animated:YES];
}

@end

@implementation Utility

+ (nullable NSString *) md5 :(nullable NSString *) str {
    if (!str) return nil;

    const char *cStr = str.UTF8String;
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
    NSMutableString *md5Str = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; ++i) {
        [md5Str appendFormat:@"%02x", result[i]];
    }
    return md5Str;
}

+ (NSString *) getReqSign :(NSMutableDictionary *) dic {
    NSString *app_key = @"&app_key=JQLepkbvA5IlFfxA";
    NSArray *keyArray = [dic allKeys];
    
    NSArray *sortArray = [keyArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    
    NSMutableArray *valueArray = [NSMutableArray array];
    
    for (NSString *key in sortArray) {
        [valueArray addObject:[dic objectForKey:key]];
    }
    
    NSMutableArray *value = [NSMutableArray array];
    NSString *s;
    
    for (int i=0; i<valueArray.count; i++) {
        s = [NSString stringWithFormat:@"%@", valueArray[i]];
        s = [s URLEncodedString];
        [value addObject: s];
    }
    
    NSMutableArray *signArray = [NSMutableArray array];
    for (int i = 0; i<sortArray.count; i++) {
        NSString *keyValueStr = [NSString stringWithFormat:@"%@=%@",sortArray[i],value[i]];
        [signArray addObject:keyValueStr];
    }
    
    NSString *sign = [signArray componentsJoinedByString:@"&"];
    
    sign = [sign stringByAppendingString:app_key];
    NSLog(@"%@",sign);
    
    sign = [self md5:sign];
    
    sign = [sign uppercaseString];
    
    return sign;
}

+ (NSString *) getTimeStamp {
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString*timeString = [NSString stringWithFormat:@"%0.f", a];//转为字符型
    return timeString;
}

+ (NSString *) return32String {
    char data[32];
    
    for (int x=0;x<32;data[x++] = (char)('A'+ (arc4random_uniform(26))));
    
    return [[NSString alloc] initWithBytes:data length:32 encoding:NSUTF8StringEncoding];
}

+ (UIImage *) stringToImage :(NSString *) str {
    NSData * imageData =[[NSData alloc] initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    UIImage *photo = [UIImage imageWithData:imageData ];
    
    return photo;
    
}

@end

