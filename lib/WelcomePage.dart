import 'package:dealtors_vendor/HomePage.dart';
import 'package:dealtors_vendor/SelectCategoryPage.dart';
import 'package:flutter/material.dart';
import 'package:dealtors_vendor/style/Color.dart' as color;

import 'netutils/preferences.dart';

class WelcomePage extends StatefulWidget {
  String name;

  WelcomePage({Key key, this.name}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}


class _WelcomePageState extends State<WelcomePage> {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: color.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Welcome " + widget.name,
                      style:
                          TextStyle(fontSize: 30, fontFamily: 'poppins_bold'),
                    ),
                    Text(
                      "Customer is Ready For Shopping Hurry up to open your shop",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 20, fontFamily: 'poppins_medium'),
                    ),
                    SizedBox(
                      height: 500.0,
                      child: new Image.asset(
                        "assets/wellcome_image.jpg",
                        fit: BoxFit.cover,
                      ),
                    ),
                    MaterialButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                        color: color.primery_color,
                        height: 50,
                        minWidth: MediaQuery.of(context).size.width / 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 18.0),
                          child: Text(
                            " Open Now ",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SelectCategoryPage()));
                          //userBlockDialog();
                          //showInSnackBarFail("testtt");
                        }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
