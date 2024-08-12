import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'fb_ali_pay_platform_interface.dart';

/// An implementation of [FbAliPayPlatform] that uses method channels.
class MethodChannelFbAliPay extends FbAliPayPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('fb_ali_pay');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
