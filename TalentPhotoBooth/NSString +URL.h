//
//  NSString +URL.h
//  TalentPhotoBooth
//
//  Created by 崔硕 on 2018/12/20.
//  Copyright © 2018 崔硕. All rights reserved.
//

/**
 *  url字符串中具有特殊功能的特殊字符的字符串，或者中文字符,作为参数用GET方式传递时，需要用urlencode处理一下。
 *
 *  例如：在 iOS 程序访问 HTTP 资源时，像拼出来的http://unmi.cc?p1=%+&sd f&p2=中文，其中的中文、特殊符号&％和空格都必须进行转译才能正确访问。
 */

/**
 *  调用示例：
 引入头文件：NSString+URL.h
 链接：https://www.jianshu.com/p/c7feb2072d1f
 // URLEncode
 NSString *unencodedString = @"cc?p1=%+&sd f&p";
 NSString *encodedString = [unencodedString URLEncodedString];
 
 // URLDecode
 NSString *undecodedString = @"%25+&sd%20&p2=%E4%B8%AD%E6%96%87";
 NSString *decodedString = [undecodedString URLDecodedString];
 */

#import <Foundation/Foundation.h>

@interface NSString (URL)

/**
 *  URLEncode
 */
- (NSString *)URLEncodedString;

/**
 *  URLDecode
 */
-(NSString *)URLDecodedString;

@end

