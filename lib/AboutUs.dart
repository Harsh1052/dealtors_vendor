import 'dart:async';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:dealtors_vendor/netutils/Retrofit.dart' as retrofit;
import 'package:dealtors_vendor/style/Color.dart' as color;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';

import 'netutils/preferences.dart';

class AboutUs extends StatefulWidget {
  @override
  _AboutUsState createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  bool isProgress = false;

  var about_data = "", mobile_no = "", email = "";

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
        this.getAboutUs();
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
          this.getAboutUs();
        });
        break;
      case ConnectivityResult.mobile:
        setState(() {
          is_connected = true;
          this.getAboutUs();
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

  Future<String> getAboutUs() async {
    isProgress = true;
    var response = await retrofit
        .aboutUs(await SharedPreferencesHelper.getPreference("user_id"));
    setState(() {
      var extractdata = json.decode(response.body);
      // print(extractdata);
      // ack = extractdata["ack"];
      if (extractdata['ack'] == 1) {
        try {
          about_data = extractdata['about_us'];
          mobile_no = extractdata['contact_no'];
          email = extractdata['email_address'];
          //coupon_data = vendor_detail[0].coupons;
        } catch (e) {
          print(e);
        }
      } else if (extractdata['ack'] == 2) {
        isProgress = false;
        SharedPreferencesHelper.clearAllPreference();
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/loginpage', (Route<dynamic> route) => false);
        // print(extractdata['ack_msg']);
      } else {
        isProgress = false;
        // print(extractdata['ack_msg']);
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
        primaryColor: color.primery_color_dark,
        //   accentColor: Theme.colors.button,
      ),
      home: Scaffold(
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
                      padding: EdgeInsets.only(
                          bottom: 0.0, top: statusBarHeight + 10),
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
                                  "About Us",
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontFamily: 'poppins_bold',
                                      color: color.white),
                                ),
                                Text(
                                  "know more about us",
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
                  padding: const EdgeInsets.only(top: 120.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(40.0),
                        topLeft: Radius.circular(40.0),
                      ),
                    ),
                    child: !is_connected
                        ? Container(
                            width: MediaQuery.of(context).size.width,
                            color: color.red,
                            child: Center(
                                child: Text(
                              "No Internet",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: color.white),
                            )),
                          )
                        : about_data == null
                            ? Visibility(
                                maintainSize: false,
                                maintainAnimation: true,
                                maintainState: true,
                                visible: isProgress,
                                child: Center(
                                  child: Container(
                                      margin:
                                          EdgeInsets.only(top: statusBarHeight),
                                      child: LinearProgressIndicator()),
                                ))
                            : Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    Html(
                                      data:
                                          about_data != null ? about_data : "",
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey,
                                            width: 1,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 20, right: 20),
                                          child: Row(
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: SizedBox(
                                                  width: 50.0,
                                                  height: 50.0,
                                                  child: Image.asset(
                                                      "assets/whatsapp_icon.png"),
                                                ),
                                              ),
                                              /*
                                              Text(
                                                "Contact Us",
                                                style: TextStyle(fontSize: 15),
                                                textAlign: TextAlign.left,
                                              ),
                                               */
                                              Expanded(
                                                child: Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Text(
                                                      mobile_no,
                                                      style: TextStyle(
                                                          fontSize: 15),
                                                      textAlign: TextAlign.left,
                                                    )),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey,
                                            width: 1,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 20, right: 20),
                                          child: Row(
                                            children: [
                                              Align(
                                                  child: Text(
                                                "Email",
                                                style: TextStyle(fontSize: 15),
                                                textAlign: TextAlign.left,
                                              )),
                                              Expanded(
                                                child: Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Text(
                                                      email,
                                                      style: TextStyle(
                                                          fontSize: 15),
                                                      textAlign: TextAlign.left,
                                                    )),
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
