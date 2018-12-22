//
//  Base64Singleton.h
//  TheArtist
//
//  Created by yanghao on 16/5/8.
//  Copyright © 2016年 wikj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Base64Singleton : NSObject
+ (Base64Singleton *)sharedManager;
-(NSString*)base64Encode:(NSData *)data;

@end
