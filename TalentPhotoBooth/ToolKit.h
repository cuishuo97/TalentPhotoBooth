//  工具包封装
//  ToolKit.h
//  TalentPhotoBooth
//
//  Created by 崔硕 on 2018/12/11.
//  Copyright © 2018 崔硕. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//Taptic Engine 触感反馈封装
@interface feedBackGenerator : NSObject

+ (void) feedBack: (NSString *) parameter;

@end

//图片压缩封装
@interface photoCompress : NSObject

+ (NSData *)resetSizeOfImageData:(UIImage *)sourceImage maxSize:(NSInteger)maxSize;

+ (UIImage *)newSizeImage:(CGSize)size image:(UIImage *)sourceImage;

+ (NSData *)halfFuntion:(NSArray *)arr image:(UIImage *)image sourceData:(NSData *)finallImageData maxSize:(NSInteger)maxSize;

@end

@interface shareViewController : NSObject

+ (UIActivityViewController *) showShareVC : (UIImage *) image;

@end



