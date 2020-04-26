import 'package:flutter/material.dart';
import 'package:medibuddie/cameraPage.dart';
import 'package:medibuddie/ProfilePage.dart';
import 'package:flutter/services.dart';

/* void main(){
  runApp(Home());
} */

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("App started");
    SystemChrome.setEnabledSystemUIOverlays([]);
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.yellow,
      home: PageView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          FlutterVisionApp(),
          Profile(),
        ],
      ),
    );
  }
}
