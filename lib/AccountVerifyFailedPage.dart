import 'package:dealtors_vendor/AddRestaurantPage.dart';
import 'package:dealtors_vendor/AllCouponPage.dart';
import 'package:dealtors_vendor/HomePage.dart';
import 'package:dealtors_vendor/SelectCategoryPage.dart';
import 'package:flutter/material.dart';
import 'package:dealtors_vendor/style/Color.dart' as color;

class AccountVerifyFailedPage extends StatefulWidget {
  String msg, type;

  AccountVerifyFailedPage({Key key, this.msg, this.type}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<AccountVerifyFailedPage> {
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
                    /*Text(
                      "Sorry your account verification failed",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 30,
                          color: color.red,
                          fontFamily: 'poppins_bold'),
                    ),*/
                    Text(
                      /*"Hey Mr. Ravi your account details are not verified so please contact to admin or re apply for the same"*/
                      widget.msg,
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 20, fontFamily: 'poppins_medium'),
                    ),
                    SizedBox(
                      height: 500.0,
                      child: new Image.asset(
                        "assets/verified_fail.jpg",
                        fit: BoxFit.cover,
                      ),
                    ),
                    widget.type == "4"
                        ? Container()
                        : MaterialButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25)),
                            color: color.primery_color,
                            height: 50,
                            minWidth: MediaQuery.of(context).size.width / 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 18.0),
                              child: Text(
                                " Re Apply Now ",
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
                                      builder: (context) => AddRestaurantPage(
                                            mode: 'reapply',
                                            category_id: "",
                                            category_name: "",
                                          ))); //userBlockDialog();
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
