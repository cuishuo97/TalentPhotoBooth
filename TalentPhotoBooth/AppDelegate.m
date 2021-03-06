//
//  AppDelegate.m
//  TalentPhotoBooth
//
//  Created by 崔硕 on 2018/12/8.
//  Copyright © 2018 崔硕. All rights reserved.
//

#import "AppDelegate.h"
#import "BeautyViewController.h"
#import "BeautyMakeUpViewController.h"
#import "CrazyMakeUpViewController.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    return YES;
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    
    if ([shortcutItem.type isEqualToString:@"shortcutBeauty"]) {
    

        
        BeautyViewController *beautyVC = [[BeautyViewController alloc] init];
        [self.window.rootViewController presentViewController: beautyVC animated:YES completion:^{
        }];
        
//        BeautyViewController *beautyVC = [self.storyboard instantiateViewControllerWithIdentifier:@"id"];
//        [self.window.rootViewController presentViewController: beautyVC animated:YES completion:^{
//        }];

        
    }
    else if ([shortcutItem.type isEqualToString:@"shortcutMakeUp"]) {
        BeautyMakeUpViewController *beautyMakeUpVC = [[BeautyMakeUpViewController alloc] init];
        [self.window.rootViewController presentViewController:beautyMakeUpVC animated:YES completion:nil];
    }
    
    else if ([shortcutItem.type isEqualToString:@"shortcutCosplay"]) {
        CrazyMakeUpViewController *crazyMakeUpVC = [[CrazyMakeUpViewController alloc] init];
        
        [self.window.rootViewController presentViewController:crazyMakeUpVC animated:YES completion:nil];
    }
    
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}







@end


