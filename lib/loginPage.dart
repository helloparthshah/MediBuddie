import 'package:medibuddie/homePage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:medibuddie/cameraPage.dart';
import 'package:camera/camera.dart';

final databaseReference = FirebaseDatabase.instance.reference();

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();
String name;
String email;
String index;
String imageUrl = "http://pluspng.com/img-png/google-logo-png-open-2000.png";

Future<String> signInWithGoogle() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
    print("Cameras found");
  } on CameraException catch (e) {
    logError(e.code, e.description);
  }
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final AuthResult authResult = await _auth.signInWithCredential(credential);
  final FirebaseUser user = authResult.user;

  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

  final FirebaseUser currentUser = await _auth.currentUser();
  assert(user.uid == currentUser.uid);

  assert(user.email != null);
  assert(user.displayName != null);
  assert(user.photoUrl != null);

  name = user.displayName;
  email = user.email;
  imageUrl = user.photoUrl;
  if (name.contains(" ")) {
    name = name.substring(0, name.indexOf(" "));
  }

  if (email.contains("@")) {
    index = email.substring(0, email.indexOf("@"));
  }

  return 'signInWithGoogle succeeded: $user';
}

Future signOutGoogle() async {
  googleSignIn.signOut();
  print("User Signed Out");
  name="";
  email="";
  imageUrl = "http://pluspng.com/img-png/google-logo-png-open-2000.png";
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Material(
      child: Container(
        decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Colors.teal[400], Colors.teal[200]],
                ),
              ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Image(image: AssetImage("images/icon.png"), height: 200.0),
              SizedBox(height: 20),
              Directionality(
                textDirection: TextDirection.ltr,
              child:Text("MediBuddie",style: TextStyle(fontSize: 40,color: Colors.green[200],fontWeight: FontWeight.w900,),),
              ),
              SizedBox(height: 50),
              Directionality(
                textDirection: TextDirection.ltr,
                child: _signInButton(),
              ),
              SizedBox(height: 20),
              Directionality(
                textDirection: TextDirection.ltr,
                child: _signInAsGuestButton(),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _signInButton() {
    return OutlineButton(
      splashColor: Colors.white,
      onPressed: () async {
        await signInWithGoogle().whenComplete(() async{
          await createRecord();
          runApp(Home());
          print("Signing in...");
        });
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.black),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Image(image: AssetImage("images/google_logo.png"), height: 35.0),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Sign in with Google',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _signInAsGuestButton() {
    return OutlineButton(
      splashColor: Colors.white,
      onPressed: () async {
        name = "Guest";
        email = "guest@veggiebuddie.com";
        index = "guest";
        await createRecord();
        runApp(Home());
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.black),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Sign in as Guest',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future createRecord() async {
      databaseReference.child(index).update({
          'name': name,
          'email': email,
    });
  }
}
