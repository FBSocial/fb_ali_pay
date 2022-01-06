package com.example.fb_ali_pay;

import androidx.annotation.NonNull;
import io.flutter.app.FlutterApplication;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import com.alipay.sdk.app.AuthTask;

import android.app.Activity;
import android.os.Handler;
import android.os.Message;
import com.alipay.sdk.app.PayTask;
import android.annotation.SuppressLint;
import android.text.TextUtils;

import java.util.Map;


/** FbAliPayPlugin */
public class FbAliPayPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  private static final int SDK_PAY_FLAG = 1;
  private static final int SDK_AUTH_FLAG = 2;

  private MethodChannel.Result result;

  private FlutterPluginBinding flutterPluginBinding;

  @SuppressLint("HandlerLeak")
  private Handler mHandler = new Handler() {
    @SuppressWarnings("unused")
    public void handleMessage(Message msg) {
      switch (msg.what) {
        case SDK_PAY_FLAG: {
          PayResult payResult = new PayResult((Map<String, String>) msg.obj);
          /**
           * 对于支付结果，请商户依赖服务端的异步通知结果。同步通知结果，仅作为支付结束的通知。
           */
          String resultInfo = payResult.getResult();// 同步返回需要验证的信息
          String resultStatus = payResult.getResultStatus();
          // 判断resultStatus 为9000则代表支付成功
          if (TextUtils.equals(resultStatus, "9000")) {
            result.success(msg.obj);
          } else {
            result.success(msg.obj);
            System.out.println("支付失败");
          }
          break;
        }
        case SDK_AUTH_FLAG: {
          @SuppressWarnings("unchecked")
          AuthResult authResult = new AuthResult((Map<String, String>) msg.obj, true);
          String resultStatus = authResult.getResultStatus();

          // 判断resultStatus 为“9000”且result_code
          // 为“200”则代表授权成功，具体状态码代表含义可参考授权接口文档
          if (TextUtils.equals(resultStatus, "9000") && TextUtils.equals(authResult.getResultCode(), "200")) {
            // 获取alipay_open_id，调支付时作为参数extern_token 的value
            // 传入，则支付账户为该授权账户
            result.success(authResult.getAuthCode());
            System.out.println("授权成功");
          } else {
            // 其他状态值则为授权失败
            result.success("");
            System.out.println("授权失败");
          }
          break;
        }
        default:
          break;
      }
    };
  };


  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "fb_ali_pay");
    channel.setMethodCallHandler(this);
    this.flutterPluginBinding = flutterPluginBinding;
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if ( call.method.equals("aliPayAuth")) {
      final String info = call.argument("info");
      System.out.println("准备授权");
      Runnable authRunnable = new Runnable() {
        @Override
        public void run() {
          FlutterApplication application = (FlutterApplication) flutterPluginBinding.getApplicationContext();
          AuthTask authTask = new AuthTask(application.getCurrentActivity());
          // 调用授权接口，获取授权结果
          Map<String, String> result = authTask.authV2(info, true);
          Message msg = new Message();
          msg.what = SDK_AUTH_FLAG;
          msg.obj = result;
          mHandler.sendMessage(msg);
        }
      };
      this.result = result;
      // 异步调用
      Thread authThread = new Thread(authRunnable);
      authThread.start();

    } else if ( call.method.equals("aliPaySendRedPacket")) {
      final String info = call.argument("info");
      final Runnable payRunnable = new Runnable() {

        @Override
        public void run() {
          FlutterApplication application = (FlutterApplication) flutterPluginBinding.getApplicationContext();
          PayTask alipay = new PayTask(application.getCurrentActivity());
          Map<String, String> result = alipay.payV2(info, true);
          Message msg = new Message();
          msg.what = SDK_PAY_FLAG;
          msg.obj = result;
          mHandler.sendMessage(msg);
        }
      };
      this.result = result;
      Thread payThread = new Thread(payRunnable);
      payThread.start();
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
