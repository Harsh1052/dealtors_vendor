import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:dealtors_vendor/AllCouponPage.dart';
import 'package:dealtors_vendor/CreateAccount.dart';
import 'package:dealtors_vendor/HomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dealtors_vendor/style/Color.dart' as color;
import 'package:flutter/services.dart';
import 'CustomWidget/ToastFile.dart';
import 'package:dealtors_vendor/netutils/Retrofit.dart' as retrofit;
import 'dart:convert';
import 'Model/GenrelModel.dart';
import 'netutils/preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

String _verificationId = "";
final FirebaseAuth _auth = FirebaseAuth.instance;

PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout;
PhoneVerificationFailed verificationFailed;
PhoneCodeSent codeSent;

String name, mobile_no;
bool otp_send_success = false;

String login_button_text = "Login with OTP";
bool widgetVisible = false, loginClick = false;

class _LoginPageState extends State<LoginPage> {
  bool is_connected = false;
  final Connectivity _connectivity = Connectivity();
  String _default_number = "53284090";
  String _selected_contury_code = "+852";

  List<GenrelModel> contry_data = new List();

  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  final mobileController = TextEditingController();

  final otpController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  PhoneVerificationCompleted verificationCompleted =
      (PhoneAuthCredential phoneAuthCredential) async {
    await _auth.signInWithCredential(phoneAuthCredential);
    print(
        "Phone number automatically verified and user signed in: ${_auth.currentUser.uid}");
    // showSnackbar("Phone number automatically verified and user signed in: ${_auth.currentUser.uid}");
  };

  void verifyPhoneNumber() async {
    print(_selected_contury_code + "" + mobileController.text);
    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: _selected_contury_code + "" + mobileController.text,
          timeout: const Duration(seconds: 5),
          verificationCompleted: verificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
    } catch (e) {
      loginClick = false;

      //showSnackbar("Failed to Verify Phone Number: ${e}");
    }
  }

  void signInWithPhoneNumber() async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otpController.text,
      );

      final User user = (await _auth.signInWithCredential(credential)).user;
      print("Successfully signed in UID: ${user.uid}");
      setState(() {
        loginClick = true;
      });
      Login(  mobileController.text,
          otpController.text, "verify");
      //  showSnackbar("Successfully signed in UID: ${user.uid}");
    } catch (e) {
      SnackBarFail("Verification Fail Please Try Again", context, _scaffoldKey);
      print("Failed to sign in: " + e.toString());
      otpController.text = "";
      //    showSnackbar("Failed to sign in: " + e.toString());
    }
  }

  void showWidget() {
    setState(() {
      widgetVisible = true;
      loginClick = false;
    });
  }

  void hideWidget() {
    setState(() {
      widgetVisible = false;
    });
  }

  Future<String> SendOtp(String mobile_no) async {
    setState(() {
      loginClick = true;
    });
    var response = await retrofit.sendOtpForLogin(mobile_no);
    setState(() {
      var extractdata = json.decode(response.body);
      print(extractdata);
      if (extractdata['ack'] == 1) {
        SnackBarSuccess(extractdata['ack_msg'], context, _scaffoldKey);
        setState(() {
          otpController.text = extractdata['otp'];
          otp_send_success = true;
          login_button_text = "Login Now";
        });
        showWidget();
        print(extractdata['ack_msg']);
      } else if (extractdata['ack'] == 2) {
        // if (result['isActive'] == '0') {
        loginClick = false;

        //   print("2 is active"+ result['isActive'] );
        blockedUser();
        //}
      } else {
        loginClick = false;

        SnackBarFail(extractdata['ack_msg'], context, _scaffoldKey);
        print(extractdata['ack_msg']);
      }
    });
  }

  var result;

  Future<String> Login(String mobile_no, String password, String type) async {
    setState(() {
      loginClick = true;
    });
    var response = await retrofit.login(mobile_no, password);
    setState(() {
      var extractdata = json.decode(response.body);
      print(extractdata);
      if (extractdata['ack'] == 1) {
        result = extractdata["result"];
        print("user id -- " + result['id']);

        // print("1 is active"+ result['isActive'] );
        if (result['isActive'] == '0') {
          loginClick = false;
          //   print("2 is active"+ result['isActive'] );
          blockedUser();
        } else {
          if (type == "check") {
            //s print(_selected_contury_code+""+mobileController.text);

            verifyPhoneNumber();
          } else {
            SharedPreferencesHelper.setPreference("user_id", result["id"]);
            SharedPreferencesHelper.setPreference("name", result["first_name"]);
            SharedPreferencesHelper.setPreference(
                "business_name", result["business_name"]);
            SharedPreferencesHelper.setPreference(
                "mobile_no", result["mobile_no"]);
            SharedPreferencesHelper.setPreference(
                "email_address", result["email_address"]);

            //  print("3 is active"+ result['isActive'] );
            SnackBarSuccess(extractdata['ack_msg'], context, _scaffoldKey);
            navigationPageHome();
          }
        }
        print(extractdata['ack_msg']);
      } else {
        loginClick = false;
        SnackBarFail(extractdata['ack_msg'], context, _scaffoldKey);
        print(extractdata['ack_msg']);
      }
    });
  }

  Future<String> getContury() async {
    var response = await retrofit.getContury();
    setState(() {
      var extractdata = json.decode(response.body);
      print(extractdata);
      if (extractdata['ack'] == 1) {
         if(extractdata['default_number']!=""){
          _default_number=extractdata['default_number'];}
          _selected_contury_code = extractdata['country_code'];


        contry_data = List<GenrelModel>.from(
            extractdata["result"].map((x) => GenrelModel.fromJson(x)));
        print(extractdata['ack_msg']);
      } else {
        print(extractdata['ack_msg']);
      }
    });
  }

  navigationPageHome() {
    loginClick = false;
    Route otproute = MaterialPageRoute(builder: (context) => HomePage());
    Navigator.pushReplacement(context, otproute);
  }

  blockedUser() {
    // setState(() {
    loginClick = false;
    //  });
    userBlockDialog();
  }

  @override
  void initState() {
    super.initState();
    otp_send_success = false;
    loginClick = false;
    login_button_text = "Login with OTP";
    mobileController.text = "";
    _selected_contury_code = "+852";

    hideWidget();
    getContury();
    codeSent = (String verificationId, [int forceResendingToken]) async {
      setState(() {
        showWidget();
      });
      loginClick = false;
      otp_send_success = true;
      login_button_text = "Login Now";
      //showSnackbar('Please check your phone for the verification code.');
      print('Please check your phone for the verification code.');
      SnackBarSuccess('Please check your phone for the verification code.',
          context, _scaffoldKey);
      _verificationId = verificationId;
      // otpController.text = extractdata['otp'];
    };

    codeAutoRetrievalTimeout = (String verificationId) {
      //showSnackbar("verification code: " + verificationId);
      print("verification code: " + verificationId);
      _verificationId = verificationId;
    };
    verificationFailed = (FirebaseAuthException authException) {
      print(
          'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');
      if (authException.code == "too-many-requests") {
        otp_send_success = false;

        SnackBarFail(authException.message, context, _scaffoldKey);
      } else if (authException.code == "invalid-phone-number") {
        otp_send_success = false;

        SnackBarFail('Please enter valid phone number with country code',
            context, _scaffoldKey);
      } else {
        SnackBarFail(authException.message, context, _scaffoldKey);
      }
      setState(() {
        loginClick = false;
      });
      //showSnackbar('Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');
    };
    _auth.setLanguageCode("en");
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
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

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return MaterialApp(
      theme: ThemeData(
        // Define the default brightness and colors.
        // brightness: Brightness.dark,
        primaryColor: color.primery_color,
        //   accentColor: Theme.colors.button,
      ),
      // Define the default font family.
      home: Scaffold(
          key: _scaffoldKey,
          backgroundColor: color.white,
          body: SingleChildScrollView(
            child: Container(
              //color: Theme.colors.myred,
              child: Stack(
                children: [
                  Container(
                    color: color.primery_color_dark,
                    height: MediaQuery.of(context).size.height / 3,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 0, top: 0, right: 0, bottom: 50.0),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 2,
                          child: new Image.asset(
                            "assets/logo.png",
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 0.0,
                        top: (MediaQuery.of(context).size.height / 3.0) - 40,
                        right: 0.0,
                        bottom: 0.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color.white,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(40.0),
                          topLeft: Radius.circular(40.0),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                        child: Container(
                          color: Colors.transparent,
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 40.0, bottom: 0.0),
                                child: Text(
                                  "Login",
                                  style: new TextStyle(
                                      fontSize: 25.0,
                                      fontFamily: 'poppins_bold'),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 0.0),
                                child: Text(
                                  "Enter Your Login Detail here",
                                  style: new TextStyle(
                                      fontSize: 15.0,
                                      fontFamily: 'poppins_medium'),
                                ),
                              ),
                              Divider(
                                indent: 100,
                                endIndent: 100,
                                thickness: 3,
                                color: color.primery_color,
                              ),
                              Container(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20.0, top: 30),
                                      child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            "Mobile Number",
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontFamily: 'poppins_medium'),
                                          )),
                                    ),
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 10.0),
                                          child: Container(
                                              width: 120,
                                              height: 60,
                                              child: InputDecorator(
                                                  decoration: InputDecoration(
                                                    fillColor: color.light_gray,
                                                    filled: true,
                                                    //   suffixIcon: Icon(Icons.phone),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                            // width: 0.0 produces a thin "hairline" border
                                                            borderSide: BorderSide(
                                                                color: color
                                                                    .light_gray),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        25.0)),
                                                    focusedBorder:
                                                        new OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: color
                                                                        .gray),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        25.0)),
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    25.0)),
                                                    // labelText: 'Phone number',
                                                  ),
                                                  isEmpty:
                                                      _selected_contury_code ==
                                                          '',
                                                  child:
                                                      DropdownButtonHideUnderline(
                                                          child:
                                                          IgnorePointer(
                                                            ignoring: false,
                                                                child: new DropdownButton<
                                                                    String>(
                                                    hint:
                                                        new Text("Select Code"),
                                                    value:
                                                        _selected_contury_code,
                                                    isDense: true,
                                                    isExpanded: true,
                                                    onChanged:
                                                        (String newValue) {
                                                      print(newValue);
                                                      setState(() {
                                                        _selected_contury_code =
                                                            newValue;
                                                      });
                                                      print(
                                                          _selected_contury_code);
                                                    },
                                                    selectedItemBuilder:
                                                        (BuildContext context) {
                                                      return contry_data
                                                          .map<Widget>(
                                                                (GenrelModel
                                                                        item) =>
                                                                    Text(item
                                                                        .code))
                                                          .toList();
                                                    },
                                                    items: contry_data
                                                        .map((GenrelModel map) {
                                                      return new DropdownMenuItem<
                                                          String>(
                                                        value: map.code,
                                                        child: Padding(
                                                          padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    bottom: 25.0),
                                                          child: new Text(
                                                            map.code +
                                                                  "\n" +
                                                                  map.country +
                                                                  "\n\n",
                                                            maxLines: 2,
                                                            style: new TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                              )))),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                top: 10.0,
                                                bottom: 10.0,
                                                left: 0.0,
                                                right: 0.0),
                                            child: TextFormField(
                                              controller: mobileController,
                                              keyboardType: TextInputType.phone,
                                              decoration: InputDecoration(
                                                  fillColor: color.light_gray,
                                                  filled: true,
                                                  //   suffixIcon: Icon(Icons.phone),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                          // width: 0.0 produces a thin "hairline" border
                                                          borderSide:
                                                              BorderSide(
                                                                  color: color
                                                                      .light_gray),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      25.0)),
                                                  focusedBorder:
                                                      new OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: color
                                                                      .gray),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      25.0)),
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25.0)),
                                                  hintText:
                                                      "Enter Mobile Number",
                                                  hintStyle: TextStyle(
                                                      color: color.hint_color,
                                                      fontSize: 14)
                                                  // labelText: 'Phone number',
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Visibility(
                                maintainSize: false,
                                maintainAnimation: true,
                                maintainState: true,
                                visible: widgetVisible,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20.0, top: 5.0),
                                      child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            "OTP",
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontFamily: 'poppins_medium'),
                                          )),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(
                                            top: 10.0,
                                            bottom: 10.0,
                                            left: 0.0,
                                            right: 0.0),
                                        child: TextFormField(
                                          controller: otpController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                              fillColor: color.light_gray,
                                              filled: true,
                                              enabledBorder: OutlineInputBorder(
                                                  // width: 0.0 produces a thin "hairline" border
                                                  borderSide: BorderSide(
                                                      color: color.light_gray),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25.0)),
                                              focusedBorder:
                                                  new OutlineInputBorder(
                                                      borderSide:
                                                          BorderSide(
                                                              color:
                                                                  color.gray),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25.0)),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25.0)),
                                              hintText: "Enter OTP",
                                              hintStyle: TextStyle(
                                                  fontSize: 14,
                                                  color: color.hint_color)

                                              //  labelText: 'OTP',
                                              ),
                                        )),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          "Not Received ? ",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'poppins_medium'),
                                        ),
                                        InkWell(
                                          onTap: () async {
                                            if(mobileController.text==_default_number){
                                              Login(mobileController.text,"","verify");
                                            }else{
                                            // if (otp_send_success == false) {
                                            if (mobileController.text != "") {
                                              if (is_connected) {
                                                loginClick = true;
                                                verifyPhoneNumber();
                                                /* await SendOtp(
                                                  mobileController.text,
                                                );*/
                                              } else {
                                                loginClick = false;
                                                SnackBarFail(
                                                    "Please Check Your Internet connection",
                                                    context,
                                                    _scaffoldKey);
                                              }
                                            } else {
                                              loginClick = false;

                                              SnackBarFail(
                                                  "Please Enter Mobile No",
                                                  context,
                                                  _scaffoldKey);
                                            }}
                                            // }
                                          },
                                          child: Text(
                                            "Resend OTP",
                                            style: TextStyle(
                                                color: color.resend,
                                                fontSize: 12,
                                                fontFamily:
                                                    'poppins_medium_italic'),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 10.0,
                                    bottom: 15.0,
                                    left: 0.0,
                                    right: 0.0),
                                child: MaterialButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(25)),
                                    color: color.primery_color,
                                    height: 50,
                                    minWidth:
                                        MediaQuery.of(context).size.width / 2,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0, horizontal: 18.0),
                                      child: Stack(
                                        children: [
                                          Text(
                                            login_button_text,
                                            style: TextStyle(
                                              fontFamily: 'poppins_medium',
                                              color: Colors.white,
                                              fontSize: 16.0,
                                            ),
                                          ),
                                          Visibility(
                                              maintainSize: false,
                                              maintainAnimation: true,
                                              maintainState: true,
                                              visible: loginClick,
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              )),
                                        ],
                                      ),
                                    ),
                                    onPressed: () async {
    if(mobileController.text==_default_number){
    Login(mobileController.text,"","verify");
    }else {
      if (otp_send_success == false) {
        if (mobileController.text != "") {
          if (is_connected) {
            loginClick = true;
            Login(mobileController.text,
                otpController.text,
                "check");
            //verifyPhoneNumber();
            /* await SendOtp(
                                              mobileController.text,
                                            );*/
          } else {
            loginClick = false;

            SnackBarFail(
                "Please Check Your Internet connection",
                context,
                _scaffoldKey);
          }
        } else {
          loginClick = false;

          SnackBarFail("Please Enter Mobile No",
              context, _scaffoldKey);
        }
      } else if (mobileController.text != "" &&
          otpController.text != "") {
        if (is_connected) {
          signInWithPhoneNumber();
          /*await Login(mobileController.text,
                                              otpController.text);*/
        } else {
          loginClick = false;

          SnackBarFail(
              "Please Check Your Internet connection",
              context,
              _scaffoldKey);
        }
      } else {
        loginClick = false;

        SnackBarFail("Please Enter Detail",
            context, _scaffoldKey);
      }
    }
                                      //   userBlockDialog();
                                      //showInSnackBarFail("testtt");
                                    }),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CreateAccount()),
                                  );
                                },
                                child: Text(
                                  "Create New Account",
                                  style: new TextStyle(
                                      fontFamily: 'poppins_redular',
                                      fontSize: 15.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  /* Visibility(
                      maintainSize: false,
                      maintainAnimation: true,
                      maintainState: true,
                      visible: loginClick,
                      child: Center(
                        child: Container(
                            margin: EdgeInsets.only(top: statusBarHeight),
                            child: LinearProgressIndicator()),
                      )),*/
                ],
              ),
            ),
          )),
    );
  }

  Future<void> userBlockDialog() async {
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
                height: 400,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 0, top: 20.0, right: 0, bottom: 0),
                        child: Center(
                          child: SizedBox(
                            height: 200.0,
                            width: 200.0,
                            child: new Image.asset(
                              "assets/blocked_user.jpg",
                              fit: BoxFit.contain,
                            ),
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
                            "You are blocked by admin ",
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
                                Navigator.pop(context, true);
                              },
                              child: Text(
                                "Ok",
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
