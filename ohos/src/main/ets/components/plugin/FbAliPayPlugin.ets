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
import {
  AFServiceParams,
  AFWantParams,
  AFServiceCenter,
  AFAuthServiceResponse,
  AFService,
  AFAuthResCode
} from '@alipay/afservicesdk';
import { JSON } from '@kit.ArkTS';

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
    } else if (call.method == "aliPayAuth") {
      if (call.args instanceof Map) {
        // 作为一个Map，我们可以使用get方法来获取"info"键的值
        let code: string | undefined = call.args.get('info');
        let backWant: AFWantParams = {
          bundleName: "com.idreamsky.fanbook", //接入方应用包名
          moduleName: "entry",
          abilityName: "EntryAbility"
        }
        let bizParams = new Map<string, string>()

        let url = encodeURIComponent("https://authweb.alipay.com/auth?auth_type=PURE_OAUTH_SDK&scope=auth_user&state=init&" + code);
        bizParams.set("url", url);
        let params = new AFServiceParams(bizParams, false, true, 'scheme:fanbook', backWant, (response: AFAuthServiceResponse) => {
          //授权返回值
          if (response.responseCode == AFAuthResCode.AFAuthResSuccess) {
            if (response.result != null) {
              let jsonStr = JSON.stringify(response);
              let jsonObject: Response = JSON.parse(jsonStr) as Response;
              let code = jsonObject.result.parameters.auth_code;
              result.success(code);
            }
            result.error("404","授权失败" + JSON.stringify(response),"");
          } else {
            result.error("404","授权失败" + JSON.stringify(response),"");
          }
        })
        AFServiceCenter.call(AFService.AFServiceAuth, params)
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

interface ResultParameters {
  app_id: string;
  auth_code: string;
  moduleName: string;
  result_code: string;
  scope: string;
  state: string;
}

interface Result {
  event: string;
  bundleName: string;
  code: number;
  data: string;
  parameters: ResultParameters;
}

interface Response {
  responseCode: number;
  session: string;
  result: Result;
}

