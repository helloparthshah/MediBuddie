import 'dart:async';

import 'package:flutter/material.dart';
import 'package:medibuddie/homePage.dart';
import 'package:medibuddie/intro.dart';
import 'package:medibuddie/loginPage.dart';
import 'package:camera/camera.dart';
import 'package:medibuddie/cameraPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    logError(e.code, e.description);
  }
  runApp(MyApp());
}
