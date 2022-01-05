//
//  AliPayTool.m
//  Runner
//
//  Created by 杨志豪 on 2021/11/16.
//  Copyright © 2021 The Chromium Authors. All rights reserved.
//

#import "AliPayTool.h"
#import <AlipaySDK/AlipaySDK.h>

@implementation AliPayTool

+ (void)getUserCode: (NSString *)userInfo block:(CodeBlock)block{
    NSString *appScheme = @"fanbook";
    [[AlipaySDK defaultService] auth_V2WithInfo:userInfo
                                     fromScheme:appScheme
                                       callback:^(NSDictionary *resultDic) {
                                           NSLog(@"result = %@",resultDic);
                                           // 解析 auth code
                                           NSString *result = resultDic[@"result"];
                                           NSString *authCode = nil;
                                           if (result.length>0) {
                                               NSArray *resultArr = [result componentsSeparatedByString:@"&"];
                                               for (NSString *subResult in resultArr) {
                                                   if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
                                                       authCode = [subResult substringFromIndex:10];
                                                       break;
                                                   }
                                               }
                                           } else {
                                               block(@"");
                                               return;
                                           }
                                            block(authCode);
                                           NSLog(@"授权结果 authCode = %@", authCode?:@"");
                                       }];
}

+ (void)senRedPacket: (NSString *)userInfo block:(PayBlock)block{
    NSString *appScheme = @"fanbook";
    NSString *orderString = userInfo;
        // NOTE: 调用支付结果开始支付
    [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
        NSLog(@"reslut = %@",resultDic);
        block(resultDic);
    }];
}

@end
