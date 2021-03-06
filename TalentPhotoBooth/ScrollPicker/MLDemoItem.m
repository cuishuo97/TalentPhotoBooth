//
//  MLDemoItem.m
//  MLPickerScrollView
//
//  Created by MelodyLuo on 15/8/14.
//  Copyright (c) 2015年 MelodyLuo. All rights reserved.
//

#define kITEM_WH 60
#define MLColor(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define kRGB220 MLColor(151, 151, 151, 1.0)
#define kRGB236 MLColor(51, 51, 51, 1.0)

#import "MLDemoItem.h"
#import "JXButton.h"

@implementation MLDemoItem

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUI];
    }
    return self;
}

- (void)setUI
{
    //self.backgroundColor = [UIColor greenColor];
    _discount = [JXButton buttonWithType:UIButtonTypeCustom];
    _discount.enabled = NO;
    _discount.titleLabel.font = [UIFont systemFontOfSize:12];
    //_discount.layer.borderWidth = 1.0f;
    //_discount.layer.cornerRadius = kITEM_WH * 0.5;
    //_discount.layer.masksToBounds = YES;
    //_discount.backgroundColor = [UIColor redColor];
    CGFloat itemW = kITEM_WH;
    CGFloat itemH = kITEM_WH;
    CGFloat itemX = (self.frame.size.width - itemW)*0.5;
    CGFloat itemY = (self.frame.size.height - itemH) *0.5;
    _discount.frame = CGRectMake(itemX, itemY, itemW, itemH);
    [self addSubview:_discount];
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    [_discount setTitle:title forState:UIControlStateNormal];
    [_discount.titleLabel sizeToFit];
}

-(void)setImageName:(NSString *)imageName{
    _imageName = imageName;
    [_discount setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}


- (void)setRedTitle
{
    //_discount.layer.borderColor = kRGB236.CGColor;
    [_discount setTitleColor:kRGB236 forState:UIControlStateNormal];
}

- (void)setGrayTitle
{
    //_discount.layer.borderColor = kRGB220.CGColor;
    [_discount setTitleColor:kRGB220 forState:UIControlStateNormal];
}

/**
 *  改变item成红色. frame变大
 */
- (void)changeSizeOfItem
{
    [self setRedTitle];
    CGFloat itemW = kITEM_WH + kITEM_WH*0.7;
    CGFloat itemH = kITEM_WH + kITEM_WH*0.7;
    CGFloat itemX = (self.frame.size.width - itemW)*0.5;
    CGFloat itemY = (self.frame.size.height - itemH) *0.5;
    //_discount.layer.borderWidth = 1.0f;
    //_discount.layer.cornerRadius = itemW * 0.5;
    //_discount.layer.masksToBounds = YES;
    _discount.frame = CGRectMake(itemX, itemY, itemW, itemH);
}

/**
 *  改变item成灰色，frame变小
 */
- (void)backSizeOfItem
{
    [self setGrayTitle];
    //_discount.layer.borderWidth = 1.0f;
    //_discount.layer.cornerRadius = kITEM_WH * 0.5;
    //_discount.layer.masksToBounds = YES;
    CGFloat itemW = kITEM_WH;
    CGFloat itemH = kITEM_WH;
    CGFloat itemX = (self.frame.size.width - itemW)*0.5;
    CGFloat itemY = (self.frame.size.height - itemH) *0.5;
    _discount.frame = CGRectMake(itemX, itemY, itemW, itemH);
}

@end
