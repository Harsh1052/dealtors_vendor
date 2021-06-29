import 'package:dealtors_vendor/HomePage.dart';
import 'package:dealtors_vendor/SelectCategoryPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'Login.dart';
import 'netUtils/preferences.dart';
import 'package:dealtors_vendor/style/Color.dart' as color;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(new MaterialApp(
    home: new MyHomePage(),
    routes: <String, WidgetBuilder>{
      '/loginpage': (BuildContext context) => new LoginPage(),
      '/home': (BuildContext context) => new HomePage(),
      '/category': (BuildContext context) => new SelectCategoryPage(),
    },
  ));
}

String fname, mobile;

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp();
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  startTime() async {
    var _duration = new Duration(seconds: 2);
    return new Timer(_duration, navigationPage);
  }

  Future navigationPage() async {
    if (await SharedPreferencesHelper.getPreference("user_id") != null) {
      /*if (await SharedPreferencesHelper.getPreference("is_profile_business_category") ==
          null) {
        Navigator.of(context).pushReplacementNamed('/category');
      } else {*/
      Navigator.of(context).pushReplacementNamed('/home');
      //}
    } else {
      Navigator.of(context).pushReplacementNamed('/loginpage');
    }
  }

  @override
  void initState() {
    super.initState();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: Container(
      color: color.primery_color_dark,
      //   color: theme.colors.myred,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: SizedBox(
            height: 150.0,
            child: new Image.asset(
              "assets/logo.png",
            ),
          ),
        ),
      ),
    )

        /*new Container(
      // Set the image as the background of the Container
      decoration: new BoxDecoration(
          image: new DecorationImage(
              // Load image from assets
              image: new AssetImage('images/exam.png'),
              // Make the image cover the whole area
              fit: BoxFit.cover)),
    )*/
        );
  }
}
