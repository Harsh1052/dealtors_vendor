import 'package:dealtors_vendor/AccountVerifyFailedPage.dart';
import 'package:dealtors_vendor/CreateCoupon.dart';
import 'package:dealtors_vendor/HomePage.dart';
import 'package:dealtors_vendor/SelectCategoryPage.dart';
import 'package:flutter/material.dart';
import 'package:dealtors_vendor/style/Color.dart' as color;

import 'netutils/preferences.dart';

class AccountVerifiy extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<AccountVerifiy> {
  @override
  void initState() {
    // TODO: implement initState
    setPrefrenseisApprove();
  }

  setPrefrenseisApprove() async {
    await SharedPreferencesHelper.setPreference("isApprove_open", "0");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: color.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top:50,left:20.0,right: 20.0,bottom: 20.0),
            child: Container(
             // height: MediaQuery.of(context).size.height,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Your Account Successfully Verified",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 30, fontFamily: 'poppins_bold'),
                    ),
                    Text(
                      "Finally you are Ready to create your bussiness coupon here",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 20, fontFamily: 'poppins_medium'),
                    ),
                    SizedBox(
                      height: 500.0,
                      child: new Image.asset(
                        "assets/account_verify.jpg",
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
                            " Create First Coupon ",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                            ),
                          ),
                        ),
                        onPressed: () {
                          // HomePage h=new HomePage();
                          Navigator.of(context).pop(true);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CreateCoupon()));
                          /*
                          Navigator.pushReplacement(context, otproute);*/
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
