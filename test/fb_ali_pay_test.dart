import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fb_ali_pay/fb_ali_pay.dart';

void main() {
  const MethodChannel channel = MethodChannel('fb_ali_pay');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
}
