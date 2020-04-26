import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/services.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
// import 'package:medibuddie/loginPage.dart';
import 'package:medibuddie/ProfilePage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:translator/translator.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:flutter/services.dart' show DeviceOrientation, rootBundle;

import 'loginPage.dart';

/* Future test() async {
  final databaseReference = FirebaseDatabase.instance.reference();
  databaseReference.once().then((DataSnapshot snapshot) {
    values = Map<String, bool>.from(snapshot.value[index]['food']);
  });
} */

List<CameraDescription> cameras;

Future<List<String>> getFileData(String path) async {
  var readLines = await rootBundle.loadString(path);
  return readLines.split("\n");
}

class FlutterVisionHome extends StatefulWidget {
  @override
  _FlutterVisionHomeState createState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    // SystemChrome.setEnabledSystemUIOverlays([]);
    return _FlutterVisionHomeState();
  }
}

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

class _FlutterVisionHomeState extends State<FlutterVisionHome> {
  CameraController controller;
  String imagePath;
  // String name, purpose, dosage;
  bool isLoad = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // test();
    // print(values);
    controller = CameraController(cameras[0], ResolutionPreset.ultraHigh);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.black,
      key: _scaffoldKey,
      body: Container(
        child: Container(
          child: Center(
            child: _cameraPreviewWidget(),
          ),
        ),
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return CircularProgressIndicator();
    } else {
      return Stack(
        // height: MediaQuery.of(context).size.height,
        // width:MediaQuery.of(context).size.width / controller.value.aspectRatio,
        children: [
          AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: Container(
              child: Stack(
                children: <Widget>[
                  ModalProgressHUD(
                    inAsyncCall: isLoad,
                    progressIndicator: CircularProgressIndicator(),
                    child: CameraPreview(controller),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                            height: MediaQuery.of(context).size.height - 200),
                        FloatingActionButton(
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.black,
                          ),
                          backgroundColor: Colors.white,
                          onPressed: controller != null &&
                                  controller.value.isInitialized
                              ? onTakePictureButtonPressed
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 100.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: Center(
                child: Column(
                  children: <Widget>[
                    Opacity(
                      opacity: 0.5,
                      child: Icon(
                        Icons.arrow_drop_up,
                        size: 50.0,
                      ),
                    ),
                    Text(
                      "Swipe up",
                      style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  void onTakePictureButtonPressed() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
        });
        if (filePath != null) {
          showInSnackBar('Picture saved to $filePath');

          detectLabels().then((_) {});
        }
      }
    });
  }

  Future createRecord(String name, purpose) async {
    final databaseReference = FirebaseDatabase.instance.reference();

    databaseReference.child(name).update({
      'name': name,
      'purpose': purpose,
      'timestamp': ServerValue.timestamp,
    });
  }

  String api = "KqfW1tEJhd8u2YNbGC26qbrEoLLSlmrWVTooLqHg";

// https://api.fda.gov/drug/label.json?api_key=KqfW1tEJhd8u2YNbGC26qbrEoLLSlmrWVTooLqHg&search=openfda.generic_name:$a&limit=1
  Future<String> fetchData(String a) async {
    final response = await http.get(
        'https://api.fda.gov/drug/label.json?api_key=$api&search=openfda.generic_name:$a&limit=1');
    // print(response.body);
    // print(a);
    String y;

    if (response.statusCode == 200) {
      final x = await json.decode(response.body);
      // print(a);
      try {
        try {
          y = x["results"][0]["purpose"][0];
        } catch (e) {
          y = x["results"][0]["geriatric_use"][0];
        }
        // print(x["results"][0]["geriatric_use"][0]);
        // print(x["results"][0]["openfda"][0]["substance_name"][0]);
        print(y);
        return y;
      } catch (e) {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<void> detectLabels() async {
    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFilePath(imagePath);
    final TextRecognizer textRecognizer =
        FirebaseVision.instance.textRecognizer();
    final VisionText visionText =
        await textRecognizer.processImage(visionImage);
    /* final translator = new GoogleTranslator(); */

    /* var lang; */

    String newStr;
    String name, purpose;

    out:
    for (TextBlock block in visionText.blocks)
      for (TextLine line in block.lines) {
        for (TextElement element in line.elements) {
          newStr = element.text
              .replaceAll(",", "")
              .replaceAll(" ", "")
              .replaceAll("\"", "");
          Future<String> s;
          if (newStr.length > 4 &&
              newStr.toLowerCase() != "tablets" &&
              !(double.tryParse(newStr[0]) != null)) s = fetchData(newStr);
          if (await s != null && await s != '') {
            name = newStr.toUpperCase();
            purpose = await s;
            createRecord(name, purpose);
            print(purpose);
            break out;
          }
        }
      }

    String t, img, p;
    if (purpose == null) {
      t = "Could not identify!";
      p = "";
      img = "assets/notfound.gif";
    } else {
      t = name.toUpperCase();
      p = purpose;
      img = "assets/gif14.gif";
    }

    showDialog(
        context: context,
        builder: (_) => AssetGiffyDialog(
              image: Image.asset(img, fit: BoxFit.cover),
              entryAnimation: EntryAnimation.BOTTOM,
              title: new Text(
                t,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
              ),
              description: new Text(
                p,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
              ),
              onlyCancelButton: true,
              buttonCancelText: Text("Ok",
                  style: TextStyle(fontSize: 18.0, color: Colors.white)),
              buttonCancelColor: Colors.teal[300],
            ));
    textRecognizer.close();
    setState(() {
      isLoad = false;
    });
  }

  Future<String> takePicture() async {
    setState(() {
      isLoad = true;
    });
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/Foodie';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}

class FlutterVisionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    print("Cam");
    return Material(
      // debugShowCheckedModeBanner: false,
      child: FlutterVisionHome(),
    );
  }
}
