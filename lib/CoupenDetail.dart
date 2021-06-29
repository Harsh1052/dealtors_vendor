import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:dealtors_vendor/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:dealtors_vendor/style/Color.dart' as color;
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';

import 'CustomWidget/AlertForCoupon.dart';
import 'CustomWidget/empty.dart';
import 'Model/Coupon.dart';
import 'package:dealtors_vendor/netutils/Retrofit.dart' as retrofit;
import 'dart:convert';

import 'netutils/preferences.dart';

class CoupenDetail extends StatefulWidget {
  String item_id, cat_name;

  CoupenDetail({Key key, this.item_id, this.cat_name}) : super(key: key);

  @override
  _CoupenDetailState createState() => _CoupenDetailState();
}

class _CoupenDetailState extends State<CoupenDetail> {
  List<CouponDetail> coupon_data;
  bool isProgress = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String ack = "", ack_msg = "";
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
        getCouponDetail();
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
          getCouponDetail();
        });
        break;
      case ConnectivityResult.mobile:
        setState(() {
          is_connected = true;
          getCouponDetail();
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
        await SharedPreferencesHelper.getPreference("user_id"), widget.item_id);
    setState(() {
      var extractdata = json.decode(response.body);
      ack = extractdata['ack'].toString();
      ack_msg = extractdata['ack_msg'].toString();
      if (extractdata['ack'] == 1) {
        try {
          coupon_data = List<CouponDetail>.from(
              extractdata["result"].map((x) => CouponDetail.fromJson(x)));
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
                "Coupon Details",
                style: TextStyle(color: color.white),
              ),
              leading: new IconButton(
                  icon: new Icon(
                    Icons.arrow_back_ios_rounded,
                    color: color.white,
                  ),
                  onPressed: () => Navigator.pop(context)),
            ),
            body: SingleChildScrollView(
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
                  : ack != "1" && isProgress == false && is_connected
                      ? empty(ack_msg)
                      : coupon_data == null
                          ? Visibility(
                              maintainSize: false,
                              maintainAnimation: true,
                              maintainState: true,
                              visible: isProgress,
                              child: LinearProgressIndicator())
                          : Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    color: color.light_gray,
                                    child: Container(
                                      margin: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            coupon_data[0].title,
                                            style: TextStyle(
                                                fontSize: 25,
                                                color: color.primery_color,
                                                fontFamily: 'poppins_bold'),
                                          ),
                                          Text(
                                            coupon_data[0].used_count,
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontFamily: 'poppins_bold'),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 10.0,
                                        top: 20,
                                        left: 10,
                                        right: 10),
                                    child: Container(
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Container(
                                            width: (MediaQuery.of(context)
                                                .size
                                                .width /
                                                2) -
                                                20,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 5.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    coupon_data[0]
                                                        .vendor_business_name,
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontFamily:
                                                        'poppins_bold'),
                                                  ),
                                                  Padding(
                                                    padding:
                                                    const EdgeInsets.only(
                                                        top: 5.0),
                                                    child: Text(
                                                      coupon_data[0]
                                                          .vendor_email_address,
                                                      maxLines: 2,
                                                      overflow:
                                                      TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontFamily:
                                                          'poppins_regular'),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                    const EdgeInsets.only(
                                                        top: 5.0),
                                                    child: Text(
                                                      coupon_data[0]
                                                          .vendor_mobile_no,
                                                      style: TextStyle(
                                                          fontFamily:
                                                          'poppins_regular'),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 3,
                                            height: 50,
                                            color: color.light_gray,
                                          ),
                                          Container(
                                            width: (MediaQuery.of(context)
                                                .size
                                                .width /
                                                2) -
                                                20,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 5.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                //mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    coupon_data[0]
                                                        .business_category_name,
                                                    maxLines: 2,
                                                    overflow:
                                                    TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontFamily:
                                                        'poppins_bold'),
                                                  ),
                                                  Padding(
                                                    padding:
                                                    const EdgeInsets.only(
                                                        top: 5.0),
                                                    child: Text(
                                                      "Start On : " +
                                                          coupon_data[0]
                                                              .start_date,
                                                      style: TextStyle(
                                                          fontFamily:
                                                          'poppins_regular'),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                    const EdgeInsets.only(
                                                        top: 5.0),
                                                    child: Text(
                                                      "Expire On : " +
                                                          coupon_data[0]
                                                              .expiery_date,
                                                      style: TextStyle(
                                                          fontFamily:
                                                          'poppins_regular'),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    thickness: 3,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, left: 20, right: 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Coupon Detail",
                                          style: TextStyle(
                                              color: color.black,
                                              fontFamily: 'poppins_bold'),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 0, bottom: 20),
                                          child: Text("" + coupon_data[0].description)/*Html(
                                            data:
                                                "" + coupon_data[0].description,
                                          )*/,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
            )));
  }
}
