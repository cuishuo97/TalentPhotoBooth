//  大头贴
//  PhotoStickerViewController.m
//  TalentPhotoBooth
//
//  Created by 崔硕 on 2018/12/16.
//  Copyright © 2018 崔硕. All rights reserved.
//

#import "PhotoStickerViewController.h"
#import "ToolKit.h"
#import "ScrollPicker/MLPickerScrollView.h"
#import "ScrollPicker/MLDemoItem.h"
#import "ScrollPicker/MLDemoModel.h"

#define kItemH 110
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define MLColor(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define kRGB236 MLColor(236, 73, 73, 1.0)

@interface PhotoStickerViewController ()<MLPickerScrollViewDataSource,MLPickerScrollViewDelegate,UIAlertViewDelegate>
{
    MLPickerScrollView *_pickerScollView;
    NSMutableArray *data;
    UIButton *sureButton;
}

@end

@implementation PhotoStickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    // Do any additional setup after loading the view.
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
    _pickerScollView = [[MLPickerScrollView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 120, SCREEN_WIDTH, kItemH)];
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
