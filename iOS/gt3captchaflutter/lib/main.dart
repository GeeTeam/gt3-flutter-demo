import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CT3Captcha Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new CustomButtonList(titles: ['点击验证']),
    );
  } 
}

typedef void CustomButtonCallback(int tag);

class CustomButton extends StatelessWidget {
  final String title;
  final int tag;
  final CustomButtonCallback callback;

  CustomButton({this.title, this.tag, this.callback});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new ListTile(
      onTap: () {
        callback(this.tag);
      },
      title: new Text(this.title),
    );
  }
}

class CustomButtonList extends StatefulWidget {
  final List<String> titles;

  CustomButtonList({Key key, this.titles}) : super(key: key);

  @override
  CustomButtonListState createState() {
    // TODO: implement createState
    return new CustomButtonListState();
  }
}

const MethodChannel iOSGT3CaptchaChannel = const MethodChannel('com.geetest.gt3captcha/gt3captcha');

Future<String> startCaptcha(int tag) async {
    try {
      return await iOSGT3CaptchaChannel.invokeMethod('startCatpcha', tag);
    } on PlatformException catch (e) {
      print('PlatformException' + e.message);
      return '-1';
    }
}

class CustomButtonListState extends State<CustomButtonList> {
  void handleButtonTapped(int tag) {
    print("您正在点击第" + tag.toString() + "个button");
    startCaptcha(tag).then((message) {
      print('captcha message: ' + message);
      if (message == '0') {
        print('captcha successed');
      } else {
        print('captcha failed, error code is: ' + message);
      }
    }).catchError((error) {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    List<CustomButton> list = new List();
    for (var i = 0; i < widget.titles.length; i++) {
      String title = widget.titles[i];
      list.add(new CustomButton(title: title, tag: i, callback: handleButtonTapped));
    }

    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('CT3Captcha Demo'),
      ),
      body: new ListView(
        padding: new EdgeInsets.symmetric(vertical: 8.0),
        children: list,
      ),
    );
  }
} 


