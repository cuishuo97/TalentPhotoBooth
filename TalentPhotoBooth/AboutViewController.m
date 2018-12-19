//  关于
//  AboutViewController.m
//  TalentPhotoBooth
//
//  Created by 崔硕 on 2018/12/8.
//  Copyright © 2018 崔硕. All rights reserved.
//

#import "AboutViewController.h"
#import <SafariServices/SafariServices.h>
#import <MessageUI/MessageUI.h>
#import "sys/utsname.h"


@interface AboutViewController ()

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    //CFShow(infoDictionary);
    
    struct utsname systemInfo;
    uname(&systemInfo);
    
    _device = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    _iosversion = [UIDevice currentDevice].systemVersion;
    _version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    _lblVersionInfo.text = _version;
    
    //_version = [@"TalentPhotoBooth:" stringByAppendingString:_version];
    
    
    
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
    //return 2;
    switch (section) {
        case 0:
            return 2;
            break;
        
        case 1:
            return 1;
            break;
            
        case 2:
            return 1;
            break;
        default:
            return 0;
            break;
    }
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //NSLog(@"%@", [tableView cellForRowAtIndexPath:indexPath]);
    if (indexPath.section == 0) {
        NSLog(@"第一组");
        
        switch (indexPath.row) {
            case 0: {
                NSLog(@"官方网站");
                NSURL *url = [NSURL URLWithString:@"https://www.cuishuo.net/2018/12/19/TalentPhotoBooth/"];
                SFSafariViewController *safariVc = [[SFSafariViewController alloc] initWithURL:url];
                
                [self presentViewController:safariVc animated:YES completion:nil];
                break;
            }
                
            case 1:
            {
                NSLog(@"联系开发者");
                if ([MFMailComposeViewController canSendMail]) {
                    // 用户已设置邮件账户
                    // 邮件服务器
                    MFMailComposeViewController *mailCompose = [[MFMailComposeViewController alloc] init];
                    // 设置邮件代理
                    [mailCompose setMailComposeDelegate:self];
                    
                    // 设置邮件主题
                    [mailCompose setSubject:@"用户反馈"];
                    
                    // 设置收件人
                    [mailCompose setToRecipients:@[@"i@cuishuo.net"]];
//                    // 设置抄送人
//                    [mailCompose setCcRecipients:@[@"1780575208@qq.com"]];
//                    // 设置密抄送
//                    [mailCompose setBccRecipients:@[@"1780575208@qq.com"]];
                    
                    /**
                     *  设置邮件的正文内容
                     */
                    NSString * temp;
                    temp = [_device stringByAppendingString:@" "];
                    temp = [temp stringByAppendingString:_iosversion];
                    temp = [temp stringByAppendingString:@" "];
                    temp = [temp stringByAppendingString:_version];
                    NSString *prompt = @"请在此处输入您的反馈意见\n\n";
                    NSString *emailContent = [prompt stringByAppendingString:temp];
                    // 是否为HTML格式
                    [mailCompose setMessageBody:emailContent isHTML:NO];
                    // 如使用HTML格式，则为以下代码
                    //    [mailCompose setMessageBody:@"<html><body><p>Hello</p><p>World！</p></body></html>" isHTML:YES];
                    
                    // 弹出邮件发送视图
                    [self presentViewController:mailCompose animated:YES completion:nil];
                    
                }else{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"你还没有配置邮箱" preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
                    
                    [alert addAction:action];
                    [self presentViewController:alert animated:YES completion:nil];
                    //NSLog(@"请先设置登录邮箱号");
                }
            }
                break;
                
            default:
                break;
        }
    }
    
    
    else if (indexPath.section == 1) {
        NSLog(@"开源组件");
        NSURL *url = [NSURL URLWithString:@"https://cuishuo.net/app/libs.html"];
        SFSafariViewController *safariVc = [[SFSafariViewController alloc] initWithURL:url];
        
        [self presentViewController:safariVc animated:YES completion:nil];
    }

}

//「版本」tableCell 禁止点击
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        return nil;
    }
    else {
        return indexPath;
    }
}


//https://www.jianshu.com/p/310c618013f3
//MFMailComposeViewControllerDelegate的代理方法,发送后关闭发送邮件视图。
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled: // 用户取消编辑
            NSLog(@"Mail send canceled...");
            break;
        case MFMailComposeResultSaved: // 用户保存邮件
            NSLog(@"Mail saved...");
            break;
        case MFMailComposeResultSent: // 用户点击发送
            NSLog(@"Mail sent...");
            break;
        case MFMailComposeResultFailed: // 用户尝试保存或发送邮件失败
            NSLog(@"Mail send errored: %@...", [error localizedDescription]);
            break;
    }
    
    // 关闭邮件发送视图
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
