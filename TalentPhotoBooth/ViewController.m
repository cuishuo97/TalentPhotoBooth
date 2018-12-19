//
//  ViewController.m
//  TalentPhotoBooth
//
//  Created by 崔硕 on 2018/12/8.
//  Copyright © 2018 崔硕. All rights reserved.
//

#import <SafariServices/SafariServices.h>
#import "ViewController.h"
#import "BeautyViewController.h"
#import "ToolKit.h"




@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

//美颜触觉反馈
- (IBAction)pressBeauty:(id)sender {
    [feedBackGenerator feedBack:@"MEDIUM"];

//    BeautyViewController *beautyVC = [self.storyboard instantiateViewControllerWithIdentifier:@"id"];
//    [self presentViewController:beautyVC animated:YES completion:nil];

    
    
}

//美妆触觉反馈
- (IBAction)pressBeautyMakeUp:(id)sender {
    [feedBackGenerator feedBack:@"MEDIUM"];
}

//变妆触觉反馈
- (IBAction)pressCrazyMakeUp:(id)sender {
    [feedBackGenerator feedBack:@"MEDIUM"];
}
//大头贴触觉反馈
- (IBAction)pressPhotoSticker:(id)sender {
    [feedBackGenerator feedBack:@"MEDIUM"];
}

@end
