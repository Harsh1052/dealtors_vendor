import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:dealtors_vendor/AccountVerifyPage.dart';
import 'package:dealtors_vendor/CustomWidget/FailVerifyDialog.dart';
import 'package:dealtors_vendor/CustomWidget/SuccessVerifyDialog.dart';
import 'package:dealtors_vendor/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:dealtors_vendor/style/Color.dart' as color;
import 'package:flutter/services.dart';
import 'package:dealtors_vendor/netutils/Retrofit.dart' as retrofit;
import 'dart:convert';

import 'CustomWidget/ToastFile.dart';
import 'netutils/preferences.dart';

class ValidateCoupon extends StatefulWidget {
  @override
  _AddRestaurantPageState createState() => _AddRestaurantPageState();
}

class _AddRestaurantPageState extends State<ValidateCoupon> {
  final couponCodeController = TextEditingController();
  final billAmountController = TextEditingController();

  bool isProgress = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool is_connected = false;

  final Connectivity _connectivity = Connectivity();

  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    // TODO: implement initState
    // _populateData();
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    setState(() {
      if (is_connected) {
        // TODO: implement initState
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        setState(() {
          is_connected = true;
        });
        break;
      case ConnectivityResult.mobile:
        setState(() {
          is_connected = true;
        });
        break;
      case ConnectivityResult.none:
        setState(() {
          is_connected = false;
        });
        break;
      default:
        setState(() {
          is_connected = false;
        });
        break;
    }
  }

  Future<String> verifyCoupon(String coupon_code, String bill_amount) async {
    isProgress = true;

    var response = await retrofit.verifyCoupon(
        await SharedPreferencesHelper.getPreference("user_id"),
        coupon_code,
        bill_amount);

    setState(() {
      var extractdata = json.decode(response.body);
      print(extractdata);
      if (extractdata['ack'] == 1) {
        print(extractdata['ack_msg']);
        //  SnackBarSuccess(extractdata['ack_msg'], context, _scaffoldKey);
        SuccessVerifyDialog(context);
        isProgress = false;
      } else {
        //SnackBarFail(extractdata['ack_msg'], context, _scaffoldKey);
        isProgress = false;
        print(extractdata['ack_msg']);

        FailVerifyDialog(context, extractdata['ack_msg']);
        //  Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return MaterialApp(
      theme: ThemeData(
        // Define the default brightness and colors.
        // brightness: Brightness.dark,
        primaryColor: color.primery_color_dark,
        //   accentColor: Theme.colors.button,
      ),
      home: Scaffold(
        key: _scaffoldKey,
        backgroundColor: color.white,
        body: SingleChildScrollView(
          child: Container(
            child: Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  color: color.primery_color_dark,
                  child: SizedBox(
                    height: 200,
                    child: Padding(
                      padding:
                          EdgeInsets.only(bottom: 0.0, top: statusBarHeight),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: new IconButton(
                                alignment: Alignment.topLeft,
                                icon: new Icon(
                                  Icons.arrow_back_ios_rounded,
                                  color: color.white,
                                ),
                                onPressed: () => Navigator.pop(context)),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Validate Coupon",
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontFamily: 'poppins_bold',
                                      color: color.white),
                                ),
                                Text(
                                  "Enter Customer's Coupon here ",
                                  style: TextStyle(
                                      fontSize: 15, color: color.white),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 80.0 + statusBarHeight),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(40.0),
                        topLeft: Radius.circular(40.0),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0, top: 20),
                            child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "Enter Customer Coupon Code",
                                  style:
                                      TextStyle(fontFamily: 'poppins_medium'),
                                )),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: 10.0, bottom: 10.0, left: 0.0, right: 0.0),
                            child: TextFormField(
                              controller: couponCodeController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  fillColor: color.light_gray,
                                  filled: true,
                                  //   suffixIcon: Icon(Icons.phone),
                                  enabledBorder: OutlineInputBorder(
                                      // width: 0.0 produces a thin "hairline" border
                                      borderSide:
                                          BorderSide(color: color.light_gray),
                                      borderRadius:
                                          BorderRadius.circular(25.0)),
                                  focusedBorder: new OutlineInputBorder(
                                      borderSide: BorderSide(color: color.gray),
                                      borderRadius:
                                          BorderRadius.circular(25.0)),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(25.0)),
                                  hintText: "Enter your Coupon Code here",
                                  hintStyle: TextStyle(color: color.hint_color)
                                  // labelText: 'Phone number',
                                  ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0, top: 20),
                            child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "Bill Amount",
                                  style:
                                      TextStyle(fontFamily: 'poppins_medium'),
                                )),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: 10.0, bottom: 10.0, left: 0.0, right: 0.0),
                            child: TextFormField(
                              controller: billAmountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                fillColor: color.light_gray,
                                filled: true,
                                //   suffixIcon: Icon(Icons.phone),
                                enabledBorder: OutlineInputBorder(
                                    // width: 0.0 produces a thin "hairline" border
                                    borderSide:
                                        BorderSide(color: color.light_gray),
                                    borderRadius: BorderRadius.circular(25.0)),
                                focusedBorder: new OutlineInputBorder(
                                    borderSide: BorderSide(color: color.gray),
                                    borderRadius: BorderRadius.circular(25.0)),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25.0)),
                                hintText: "Enter Bill Amount here",
                                hintStyle: TextStyle(color: color.hint_color),

                                // labelText: 'Phone number',
                              ),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 50.0),
                              child: MaterialButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25)),
                                  color: color.primery_color,
                                  height: 50,
                                  minWidth:
                                      MediaQuery.of(context).size.width / 2,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5.0, horizontal: 18.0),
                                    child: Text(
                                      "  Verify Now  ",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15.0,
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (is_connected) {
                                      if (isProgress==false) {
                                        if (couponCodeController.text == "") {
                                          isProgress = false;

                                          SnackBarFail(
                                              "Please Enter Coupon Code",
                                              context,
                                              _scaffoldKey);
                                        } else if (billAmountController.text ==
                                            "") {
                                          isProgress = false;

                                          SnackBarFail(
                                              "Please Enter Bill Amount",
                                              context,
                                              _scaffoldKey);
                                        } else {
                                          verifyCoupon(
                                              couponCodeController.text,
                                              billAmountController.text);
                                        }
                                      } /*else {
                                        SnackBarFail(
                                            "Still Your old process working",
                                            context,
                                            _scaffoldKey);
                                      }*/
                                    } else {
                                      isProgress = false;
                                      SnackBarFail(
                                          "Please Check Your Internet connection",
                                          context,
                                          _scaffoldKey);
                                    }
                                  }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> FailVerifyDialog(BuildContext context, String msg) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40.0)), //this right here
          child: SingleChildScrollView(
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 60.0, bottom: 40, left: 20, right: 20),
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: SizedBox(
                          height: 100.0,
                          width: 100.0,
                          child: new Image.asset(
                            "assets/blocked_user.jpg",
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 0, top: 10.0, right: 0, bottom: 0),
                        child: Center(
                          child: Text(
                            "Sorry !!",
                            style: TextStyle(
                                color: color.black,
                                fontSize: 25,
                                fontFamily: 'poppins_bold'),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 0, top: 10.0, right: 0, bottom: 0),
                        child: Center(
                          child: Text(
                            "" + msg,
                            style: TextStyle(color: color.gray),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 0, top: 20.0, right: 0, bottom: 0),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: SizedBox(
                            width: 200,
                            height: 50,
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25)),
                              onPressed: () {

                                  Navigator.pop(context);

                              },
                              child: Text(
                                "Try Again",
                                style: TextStyle(color: Colors.white),
                              ),
                              color: color.primery_color,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
