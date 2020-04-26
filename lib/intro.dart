import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intro_views_flutter/Models/page_view_model.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'package:medibuddie/homePage.dart';
import 'package:google_fonts/google_fonts.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new Intro(),
    );
  }
}

final page1 = new PageViewModel(
  pageColor: const Color(0xFF33BCD1),
  iconImageAssetPath: 'assets/discico.png',
  body: Center(
    child: Text(
      'Nothing is perfect and even our app isn\'t any different. MediBuddie is not responsible for any damage whatsoever.',
      style: GoogleFonts.getFont('Poppins'),
    ),
  ),
  title: Text(
    'Disclaimer!',
    style: GoogleFonts.getFont('Poppins'),
  ),
  mainImage: Image.asset(
    'assets/discico.png',
    height: 285.0,
    width: 285.0,
    alignment: Alignment.center,
  ),
  titleTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
  bodyTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
);

final page2 = new PageViewModel(
  pageColor: const Color(0xFF4EBD92),
  iconImageAssetPath: 'assets/medico.png',
  body: Center(
    child: Text(
      'MediBuddie Intelligently scans the medicine and gives you information about the use of the drug.',
      style: GoogleFonts.getFont('Poppins'),
    ),
  ),
  title: Text(
    'MediBuddie',
    style: GoogleFonts.getFont('Poppins'),
  ),
  mainImage: Image.asset(
    'assets/medlog',
    height: 285.0,
    width: 285.0,
    alignment: Alignment.center,
  ),
  titleTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
  bodyTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
);

final page3 = new PageViewModel(
  pageColor: const Color(0xFFF7D178),
  iconImageAssetPath: 'assets/celico.png',
  body: Center(
    child: Text(
      'Point your phone at the medicine label and click the camera icon. MediBuddie will search it\'s immense database and provide you with the information.',
      style: GoogleFonts.getFont('Poppins'),
    ),
  ),
  title: Text(
    'How to use?',
    style: GoogleFonts.getFont('Poppins'),
  ),
  mainImage: Image.asset(
    'assets/cellog.png',
    height: 285.0,
    width: 285.0,
    alignment: Alignment.center,
  ),
  titleTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
  bodyTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
);

class Intro extends StatefulWidget {
  @override
  _IntroState createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  @override
  Widget build(BuildContext context) {
    return IntroViewsFlutter(
      [page1, page2, page3],
      showNextButton: true,
      onTapDoneButton: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      },
      showSkipButton: true,
      pageButtonTextStyles: GoogleFonts.getFont(
        'Poppins',
        color: Colors.white,
        fontSize: 18.0,
      ),
    );
  }
}
