#import "FbAliPayPlugin.h"
#import "AliPayTool.h"
#import <AlipaySDK/AlipaySDK.h>


@implementation FbAliPayPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"fb_ali_pay"
            binaryMessenger:[registrar messenger]];
  FbAliPayPlugin* instance = [[FbAliPayPlugin alloc] init];
  [registrar addApplicationDelegate:instance];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"isInstalledAliPay" isEqualToString:call.method]) {
        BOOL isInstalled = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"alipay://"]];
        result([NSNumber numberWithBool:isInstalled]);
        
    } else if ([@"aliPayAuth" isEqualToString:call.method]) {
      NSString * infoStr = [call.arguments valueForKey:@"info"];
      [AliPayTool getUserCode:infoStr block:^(NSString * _Nonnull code) {
          result(code);
      }];
      
  } else if ([@"aliPaySendRedPacket" isEqualToString:call.method]) {
      NSString * infoStr = [call.arguments valueForKey:@"info"];
      [AliPayTool senRedPacket:infoStr block:^(NSDictionary * _Nonnull code) {
          result(code);
      }];
      
  } else {
    result(FlutterMethodNotImplemented);
  }
}

-(BOOL)handleOpenURL:(NSURL*)url{
    if ([url.host isEqualToString:@"safepay"]) {
        // 支付跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:nil];
        
        // 授权跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic) {
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
            }
            NSLog(@"授权结果 authCode = %@", authCode?:@"");
        }];
        return YES;
    }

    return NO;
}

#pragma ApplicatioonLifeCycle

/**
 * Called if this has been registered for `UIApplicationDelegate` callbacks.
 *
 * @return `YES` if this handles the request.
 */
- (BOOL)application:(UIApplication*)application
            openURL:(NSURL*)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey, id>*)options{
    return [self handleOpenURL:url];
}

/**
 * Called if this has been registered for `UIApplicationDelegate` callbacks.
 *
 * @return `YES` if this handles the request.
 */
- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)url{
    return [self handleOpenURL:url];
}

/**
 * Called if this has been registered for `UIApplicationDelegate` callbacks.
 *
 * @return `YES` if this handles the request.
 */
- (BOOL)application:(UIApplication*)application
            openURL:(NSURL*)url
  sourceApplication:(NSString*)sourceApplication
         annotation:(id)annotation{
    return [self handleOpenURL:url];
}

@end
