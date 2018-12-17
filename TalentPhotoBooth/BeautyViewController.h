//  美颜
//  BeautyViewController.h
//  TalentPhotoBooth
//
//  Created by 崔硕 on 2018/12/8.
//  Copyright © 2018 崔硕. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BeautyViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageView;


@property (weak, nonatomic) IBOutlet UISlider *sliderWhiteningRate;
@property (weak, nonatomic) IBOutlet UISlider *sliderSmoothingRate;

@property (weak, nonatomic) IBOutlet UILabel *lblWhiteningRate;
@property (weak, nonatomic) IBOutlet UILabel *lblSmoothingRate;



@end

NS_ASSUME_NONNULL_END
