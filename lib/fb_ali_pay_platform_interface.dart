import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'fb_ali_pay_method_channel.dart';

abstract class FbAliPayPlatform extends PlatformInterface {
  /// Constructs a FbAliPayPlatform.
  FbAliPayPlatform() : super(token: _token);

  static final Object _token = Object();

  static FbAliPayPlatform _instance = MethodChannelFbAliPay();

  /// The default instance of [FbAliPayPlatform] to use.
  ///
  /// Defaults to [MethodChannelFbAliPay].
  static FbAliPayPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FbAliPayPlatform] when
  /// they register themselves.
  static set instance(FbAliPayPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
