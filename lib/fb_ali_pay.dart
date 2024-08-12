// You have generated a new plugin project without
// specifying the `--platforms` flag. A plugin project supports no platforms is generated.
// To add platforms, run `flutter create -t plugin --platforms <platforms> .` under the same
// directory. You can also find a detailed instruction on how to add platforms in the `pubspec.yaml` at https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'dart:async';

import 'package:flutter/services.dart';

class FbAliPay {
  static const MethodChannel _channel = const MethodChannel('fb_ali_pay');

  ///是否安装支付宝(鸿蒙系统需要在module.json中添加"querySchemes": ["alipays"])

  static Future<bool?> isInstalledAliPay() async {
     bool? isInstalled = await _channel.invokeMethod("isInstalledAliPay");
    return isInstalled;
  }

  ///向支付宝请求授权
  static Future<String?> aliPayAuth(String serviceCode) async {
    final String? code =
        await _channel.invokeMethod("aliPayAuth", <String, String>{
      'info': serviceCode,
    });
    return code;
  }

  ///支付宝付款订单、红包
  static Future<bool> aliPaySendRedPacket(String serviceCode) async {
    final Map value =
        await _channel.invokeMethod("aliPaySendRedPacket", <String, String>{
      'info': serviceCode,
    });
    if (value["resultStatus"] == "9000") {
      return true;
    } else {
      return false;
    }
  }

  /// 支付宝支付
  static Future<String?> aliPay(String orderStr) async {
    final String? code =
    await _channel.invokeMethod("aliPay", <String, String>{
      'info': orderStr,
    });
    return code;
  }
}
