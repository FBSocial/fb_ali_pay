import 'dart:async';

import 'package:fb_ali_pay/fb_ali_pay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  String serviceCode =
      "alipay_root_cert_sn=687b59193f3f462dd5336e5abf83c5d8_02941eef3187dddf3d3b83462e1dfcf6&alipay_sdk=alipay-sdk-php-20200415&app_cert_sn=a199a6a0760a19bacfc5ca74acb9311f&app_id=2021002194662251&biz_content=%7B%0D%0A++++++++++++%22out_biz_no%22%3A+%22303887371185684480%22%2C%0D%0A++++++++++++%22trans_amount%22%3A+200.32%2C%0D%0A++++++++++++%22order_id%22%3A+%22%22%2C%0D%0A++++++++++++%22product_code%22%3A+%22STD_RED_PACKET%22%2C%0D%0A++++++++++++%22biz_scene%22%3A+%22PERSONAL_PAY%22%2C%0D%0A++++++++++++%22remark%22%3A+%22Fanbook%E6%89%8B%E6%B0%94%E7%BA%A2%E5%8C%85%22%2C%0D%0A++++++++++++%22order_title%22%3A+%22%E5%BC%80%E5%BF%83%E7%BA%A2%E5%8C%85%22%2C%0D%0A++++++++++++%22time_expire%22%3A+%222021-11-24+09%3A48%22%2C%0D%0A++++++++++++%22refund_time_expire%22%3A+%222021-11-24+09%3A48%22%2C%0D%0A++++++++++++%22business_params%22%3A+%7B%22sub_biz_scene%22%3A%22REDPACKET%22%2C%22payer_binded_alipay_uid%22%3A%222088802424615392%22%7D%0D%0A++++++++%7D&charset=utf-8&format=json&method=alipay.fund.trans.app.pay&sign_type=RSA2&timestamp=2021-11-23+21%3A48%3A03&version=1.0&sign=Df61ezf6YXcykdpPyb61iI9omGxL28UpdvVI6Cg9K3uLA7%2FDbKjroyu7x6j5yShiAn6B8P%2B4k1p57EuDMeVuD5UOV4Hp0PHdtowrA%2B%2BMnW9DXDA7hzioW5CgE%2FFdDa9mHliezSIw0tjrpSD4gCyZ0w5LYkRBFqZ1LgltKrn7zChVfbfWjTrbYs5dC%2BEycCjw8y%2FIyIK4cks7SgfSAVdM3JTm1EkIjSbGAZxj3pAOZRE8f%2FAruDLulgl3mJHHC7IpSvjeCrmH5tC2LXn4zESafharFaP1hnwv5D%2BB%2FdlARjvm4qrjCFogjTCFb5%2BqslvkeJm4zgX5Z2ZgygxMY74xEA%3D%3D";

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await FbAliPay.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Column(
            children: [
              createButton("支付宝授权", () async {
                String code =
                    await FbAliPay.aliPayAuth(serviceCode).catchError((e) {
                  print("授权出错");
                });
                print("授权码为$code");
              }),
              createButton("支付宝付款", () async {
                bool success = await FbAliPay.aliPaySendRedPacket(serviceCode);
                print("支付成功? ${success ? "成功" : "失败"}");
              }),
            ],
          )),
    );
  }

  Widget createButton(String text, GestureTapCallback ontap) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        color: Colors.cyan,
        margin: EdgeInsets.only(top: 50),
        width: 200,
        height: 50,
        child: Center(
          child: Text(text),
        ),
      ),
    );
  }
}
