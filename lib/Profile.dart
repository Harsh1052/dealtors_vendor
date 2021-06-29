import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:dealtors_vendor/AddRestaurantPage.dart';
import 'package:dealtors_vendor/EditProfile.dart';
import 'package:dealtors_vendor/HomePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dealtors_vendor/style/Color.dart' as color;
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';

import 'ChnagePhoneNumber.dart';
import 'CustomWidget/AlertForCoupon.dart';
import 'CustomWidget/empty.dart';
import 'Model/Coupon.dart';
import 'package:dealtors_vendor/netutils/Retrofit.dart' as retrofit;
import 'dart:convert';

import 'Model/Vendor.dart';
import 'netutils/preferences.dart';

void main() {
  runApp(Profile());
}

class Profile extends StatefulWidget {
  /*String item_id, cat_name;
  Profile({Key key, this.item_id, this.cat_name}) : super(key: key);
*/
  @override
  _DetailPageState createState() => _DetailPageState();
}

var extractdata;

class _DetailPageState extends State<Profile> {
  List<Coupon> coupon_data;
  List<VendorDetail> vendor_detail;
  bool isProgress = false;
  String ack = "", ack_msg = "";
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Future<String> getVendorDetail() async {
    isProgress = true;
    var response = await retrofit
        .getVendor(await SharedPreferencesHelper.getPreference("user_id"));
    setState(() {
      var extractdata = json.decode(response.body);
      ack = extractdata['ack'].toString();
      ack_msg = extractdata['ack_msg'].toString();
      if (extractdata['ack'] == 1) {
        try {
          vendor_detail = List<VendorDetail>.from(
              extractdata["result"].map((x) => VendorDetail.fromJson(x)));
          // coupon_data = vendor_detail[0].coupons;
          isProgress = false;
        } catch (e) {
          print(e);
        }
      } else {
        isProgress = false;
        // print(extractdata['ack_msg']);
      }
    });
  }

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
        this.getVendorDetail();
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
          this.getVendorDetail();
        });
        break;
      case ConnectivityResult.mobile:
        setState(() {
          is_connected = true;
          this.getVendorDetail();
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

  FutureOr onGoBack(dynamic value) {
    this.getVendorDetail();
    setState(() {});
  }

  void navigateSecondPage() {
    Route route = MaterialPageRoute(
        builder: (context) => AddRestaurantPage(
              mode: 'edit',
              category_id: "",
              category_name: "",
            ));
    //Route route = MaterialPageRoute(builder: (context) => UploadImageDemo1());
    Navigator.push(context, route).then(onGoBack);
  }

  void navigateEditProfile() {
    Route route = MaterialPageRoute(builder: (context) => EditProfile());
    //Route route = MaterialPageRoute(builder: (context) => UploadImageDemo1());
    Navigator.push(context, route).then(onGoBack);
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
        key: _scaffoldKey,
        appBar: new AppBar(
          shadowColor: null,
          elevation: 0.0,
          // backgroundColor: color.white,
          title: Text(
            "Profile",
            style: TextStyle(color: color.white),
          ),
          leading: new IconButton(
              icon: new Icon(
                Icons.arrow_back_ios_rounded,
                color: color.white,
              ),
              onPressed: () => Navigator.pop(context)),
          actions: [
            new IconButton(
                icon: new Icon(
                  Icons.edit,
                  color: color.white,
                ),
                onPressed: () {
                  navigateEditProfile();
                })
          ],
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
                  : vendor_detail == null
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
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 20.0, bottom: 10.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          new Container(
                                              margin: const EdgeInsets.only(
                                                  left: 10.0),
                                              width: 120.0,
                                              height: 120.0,
                                              decoration: new BoxDecoration(
                                                  image: new DecorationImage(
                                                      image: new NetworkImage(
                                                          vendor_detail[0]
                                                              .image_path),
                                                      fit: BoxFit.cover))),
                                          Expanded(
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                  left: 10.0, right: 10.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    vendor_detail[0]
                                                        .business_name,
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontFamily:
                                                            'poppins_bold'),
                                                  ),
                                                  Text(
                                                    vendor_detail[0].address,
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontFamily:
                                                            'poppins_medium'),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 5.0),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          "Business No. : ",
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              color: color.gray,
                                                              fontFamily:
                                                                  'poppins_medium'),
                                                        ),
                                                        Text(
                                                          vendor_detail[0]
                                                              .business_contact_no,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'poppins_medium'),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              vendor_detail[0].rate,
                                              style: TextStyle(
                                                  fontFamily: 'poppins_bold'),
                                            ),
                                            Icon(
                                              Icons.star,
                                              color: Colors.deepOrange,
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 20.0,
                                    left: 20.0,
                                    right: 20.0,
                                    bottom: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10.0),
                                      child: Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    vendor_detail[0].first_name,
                                                    overflow: TextOverflow.fade,
                                                    softWrap: false,
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontFamily:
                                                            'poppins_bold'),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 5.0),
                                                    child: Text(
                                                      vendor_detail[0]
                                                          .email_address,
                                                      maxLines: 2,
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontFamily:
                                                              'poppins_regular'),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 5.0),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          "Mo. No.",
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color: color.gray,
                                                              fontFamily:
                                                                  'poppins_regular'),
                                                        ),
                                                        Text(
                                                          vendor_detail[0]
                                                              .mobile_no,
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'poppins_medium'),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 20.0, left: 5),
                                              child: Container(
                                                width: 3,
                                                height: 50,
                                                color: color.light_gray,
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                //mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    vendor_detail[0]
                                                        .business_category_name,
                                                    overflow: TextOverflow.fade,
                                                    softWrap: false,
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontFamily:
                                                            'poppins_bold'),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 5.0),
                                                    child: Text(
                                                      "Open Time : " +
                                                          vendor_detail[0]
                                                              .open_time,
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
                                                      "Close Time : " +
                                                          vendor_detail[0]
                                                              .close_time,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'poppins_regular'),
                                                    ),
                                                  ),
                                                ],
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
                                          top: 10.0, bottom: 10.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Bussiness Details",
                                            style: TextStyle(
                                                color: color.black,
                                                fontFamily: 'poppins_bold'),
                                          ),
                                          new IconButton(
                                              icon: new Icon(
                                                Icons.edit,
                                                color: color.black,
                                              ),
                                              onPressed: () {
                                                navigateSecondPage();
                                              })
                                        ],
                                      ),
                                    ),
                                    Text(
                                      "" + vendor_detail[0].about_business,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: color.black,
                                          fontFamily: 'poppins_reguler'),
                                    )
/*
                                    Text("" + vendor_detail[0].about_business),
*/
/*                      Html(
                        data: vendor_detail[0].about_business,
                        defaultTextStyle: TextStyle(color: color.gray),
                      ),*/
                                    /*coupon_data == null
                          ? Container()
                          : Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 15.0),
                            child: Text(
                              "Available Coupon",
                              style: TextStyle(
                                  color: color.black,
                                  fontFamily: 'poppins_bold'),
                            ),
                          ),
                          ListView(
                            primary: false,
                            shrinkWrap: true,
                            physics:
                            NeverScrollableScrollPhysics(),
                            children: [_buildCardListView()],
                          )
                        ],
                      )*/
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
        ),
      ),
    );
  }
}
