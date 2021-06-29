import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:dealtors_vendor/AccountVerifyPage.dart';
import 'package:dealtors_vendor/HomePage.dart';
import 'package:dealtors_vendor/ValidateCoupon.dart';
import 'package:flutter/material.dart';
import 'package:dealtors_vendor/style/Color.dart' as color;
import 'package:flutter/services.dart';
import 'package:dealtors_vendor/netutils/Retrofit.dart' as retrofit;
import 'dart:convert';

import 'CustomWidget/ToastFile.dart';
import 'Model/Coupon.dart';
import 'netutils/preferences.dart';
import 'package:intl/intl.dart';

class CreateCoupon extends StatefulWidget {
  String id;

  CreateCoupon({Key key, this.id}) : super(key: key);

  @override
  _AddRestaurantPageState createState() => _AddRestaurantPageState();
}

class _AddRestaurantPageState extends State<CreateCoupon> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final startdateController = TextEditingController();
  final expdateController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isProgress = false;
  var result;
  List<CouponDetail> coupon_data;
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
        if (widget.id != null && widget.id != "") {
          getCouponDetail();
        }
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
          if (widget.id != null && widget.id != "") {
            getCouponDetail();
          }
        });
        break;
      case ConnectivityResult.mobile:
        setState(() {
          is_connected = true;
          if (widget.id != null && widget.id != "") {
            getCouponDetail();
          }
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

  Future<String> getCouponDetail() async {
    isProgress = true;
    var response = await retrofit.getCouponDetail(
        await SharedPreferencesHelper.getPreference("user_id"), widget.id);
    setState(() {
      var extractdata = json.decode(response.body);
      /* ack = extractdata['ack'].toString();
      ack_msg = extractdata['ack_msg'].toString();
     */
      if (extractdata['ack'] == 1) {
        try {
          coupon_data = List<CouponDetail>.from(
              extractdata["result"].map((x) => CouponDetail.fromJson(x)));
          titleController.text = "" + extractdata['result'][0]['title'];
          descController.text = "" + extractdata['result'][0]['description'];
          startdateController.text =
              "" + extractdata['result'][0]['start_date'];
          expdateController.text = "" + extractdata['result'][0]['expiry_date'];
          //coupon_data = vendor_detail[0].coupons;
        } catch (e) {
          print(e);
        }
        isProgress = false;
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

  Future<String> addCoupon(
      String title, String desc, String start_date, String end_date) async {
    setState(() {
      isProgress = true;
    });
    var response = await retrofit.addCoupon(
        await SharedPreferencesHelper.getPreference("user_id"),
        title,
        desc,
        start_date,
        end_date);
    setState(() {
      var extractdata = json.decode(response.body);
      print(extractdata);
      if (extractdata['ack'] == 1) {
        //  result = extractdata["result"];
        SnackBarSuccess(extractdata['ack_msg'], context, _scaffoldKey);
        isProgress = false;
        print(extractdata['ack_msg']);
        Navigator.pop(context);
      } else {
        SnackBarFail(extractdata['ack_msg'], context, _scaffoldKey);
        print(extractdata['ack_msg']);
        isProgress = false;
      }
    });
  }

  Future<String> editCoupon(
      String title, String desc, String start_date, String end_date) async {
    setState(() {
      isProgress = true;
    });
    var response = await retrofit.editCoupon(
        await SharedPreferencesHelper.getPreference("user_id"),
        title,
        desc,
        start_date,
        end_date,
        widget.id);
    setState(() {
      var extractdata = json.decode(response.body);
      print(extractdata);
      if (extractdata['ack'] == 1) {
        //  result = extractdata["result"];
        SnackBarSuccess(extractdata['ack_msg'], this.context, _scaffoldKey);
        isProgress = false;
        print(extractdata['ack_msg']);
        Navigator.pop(this.context);
      } else {
        SnackBarFail(extractdata['ack_msg'], this.context, _scaffoldKey);
        print(extractdata['ack_msg']);
        isProgress = false;
      }
    });
  }

  DateTime selectedDate = DateTime.now();

  Future<void> _startselectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        startdateController.text = myFormat.format(picked);
      });
  }

  var myFormat = DateFormat('d-MM-yyyy');
  Future<void> _expselectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: selectedDate.subtract(Duration(days: 0)),
        lastDate: DateTime(2101));
    if (picked != null)
      setState(() {
        expdateController.text = myFormat.format(picked);
        //  selectedDate = picked;
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
                                  "Create Your Coupon",
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontFamily: 'poppins_bold',
                                      color: color.white),
                                ),
                                Text(
                                  "Enter Your Coupon Details here ",
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
                                  "Coupon Title",
                                  style:
                                      TextStyle(fontFamily: 'poppins_medium'),
                                )),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: 10.0, bottom: 10.0, left: 0.0, right: 0.0),
                            child: TextFormField(
                              controller: titleController,
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
                                  hintText: "Enter your Coupon Title here",
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
                                  "Coupon Description",
                                  style:
                                      TextStyle(fontFamily: 'poppins_medium'),
                                )),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: 10.0, bottom: 10.0, left: 0.0, right: 0.0),
                            child: TextFormField(
                              controller: descController,
                              keyboardType: TextInputType.multiline,
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
                                hintText:
                                    "Enter Full Detail About Your Coupn here",
                                hintStyle: TextStyle(color: color.hint_color),

                                // labelText: 'Phone number',
                              ),
                              maxLines: 5,
                            ),
                          ),
                          Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 20.0, top: 20),
                                child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      "Start Date",
                                      style: TextStyle(
                                          fontFamily: 'poppins_medium'),
                                    )),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 10.0,
                                    bottom: 0.0,
                                    left: 0.0,
                                    right: 0.0),
                                child: InkWell(
                                  onTap: () {
                                    _startselectDate(context);
                                  },
                                  child: TextFormField(
                                    autofocus: false,
                                    enabled: false,
                                    showCursor: false,
                                    controller: startdateController,
                                    decoration: InputDecoration(
                                        suffixIcon:
                                            new Icon(Icons.date_range_sharp),
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
                                        hintText: "Start Date",
                                        hintStyle:
                                            TextStyle(color: color.hint_color)
                                        // labelText: 'Phone number',
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0, top: 20),
                            child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "Expiry Date",
                                  style:
                                      TextStyle(fontFamily: 'poppins_medium'),
                                )),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: 10.0, bottom: 0.0, left: 0.0, right: 0.0),
                            child: InkWell(
                              onTap: () {
                                _expselectDate(context);
                              },
                              child: TextFormField(
                                autofocus: false,
                                enabled: false,
                                showCursor: false,
                                controller: expdateController,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                    suffixIcon:
                                        new Icon(Icons.date_range_sharp),
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
                                        borderSide:
                                            BorderSide(color: color.gray),
                                        borderRadius:
                                            BorderRadius.circular(25.0)),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(25.0)),
                                    hintText: "Expire Date",
                                    hintStyle:
                                        TextStyle(color: color.hint_color)
                                    // labelText: 'Phone number',
                                    ),
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
                                      "  Publish  ",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15.0,
                                      ),
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (is_connected) {
                                      if (isProgress == false) {
                                        if (titleController.text == "") {
                                          SnackBarFail("Please Enter Title",
                                              context, _scaffoldKey);
                                        } else if (descController.text == "") {
                                          SnackBarFail(
                                              "Please Enter Description",
                                              context,
                                              _scaffoldKey);
                                        } else if (startdateController.text ==
                                            "") {
                                          SnackBarFail(
                                              "Please Enter Start Date",
                                              context,
                                              _scaffoldKey);
                                        } else if (expdateController.text ==
                                            "") {
                                          SnackBarFail(
                                              "Please Enter expire Date",
                                              context,
                                              _scaffoldKey);
                                        } else {
                                          if (widget.id == null ||
                                              widget.id == "") {
                                            //print(descController.text);
                                            await addCoupon(
                                              titleController.text,
                                              descController.text,
                                              startdateController.text,
                                              expdateController.text,
                                            );
                                          } else {
                                            await editCoupon(
                                              titleController.text,
                                              descController.text,
                                              startdateController.text,
                                              expdateController.text,
                                            );
                                          }
                                        }
                                      }
                                    } else {
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
}
