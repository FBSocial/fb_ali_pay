import {
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';

import {Pay} from '@cashier_alipay/cashiersdk';
import { BusinessError } from '@kit.BasicServicesKit';
import { bundleManager } from '@kit.AbilityKit';

/** FbAliPayPlugin **/
export default class FbAliPayPlugin implements FlutterPlugin, MethodCallHandler {
  private channel: MethodChannel | null = null;

  constructor() {
  }

  getUniqueClassName(): string {
    return "FbAliPayPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "fb_ali_pay");
    this.channel.setMethodCallHandler(this)
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null)
    }
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (call.method == "isInstalledAliPay") {
      try {
        let link = 'alipays://test.example.com/home';
        let canOpen = bundleManager.canOpenLink(link);
        result.success(canOpen);
      } catch (err) {
        result.success(false);
      }
    } else if (call.method == "aliPay") {
      if (call.args instanceof Map) {
        // 作为一个Map，我们可以使用get方法来获取"info"键的值
        let code: string | undefined = call.args.get('info');
        new Pay().payWithNav(code ?? "", true, undefined, new NavPathStack()).then((aliPayResult) => {
          let message =
            `resultStatus: ${aliPayResult.get('resultStatus')} memo: ${aliPayResult.get('memo')} result: ${aliPayResult.get('result')}`;
          result.success(message);
        }).catch((error: BusinessError) => {
          result.success(error.message);
        });
      }

    } else if (call.method == "aliPaySendRedPacket") {
      if (call.args instanceof Map) {
        // 作为一个Map，我们可以使用get方法来获取"info"键的值
        let code: string | undefined = call.args.get('info');
        new Pay().payWithNav(code ?? "", true, undefined, new NavPathStack()).then((aliPayResult) => {
          result.success(aliPayResult);
        }).catch((error: BusinessError) => {
          result.success({"code":"9001"});
        });
      }
    } else {
      result.notImplemented()
    }
  }
}