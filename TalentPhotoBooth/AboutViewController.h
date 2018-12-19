//  关于
//  AboutViewController.h
//  TalentPhotoBooth
//
//  Created by 崔硕 on 2018/12/8.
//  Copyright © 2018 崔硕. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AboutViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UITableView *AboutTableView;
@property (weak, nonatomic) IBOutlet UILabel *lblVersionInfo;

@property (nonatomic, assign) NSString *iosversion;
@property (nonatomic, assign) NSString *version;
@property (nonatomic, assign) NSString *device;

@end

NS_ASSUME_NONNULL_END
