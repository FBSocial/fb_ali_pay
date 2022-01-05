//
//  AliPayTool.h
//  Runner
//
//  Created by 杨志豪 on 2021/11/16.
//  Copyright © 2021 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AliPayTool : NSObject

typedef void(^CodeBlock)(NSString* code);

typedef void(^PayBlock)(NSDictionary* code);

+ (void)getUserCode: (NSString *)userInfo block:(CodeBlock)block;

+ (void)senRedPacket: (NSString *)userInfo block:(PayBlock)block;

@end

NS_ASSUME_NONNULL_END
