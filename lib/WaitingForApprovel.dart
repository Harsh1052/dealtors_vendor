import 'package:flutter/material.dart';

import 'package:dealtors_vendor/style/Color.dart' as color;

import 'netutils/preferences.dart';

class WaitingForApprovel extends StatefulWidget {
  @override
  _WaitingForApprovelState createState() => _WaitingForApprovelState();
}

class _WaitingForApprovelState extends State<WaitingForApprovel> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setPrefrenseisApprove();
  }

  setPrefrenseisApprove() async {
    await SharedPreferencesHelper.setPreference("isApprove_open", "1");
  }

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
                      "Waiting For Approval",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 25,
                          color: color.red,
                          fontFamily: 'poppins_bold'),
                    ),
                    Text(
                      "Your account is under approval we will get back soon",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 15, fontFamily: 'poppins_medium'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 50),
                      child: SizedBox(
                        height: 200.0,
                        width: 200,
                        child: new Image.asset(
                          "assets/waiting_for_approvel.png",
                          fit: BoxFit.cover,
                        ),
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
                            " Logout ",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                            ),
                          ),
                        ),
                        onPressed: () {
                          navigationLogout();

                          /* Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage()));
                         */ //userBlockDialog();
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

  navigationLogout() async {
    await SharedPreferencesHelper.clearAllPreference();
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/loginpage', (Route<dynamic> route) => false);
  }
}
