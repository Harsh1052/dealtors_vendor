import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:dealtors_vendor/SelectCategoryPage.dart';
import 'package:dealtors_vendor/WelcomePage.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dealtors_vendor/style/Color.dart' as color;
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:dealtors_vendor/netutils/Retrofit.dart' as retrofit;
import 'dart:convert';

import 'CustomWidget/ToastFile.dart';
import 'HomePage.dart';
import 'Model/GenrelModel.dart';
import 'netutils/preferences.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

String _verificationId = "";
final FirebaseAuth _auth = FirebaseAuth.instance;
PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout;
PhoneVerificationFailed verificationFailed;
PhoneCodeSent codeSent;

class _CreateAccountState extends State<CreateAccount> {
  bool is_connected = false, widgetVisible = false;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  String button_text = "Verify";
  bool otp_send_success = false;
  String _selected_contury_code = "+852";
  List<GenrelModel> contry_data = new List();

  final otpController = TextEditingController();
  final mobileController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool loginClick = false;
  var result;
  PhoneVerificationCompleted verificationCompleted =
      (PhoneAuthCredential phoneAuthCredential) async {
    await _auth.signInWithCredential(phoneAuthCredential);
    print(
        "Phone number automatically verified and user signed in: ${_auth.currentUser.uid}");
    // showSnackbar("Phone number automatically verified and user signed in: ${_auth.currentUser.uid}");
  };

  void verifyPhoneNumber() async {
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
      otp_send_success = false;

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
      await signup(
          nameController.text,
          emailController.text,
          mobileController.text,
          otpController.text);
      // Login(mobileController.text, otpController.text);
      //  showSnackbar("Successfully signed in UID: ${user.uid}");
    } catch (e) {
      setState(() {
        loginClick = false;
      });
      otpController.text = "";
      SnackBarFail("Verification Fail", context, _scaffoldKey);
      print("Failed to sign in: " + e.toString());
      //    showSnackbar("Failed to sign in: " + e.toString());
    }
  }

  Future<String> getContury() async {
    var response = await retrofit.getContury();
    setState(() {
      var extractdata = json.decode(response.body);
      print(extractdata);
      if (extractdata['ack'] == 1) {
        _selected_contury_code = extractdata['country_code'];

        contry_data = List<GenrelModel>.from(
            extractdata["result"].map((x) => GenrelModel.fromJson(x)));
        print(extractdata['ack_msg']);
      } else {
        print(extractdata['ack_msg']);
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    // _populateData();
    super.initState();
    otp_send_success = false;
    loginClick = false;
    button_text = "Verify";
    getContury();
    codeSent = (String verificationId, [int forceResendingToken]) async {
      setState(() {
        showWidget();
      });
      loginClick = false;
      otp_send_success = true;
      button_text = " Next ";
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
      setState(() {
        loginClick = false;
      });

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
      //showSnackbar('Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');
    };
    _auth.setLanguageCode("en");
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
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

  Future<String> signup(
      String name, String email_address, String mobile_no,String otp) async {
    setState(() {
      loginClick = true;
    });
    var response = await retrofit.signup(name, email_address, mobile_no,otp);
    setState(() {
      var extractdata = json.decode(response.body);
      print(extractdata);
      if (extractdata['ack'] == 1) {
        result = extractdata["result"];
        print("user id -- " + result['id']);

        SharedPreferencesHelper.setPreference("user_id", result["id"]);
        SharedPreferencesHelper.setPreference("name", result["first_name"]);
        // SharedPreferencesHelper.setPreference("business_name", result["business_name"]);
        SharedPreferencesHelper.setPreference("mobile_no", result["mobile_no"]);
        SharedPreferencesHelper.setPreference(
            "email_address", result["email_address"]);
        //  print("3 is active"+ result['isActive'] );
        //  SnackBarSuccess(extractdata['ack_msg'], context, _scaffoldKey);

        showTermsandCondition(result['terms_condition']);
        loginClick = false;

        print(extractdata['ack_msg']);
      } else {
        SnackBarFail(extractdata['ack_msg'], context, _scaffoldKey);
        print(extractdata['ack_msg']);
        loginClick = false;
      }
    });
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
          backgroundColor: color.white,
          key: _scaffoldKey,
          body: SingleChildScrollView(
            child: Container(
              color: color.white,
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
                        color: Colors.white,
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
                                  "Create Account",
                                  style: new TextStyle(
                                      fontSize: 25.0,
                                      fontFamily: 'poppins_bold'),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 0.0),
                                child: Text(
                                  "Enter Your Personal Details here",
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
                                                fontFamily:
                                                'poppins_medium'),
                                          )),
                                    ),
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right:10.0),
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
                                                                padding: const EdgeInsets.only(bottom:25.0),
                                                                child: new Text(
                                                                  map.code +
                                                                      "\n" +
                                                                      map.country+"\n\n",
                                                                  maxLines: 2,
                                                                  style: new TextStyle(
                                                                      color:
                                                                      Colors.black),
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
                                                      borderSide: BorderSide(
                                                          color: color
                                                              .light_gray),
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                          25.0)),
                                                  focusedBorder:
                                                  new OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: color.gray),
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                          25.0)),
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          25.0)),
                                                  hintText: "Enter Mobile Number",
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
                                            //if (otp_send_success == false) {
                                            if (mobileController.text != "") {
                                              if (is_connected) {
                                                ////if (otp_send_success == false) {
                                                setState(() {
                                                  loginClick = true;
                                                });
                                                verifyPhoneNumber();
                                                //  }
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
                                            }
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
                                padding:
                                const EdgeInsets.only(left: 20.0, top: 5),
                                child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      "Owner Full Name ",
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
                                  controller: nameController,
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                      fillColor: color.light_gray,
                                      filled: true,
                                      //   suffixIcon: Icon(Icons.phone),
                                      enabledBorder: OutlineInputBorder(
                                        // width: 0.0 produces a thin "hairline" border
                                          borderSide: BorderSide(
                                              color: color.light_gray),
                                          borderRadius:
                                          BorderRadius.circular(25.0)),
                                      focusedBorder: new OutlineInputBorder(
                                          borderSide:
                                          BorderSide(color: color.gray),
                                          borderRadius:
                                          BorderRadius.circular(25.0)),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(25.0)),
                                      hintText: "Enter your full name here",
                                      hintStyle: TextStyle(
                                        color: color.hint_color,
                                        fontSize: 14,
                                      )
                                    // labelText: 'Phone number',
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                const EdgeInsets.only(left: 20.0, top: 5),
                                child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      "Email Address",
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
                                  controller: emailController,
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                      fillColor: color.light_gray,
                                      filled: true,
                                      //   suffixIcon: Icon(Icons.phone),
                                      enabledBorder: OutlineInputBorder(
                                        // width: 0.0 produces a thin "hairline" border
                                          borderSide: BorderSide(
                                              color: color.light_gray),
                                          borderRadius:
                                          BorderRadius.circular(25.0)),
                                      focusedBorder: new OutlineInputBorder(
                                          borderSide:
                                          BorderSide(color: color.gray),
                                          borderRadius:
                                          BorderRadius.circular(25.0)),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(25.0)),
                                      hintText: "Enter your email address here",
                                      hintStyle: TextStyle(
                                          fontSize: 14, color: color.hint_color)
                                    // labelText: 'Phone number',
                                  ),
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
                                    height: 50.0,
                                    minWidth:
                                    MediaQuery.of(context).size.width / 2,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0, horizontal: 18.0),
                                      child: Stack(
                                        children: [
                                          Text(
                                            button_text,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15.0,
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
                                      if (is_connected) {
                                        if (loginClick == false) {
                                          if (mobileController.text == "") {
                                            loginClick = false;
                                            SnackBarFail(
                                                "Please Enter Mobile Number",
                                                context,
                                                _scaffoldKey);
                                          } else if (nameController.text ==
                                              "") {
                                            loginClick = false;
                                            SnackBarFail("Please Enter Name",
                                                context, _scaffoldKey);
                                          } else if (emailController.text ==
                                              "") {
                                            loginClick = false;
                                            SnackBarFail("Please Enter Email",
                                                context, _scaffoldKey);
                                          } else if (!EmailValidator.validate(
                                              emailController.text)) {
                                            loginClick = false;
                                            SnackBarFail(
                                                "Please Enter Valid Email",
                                                context,
                                                _scaffoldKey);
                                          } else {
                                            /*signup(
                                                nameController.text,
                                                emailController.text,
                                                _selected_contury_code +
                                                    "" +
                                                    mobileController.text,
                                                otpController.text);*/
                                            if (otp_send_success == false) {
                                              setState(() {
                                                loginClick = true;
                                              });
                                              verifyPhoneNumber();
                                            } else {
                                              setState(() {
                                                loginClick = true;
                                              });
                                              signInWithPhoneNumber();
                                            }
                                          }
                                        }
                                        /* else {
                                        SnackBarFail(
                                            "Still Your old process working",
                                            context,
                                            _scaffoldKey);
                                      }*/
                                      } else {
                                        loginClick = false;

                                        SnackBarFail(
                                            "Please Check Your Internet connection",
                                            context,
                                            _scaffoldKey);
                                      }
                                    }),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "Already have an account? Login Now",
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
                  /*Visibility(
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

  Future<void> showTermsandCondition(String value) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.all(15.0),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40.0)), //this right here
          child: Container(
            //height: MediaQuery.of(context).size.height - 80,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 20.0, top: 20.0, bottom: 10.0, right: 20.0),
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context, true);
                    },
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Icon(
                        Icons.cancel,
                        color: color.red,
                        size: 24.0,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Terms & Conditions",
                      textAlign: TextAlign.center,
                      style:
                      TextStyle(fontFamily: 'poppins_bold', fontSize: 25),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 0, top: 30.0, right: 0, bottom: 0),
                        child: Html(
                          data: value,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width / 2,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => HomePage(),
                            ),
                                (route) => false,
                          );
                        },
                        child: Text(
                          " I Accept",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: color.primery_color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
