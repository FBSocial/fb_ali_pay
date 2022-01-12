# Flutter支付宝插件 fb_ali_pay

## 概述

* 该插件可以已集成ios、安卓原生的支付宝SDK，并且可以直接到dart层调用，无需再写原生的桥接代码。
* 该插件有检查支付宝环境、支付支付宝订单(或发红包)、获取支付宝授权三个功能。

#### 如何集成

在pubspec.yaml文件中加入
```
fb_ali_pay:
    git:
      url: https://github.com/yzhtracy/fb_ali_pay.git

```

因为ios是有白名单设置的，如果要使用ios的检测支付宝安装功能，只使用支付和授权则不用设置。
检测功能需要在ios工程的info.plist中加入LSApplicationQueriesSchemes，值为alipay。
可以参考此项目的example工程。

## 使用方式

### 检测安装
```
bool success = await FbAliPay.isInstalledAliPay();
print("是否有安装? ${success ? "是" : "否"}");
```

### 拉起支付宝支付订单(发红包)
```
bool success = await FbAliPay.aliPaySendRedPacket(serviceCode);
print("支付成功? ${success ? "成功" : "失败"}");
```
### 支付宝授权
```
String code =
    await FbAliPay.aliPayAuth(serviceCode).catchError((e) {
  print("授权出错");
});
print("授权码为$code");
```

