package com.example.fb_ali_pay;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;

import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import android.content.Context;

import com.alipay.sdk.app.AuthTask;


import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;

import android.app.Activity;
import android.os.Handler;
import android.os.Message;

import com.alipay.sdk.app.PayTask;

import android.annotation.SuppressLint;
import android.text.TextUtils;
import android.util.Log;

import java.util.Map;


/**
 * FbAliPayPlugin
 */
public class FbAliPayPlugin implements FlutterPlugin, ActivityAware, MethodCallHandler {
    private static final String TAG = "FbAliPayPlugin";
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;

    private static final String METHOD_PLATFORM_VERSION = "getPlatformVersion";
    private static final String METHOD_ALI_PAY_AUTH = "aliPayAuth";
    private static final String METHOD_ALI_PAY_INSTALLED = "isInstalledAliPay";
    private static final String METHOD_SEND_RED_PACKET = "aliPaySendRedPacket";

    private static final String OPTIONS_TIME_OUT = "last option time out";

    private static final int SDK_PAY_FLAG = 1;
    private static final int SDK_AUTH_FLAG = 2;

    private MethodChannel.Result mCurrentResult;

    private Activity activity;

    private Context applicationContext;

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
                    if (mCurrentResult == null) {
                        Log.e(TAG, "alipay plugin result is empty");
                        return;
                    }
                    // 判断resultStatus 为9000则代表支付成功
                    if (TextUtils.equals(resultStatus, "9000")) {
                        mCurrentResult.success(msg.obj);
                    } else {
                        mCurrentResult.success(msg.obj);
//                        System.out.println("支付失败");
                    }
                    break;
                }
                case SDK_AUTH_FLAG: {
                    @SuppressWarnings("unchecked")
                    AuthResult authResult = new AuthResult((Map<String, String>) msg.obj, true);
                    String resultStatus = authResult.getResultStatus();

                    if (mCurrentResult == null) {
                        Log.e(TAG, "alipay plugin result is empty");
                        return;
                    }
                    // 判断resultStatus 为“9000”且result_code
                    // 为“200”则代表授权成功，具体状态码代表含义可参考授权接口文档
                    if (TextUtils.equals(resultStatus, "9000") && TextUtils.equals(authResult.getResultCode(), "200")) {
                        // 获取alipay_open_id，调支付时作为参数extern_token 的value
                        // 传入，则支付账户为该授权账户
                        mCurrentResult.success(authResult.getAuthCode());
//                        System.out.println("授权成功");
                    } else {
                        // 其他状态值则为授权失败
                        mCurrentResult.success("");
//                        System.out.println("授权失败");
                    }
                    break;
                }
                default:
                    break;
            }
            mCurrentResult = null;
        }
    };

    // --- ActivityAware

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        onAttachedToActivity(binding);
    }

    @Override
    public void onDetachedFromActivity() {
        activity = null;
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "fb_ali_pay");
        channel.setMethodCallHandler(this);
        applicationContext = flutterPluginBinding.getApplicationContext();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method == null) {
            result.error("method is empty", null, null);
            return;
        }

        switch (call.method) {
            // 获取版本
            case METHOD_PLATFORM_VERSION:
                handlePlatformVersion(call, result);
                break;

            // 支付授权
            case METHOD_ALI_PAY_AUTH:
                handleAliPayAuth(call, result);
                break;

            // 判断是否安装支付宝
            case METHOD_ALI_PAY_INSTALLED:
                handleAliPayInstalled(call, result);
                break;

            // 发送红包
            case METHOD_SEND_RED_PACKET:
                handleSendRedPacket(call, result);
                break;

            default:
                result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    private void handlePlatformVersion(MethodCall call, Result result) {
        result.success("Android " + android.os.Build.VERSION.RELEASE);
    }

    private void handleAliPayInstalled(MethodCall call, Result result) {
//        Log.d(TAG, "handleAliPayInstalled: ");
        boolean isInstalled = false;
        try {
            final PackageManager packageManager = applicationContext.getPackageManager();
            PackageInfo info = packageManager.getPackageInfo("com.eg.android.AlipayGphone", PackageManager.GET_SIGNATURES);
            isInstalled = info != null;
        } catch (PackageManager.NameNotFoundException ignore) {
        }
        result.success(isInstalled);
    }

    private void handleAliPayAuth(MethodCall call, Result result) {
        if (mCurrentResult != null) {
            mCurrentResult.error(OPTIONS_TIME_OUT, null, null);
            mCurrentResult = null;
            return;
        }
        mCurrentResult = result;
        final String info = call.argument("info");
//        Log.d(TAG, "handleAliPayAuth: ");
        Runnable authRunnable = new Runnable() {
            @Override
            public void run() {
                AuthTask authTask = new AuthTask(activity);
                // 调用授权接口，获取授权结果
                Map<String, String> result = authTask.authV2(info, true);
                Message msg = new Message();
                msg.what = SDK_AUTH_FLAG;
                msg.obj = result;
                mHandler.sendMessage(msg);
            }
        };
        // 异步调用
        Thread authThread = new Thread(authRunnable);
        authThread.start();
    }

    private void handleSendRedPacket(MethodCall call, Result result) {
        if (mCurrentResult != null) {
            mCurrentResult.error(OPTIONS_TIME_OUT, null, null);
            mCurrentResult = null;
            return;
        }
        mCurrentResult = result;
//        Log.d(TAG, "handleSendRedPacket: ");
        final String info = call.argument("info");
        final Runnable payRunnable = new Runnable() {

            @Override
            public void run() {
                PayTask alipay = new PayTask(activity);
                Map<String, String> result = alipay.payV2(info, true);
                Message msg = new Message();
                msg.what = SDK_PAY_FLAG;
                msg.obj = result;
                mHandler.sendMessage(msg);
            }
        };
        Thread payThread = new Thread(payRunnable);
        payThread.start();
    }
}
