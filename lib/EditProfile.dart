import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:dealtors_vendor/netutils/preferences.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:dealtors_vendor/style/Color.dart' as color;
import 'package:dealtors_vendor/netutils/Retrofit.dart' as retrofit;
import 'package:flutter/services.dart';
import 'dart:convert';

import 'AccountVerifyFailedPage.dart';
import 'CustomWidget/ToastFile.dart';
import 'WaitingForApprovel.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool isProgress = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final mobileController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  var result;
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
        getPrafrence();
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
          getPrafrence();
        });
        break;
      case ConnectivityResult.mobile:
        setState(() {
          is_connected = true;
          getPrafrence();
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

  Future<String> editProfile() async {
    setState(() {
      isProgress = true;
    });
    var response = await retrofit.editProfile(
        await SharedPreferencesHelper.getPreference("user_id"),
        nameController.text,
        emailController.text,
        mobileController.text);

    setState(() {
      var extractdata = json.decode(response.body);
      print(extractdata);
      if (extractdata['ack'] == 1) {
        result = extractdata["result"];
        print("user id -- " + result['id']);
        SharedPreferencesHelper.setPreference("user_id", result["id"]);
        SharedPreferencesHelper.setPreference("name", result["first_name"]);
        SharedPreferencesHelper.setPreference("mobile_no", result["mobile_no"]);
        SharedPreferencesHelper.setPreference(
            "email_address", result["email_address"]);
        //  print("3 is active"+ result['isActive'] );
        // SnackBarSuccess(extractdata['ack_msg'], context, _scaffoldKey);
        isProgress = false;
        // print(result['ack_msg']);

        if (result['status'] ==
            "2") //array("1"=>"Active","2"=>"Rejected","3"=>"Under approval","4"=>"Blocked");
        {
          Route otproute = MaterialPageRoute(
              builder: (context) => AccountVerifyFailedPage(
                  msg: result['status_message'], type: result['status']));
          Navigator.pushReplacement(context, otproute);
        } else if (result['status'] == "4") {
          Route otproute = MaterialPageRoute(
              builder: (context) => AccountVerifyFailedPage(
                  msg: result['status_message'], type: result['status']));
          Navigator.pushReplacement(context, otproute);
        } else if (result['status'] ==
            "3") //array("1"=>"Active","2"=>"Rejected","3"=>"Under approval","4"=>"Blocked");
        {
          Route otproute =
              MaterialPageRoute(builder: (context) => WaitingForApprovel());
          Navigator.pushReplacement(context, otproute);
        } else {
          Navigator.pop(context);
        }
      } else {
        isProgress = false;
        // SnackBarFail(extractdata['ack_msg'], context, _scaffoldKey);
        print(extractdata['ack_msg']);
        Navigator.pop(context);
      }
    });
  }


  getPrafrence() async {
    nameController.text = await SharedPreferencesHelper.getPreference("name");
    emailController.text =
        await SharedPreferencesHelper.getPreference("email_address");
    mobileController.text =
        await SharedPreferencesHelper.getPreference("mobile_no");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        // Define the default brightness and colors.
        // brightness: Brightness.dark,
        primaryColor: color.primery_color_dark,
        //   accentColor: Theme.colors.button,
      ),
      home: Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          shadowColor: null,
          elevation: 0.0,
          // backgroundColor: color.white,
          title: Text(
            "Edit Profile",
            style: TextStyle(color: color.white),
          ),
          leading: new IconButton(
              icon: new Icon(
                Icons.arrow_back_ios_rounded,
                color: color.white,
              ),
              onPressed: () => Navigator.pop(context)),
        ),
        body: Container(
          child: Padding(
            padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 20),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, top: 20),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Mobile Number",
                        style: TextStyle(
                            fontSize: 12, fontFamily: 'poppins_medium'),
                      )),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: 10.0, bottom: 10.0, left: 0.0, right: 0.0),
                  child: TextFormField(
                    controller: mobileController,
                    keyboardType: TextInputType.number,
                    readOnly: true,
                    decoration: InputDecoration(
                        fillColor: color.light_gray,
                        filled: true,
                        //   suffixIcon: Icon(Icons.phone),
                        enabledBorder: OutlineInputBorder(
                            // width: 0.0 produces a thin "hairline" border
                            borderSide: BorderSide(color: color.light_gray),
                            borderRadius: BorderRadius.circular(25.0)),
                        focusedBorder: new OutlineInputBorder(
                            borderSide: BorderSide(color: color.gray),
                            borderRadius: BorderRadius.circular(25.0)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0)),
                        hintText: "Enter Mobile Number",
                        hintStyle: TextStyle(
                          color: color.hint_color,
                          fontSize: 14,
                        )
                        // labelText: 'Phone number',
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, top: 5),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Owner Full Name",
                        style: TextStyle(
                            fontSize: 12, fontFamily: 'poppins_medium'),
                      )),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: 10.0, bottom: 10.0, left: 0.0, right: 0.0),
                  child: TextFormField(
                    controller: nameController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        fillColor: color.light_gray,
                        filled: true,
                        //   suffixIcon: Icon(Icons.phone),
                        enabledBorder: OutlineInputBorder(
                            // width: 0.0 produces a thin "hairline" border
                            borderSide: BorderSide(color: color.light_gray),
                            borderRadius: BorderRadius.circular(25.0)),
                        focusedBorder: new OutlineInputBorder(
                            borderSide: BorderSide(color: color.gray),
                            borderRadius: BorderRadius.circular(25.0)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0)),
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
                  padding: const EdgeInsets.only(left: 20.0, top: 5),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Email Address",
                        style: TextStyle(
                            fontSize: 12, fontFamily: 'poppins_medium'),
                      )),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: 10.0, bottom: 10.0, left: 0.0, right: 0.0),
                  child: TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        fillColor: color.light_gray,
                        filled: true,
                        //   suffixIcon: Icon(Icons.phone),
                        enabledBorder: OutlineInputBorder(
                            // width: 0.0 produces a thin "hairline" border
                            borderSide: BorderSide(color: color.light_gray),
                            borderRadius: BorderRadius.circular(25.0)),
                        focusedBorder: new OutlineInputBorder(
                            borderSide: BorderSide(color: color.gray),
                            borderRadius: BorderRadius.circular(25.0)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0)),
                        hintText: "Enter your email address here",
                        hintStyle:
                            TextStyle(fontSize: 14, color: color.hint_color)
                        // labelText: 'Phone number',
                        ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: 10.0, bottom: 15.0, left: 0.0, right: 0.0),
                  child: MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      color: color.primery_color,
                      height: 50.0,
                      minWidth: MediaQuery.of(context).size.width / 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 18.0),
                        child: Text(
                          "  Next  ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                          ),
                        ),
                      ),
                      onPressed: () async {
                        if (is_connected) {
                          if (isProgress == false) {
                            if (mobileController.text == "") {
                              isProgress = false;
                              SnackBarFail("Please Enter Mobile Number",
                                  context, _scaffoldKey);
                            } else if (nameController.text == "") {
                              isProgress = false;
                              SnackBarFail(
                                  "Please Enter Name", context, _scaffoldKey);
                            } else if (emailController.text == "") {
                              isProgress = false;
                              SnackBarFail(
                                  "Please Enter Email", context, _scaffoldKey);
                            } else if (!EmailValidator.validate(
                                emailController.text)) {
                              isProgress = false;
                              SnackBarFail("Please Enter Valid Email", context,
                                  _scaffoldKey);
                            } else {
                              try {
                                await editProfile();
                              } catch (e) {
                                print(e);
                              }
                            }
                          }
                          /*else {
                            SnackBarFail("Still Your old process working",
                                context, _scaffoldKey);
                          }*/
                        } else {
                          isProgress = false;
                          SnackBarFail("Please Check Your Internet", context,
                              _scaffoldKey);
                        }
                      }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
