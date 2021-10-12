# gt3-flutter-demo

这是行为验证 Flutter 的简单使用示例，通过 MethodChannel 即可调用到原生方法实现行为验证功能。

## iOS

```dart
const MethodChannel iOSGT3CaptchaChannel = const MethodChannel('com.geetest.gt3captcha/gt3captcha');

Future<String> startCaptcha(int tag) async {
    try {
      return await iOSGT3CaptchaChannel.invokeMethod('startCatpcha', tag);
    } on PlatformException catch (e) {
      print('PlatformException' + e.message);
      return '-1';
    }
}
```

```objc
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface GT3CaptchaUtil : NSObject

- (void)startCaptcha:(FlutterResult)flutterResult;

@end

NS_ASSUME_NONNULL_END

#import "GT3CaptchaUtil.h"
#import <GT3Captcha/GT3Captcha.h>
#import "TipsView.h"

#define DefaultRegisterAPI @"http://www.geetest.com/demo/gt/register-test"
#define DefaultValidateAPI @"http://www.geetest.com/demo/gt/validate-test"

@interface GT3CaptchaUtil () <GT3CaptchaManagerDelegate, GT3CaptchaManagerViewDelegate>

@property (nonatomic, strong) GT3CaptchaManager *captchaManager;
@property (nonatomic, copy) FlutterResult flutterResult;

@end

@implementation GT3CaptchaUtil

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (GT3CaptchaManager *)captchaManager {
    if (!_captchaManager) {
        _captchaManager = [GT3CaptchaManager sharedGTManagerWithAPI1:DefaultRegisterAPI API2:DefaultValidateAPI timeout:5.0];
        _captchaManager.delegate = self;
        _captchaManager.viewDelegate = self;
        _captchaManager.maskColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
        [_captchaManager registerCaptcha:^{
            
        }];
    }
    return _captchaManager;
}

- (void)startCaptcha:(FlutterResult)flutterResult {
    self.flutterResult = flutterResult;
    [self.captchaManager startGTCaptchaWithAnimated:YES];
}

#pragma mark - GT3CaptchaManagerViewDelegate

- (void)gtCaptchaWillShowGTView:(GT3CaptchaManager *)manager {
    NSLog(@"GTView will show.");
}

#pragma MARK - GT3CaptchaManagerDelegate

- (void)gtCaptcha:(GT3CaptchaManager *)manager errorHandler:(GT3Error *)error {
    //处理验证中返回的错误
    if (error.code == -999) {
        // 请求被意外中断, 一般由用户进行取消操作导致, 可忽略错误
    }
    else if (error.code == -10) {
        // 预判断时被封禁, 不会再进行图形验证
    }
    else if (error.code == -20) {
        // 尝试过多
    }
    else {
        // 网络问题或解析失败, 更多错误码参考开发文档
    }
    [TipsView showTipOnKeyWindow:error.error_code fontSize:12.0];
    
    if (self.flutterResult) {
        self.flutterResult(error);
    }
}

- (void)gtCaptchaUserDidCloseGTView:(GT3CaptchaManager *)manager {
    NSLog(@"User Did Close GTView.");
}

- (void)gtCaptcha:(GT3CaptchaManager *)manager didReceiveSecondaryCaptchaData:(NSData *)data response:(NSURLResponse *)response error:(GT3Error *)error decisionHandler:(void (^)(GT3SecondaryCaptchaPolicy))decisionHandler {
    if (!error) {
        // 处理你的验证结果
        NSLog(@"\ndata: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        // 成功请调用decisionHandler(GT3SecondaryCaptchaPolicyAllow)
        decisionHandler(GT3SecondaryCaptchaPolicyAllow);
        // 失败请调用decisionHandler(GT3SecondaryCaptchaPolicyForbidden)
        //decisionHandler(GT3SecondaryCaptchaPolicyForbidden);
        
        [TipsView showTipOnKeyWindow:@"验证成功"];
        if (self.flutterResult) {
            self.flutterResult([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        }
    } else {
        // 二次验证发生错误
        decisionHandler(GT3SecondaryCaptchaPolicyForbidden);
        [TipsView showTipOnKeyWindow:error.error_code fontSize:12.0];
        
        if (self.flutterResult) {
            self.flutterResult(error);
        }
    }
}

@end
```

## Android

```dart
static const platform = const MethodChannel("com.flyou.test/android");
Future<String> customVerity() async {
    try {
      return await platform.invokeMethod("customVerity");
    } on PlatformException catch (e) {
      print(e.toString());
      return "1";
    }
}
```

```java
package com.geetest.gee_flutter_demo;

import android.content.res.Configuration;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.widget.Toast;

import com.geetest.sdk.GT3ConfigBean;
import com.geetest.sdk.GT3ErrorBean;
import com.geetest.sdk.GT3GeetestUtils;
import com.geetest.sdk.GT3Listener;

import org.json.JSONObject;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {

    private static final String TAG = "MainActivity";

    // api1，需替换成自己的服务器URL
    private static final String captchaURL = "https://www.geetest.com/demo/gt/register-slide-voice";
    // api2，需替换成自己的服务器URL
    private static final String validateURL = "https://www.geetest.com/demo/gt/validate-slide-voice";

    private GT3GeetestUtils gt3GeetestUtils;
    private GT3ConfigBean gt3ConfigBean;

    private static final String CHANNEL = "com.flyou.test/android";
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        gt3GeetestUtils = new GT3GeetestUtils(this);
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor(), CHANNEL).setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("customVerity")) {
                        customVerity(result);
                    } else if (call.method.equals("onDestroy")){
                        onDestroy();
                    } else if(call.method.equals("showToast") && call.argument("msg")!=null){
                        Toast.makeText(MainActivity.this, call.argument("msg").toString(), Toast.LENGTH_SHORT).show();
                    }
                });
    }

    private void customVerity(final MethodChannel.Result callback) {
        // 配置bean文件，也可在oncreate初始化
        gt3ConfigBean = new GT3ConfigBean();
        // 设置验证模式，1：bind，2：unbind
        gt3ConfigBean.setPattern(1);
        // 设置点击灰色区域是否消失，默认不消息
        gt3ConfigBean.setCanceledOnTouchOutside(false);
        // 设置语言，如果为null则使用系统默认语言
        gt3ConfigBean.setLang(null);
        // 设置webview加载超时
        gt3ConfigBean.setTimeout(10000);
        // 设置webview请求超时
        gt3ConfigBean.setWebviewTimeout(10000);
        // 设置回调监听
        gt3ConfigBean.setListener(new GT3Listener() {

            /**
             * 验证码加载完成
             * @param duration 加载时间和版本等信息，为json格式
             */
            @Override
            public void onDialogReady(String duration) {
                Log.e(TAG, "GT3BaseListener-->onDialogReady-->" + duration);
            }

            @Override
            public void onReceiveCaptchaCode(int i) {
                Log.e(TAG, "GT3BaseListener-->onClosed-->" + i);
            }

            /**
             * 验证结果
             * @param result
             */
            @Override
            public void onDialogResult(String result) {
                Log.e(TAG, "GT3BaseListener-->onDialogResult-->" + result);
                // 开启自定义api2逻辑
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.CUPCAKE) {
                    new RequestAPI2().execute(result);
                }
            }

            /**
             * 统计信息，参考接入文档
             * @param result
             */
            @Override
            public void onStatistics(String result) {
                Log.e(TAG, "GT3BaseListener-->onStatistics-->" + result);
            }

            /**
             * 验证码被关闭
             * @param num 1 点击验证码的关闭按钮来关闭验证码, 2 点击屏幕关闭验证码, 3 点击返回键关闭验证码
             */
            @Override
            public void onClosed(int num) {
                Log.e(TAG, "GT3BaseListener-->onClosed-->" + num);
            }

            /**
             * 验证成功回调
             * @param result
             */
            @Override
            public void onSuccess(String result) {
                Log.e(TAG, "GT3BaseListener-->onSuccess-->" + result);
                callback.success("0");
            }

            /**
             * 验证失败回调
             * @param errorBean 版本号，错误码，错误描述等信息
             */
            @Override
            public void onFailed(GT3ErrorBean errorBean) {
                Log.e(TAG, "GT3BaseListener-->onFailed-->" + errorBean.toString());
            }

            /**
             * 自定义api1回调
             */
            @Override
            public void onButtonClick() {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.CUPCAKE) {
                    new RequestAPI1().execute();
                }
            }
        });
        gt3GeetestUtils.init(gt3ConfigBean);
        // 开启自定义验证
        gt3GeetestUtils.startCustomFlow();
    }

    /**
     * 请求api1
     */
    class RequestAPI1 extends AsyncTask<Void, Void, JSONObject> {

        @Override
        protected JSONObject doInBackground(Void... params) {
            String string = HttpUtils.requestGet(captchaURL + "?" + System.currentTimeMillis());
            Log.e(TAG, "doInBackground: " + string);
            JSONObject jsonObject = null;
            try {
                jsonObject = new JSONObject(string);
            } catch (Exception e) {
                e.printStackTrace();
            }
            return jsonObject;
        }

        @Override
        protected void onPostExecute(JSONObject parmas) {
            // 继续验证
            Log.i(TAG, "RequestAPI1-->onPostExecute: " + parmas);
            // SDK可识别格式为
            // {"success":1,"challenge":"06fbb267def3c3c9530d62aa2d56d018","gt":"019924a82c70bb123aae90d483087f94","new_captcha":true}
            // TODO 设置返回api1数据，即使为null也要设置，SDK内部已处理
            gt3ConfigBean.setApi1Json(parmas);
            // 继续api验证
            gt3GeetestUtils.getGeetest();
        }
    }

    /**
     * 请求api2
     */
    class RequestAPI2 extends AsyncTask<String, Void, String> {

        @Override
        protected String doInBackground(String... params) {
            if (!TextUtils.isEmpty(params[0])) {
                return HttpUtils.requestPost(validateURL, params[0]);
            } else {
                return null;
            }
        }

        @Override
        protected void onPostExecute(String result) {
            Log.i(TAG, "RequestAPI2-->onPostExecute: " + result);
            if (!TextUtils.isEmpty(result)) {
                try {
                    JSONObject jsonObject = new JSONObject(result);
                    String status = jsonObject.getString("status");
                    if ("success".equals(status)) {
                        gt3GeetestUtils.showSuccessDialog();
                    } else {
                        gt3GeetestUtils.showFailedDialog();
                    }
                } catch (Exception e) {
                    gt3GeetestUtils.showFailedDialog();
                    e.printStackTrace();
                }
            } else {
                gt3GeetestUtils.showFailedDialog();
            }
        }
    }


    @Override
    protected void onDestroy() {
        super.onDestroy();
        // TODO 销毁资源，务必添加
        gt3GeetestUtils.destory();
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        // 横竖屏切换
        gt3GeetestUtils.changeDialogLayout();
    }

}
```