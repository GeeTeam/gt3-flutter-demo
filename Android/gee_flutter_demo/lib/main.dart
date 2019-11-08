import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MaterialApp(
    home: new LifecycleAppPage(),
  ));
}

class LifecycleAppPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new MyApp();
  }
}

class MyApp extends State<LifecycleAppPage>
    with WidgetsBindingObserver {
  static const platform = const MethodChannel("com.flyou.test/android");
  Future<String> customVerity() async {
    try {
      return await platform.invokeMethod("customVerity");
    } on PlatformException catch (e) {
      print(e.toString());
      return "1";
    }

  }

  onDestroy() async{
    try {
      await platform.invokeMethod("onDestroy");
    } on PlatformException catch (e) {
      print(e);
    }
  }

  showToast(String msg) async {
    try {
      await platform.invokeMethod("showToast",{"msg":msg});
    } on PlatformException catch (e) {
      print(e.toString());
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("GeetestDemo"),), body: Center(
      child: RaisedButton(
        child: Text("点我验证"),
        onPressed: () {
          customVerity().then((message) {
            print('captcha message: ' + message);
            if (message == "0") {
              print('captcha successed');
              showToast("success!!!");
            } else {
              print('captcha failed, error code is: ' + message);
            }
          }).catchError((error) {

          });
        },
      ),
    ),);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    onDestroy();
    super.dispose();
  }


}