import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dealtors_vendor/AboutUs.dart';
import 'package:dealtors_vendor/AccountVerifyFailedPage.dart';
import 'package:dealtors_vendor/AccountVerifyPage.dart';
import 'package:dealtors_vendor/AllCouponPage.dart';
import 'package:dealtors_vendor/Login.dart';
import 'package:dealtors_vendor/Profile.dart';
import 'package:dealtors_vendor/ValidateCoupon.dart';
import 'package:dealtors_vendor/WaitingForApprovel.dart';
import 'package:dealtors_vendor/WelcomePage.dart';
import 'package:dealtors_vendor/netutils/Retrofit.dart' as retrofit;
import 'package:dealtors_vendor/style/Color.dart' as color;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:package_info/package_info.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:url_launcher/url_launcher.dart';

import 'CreateCoupon.dart';
import 'CustomWidget/empty.dart';
import 'HistoryPage.dart';
import 'ReatingReviewPage.dart';
import 'netutils/preferences.dart';

void main() {
  runApp(new MaterialApp(
    home: new HomePage(),
    routes: <String, WidgetBuilder>{
      '/loginpage': (BuildContext context) => new LoginPage(),
    },
  ));
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isProgress = false;
  List<Banner> banner_data;
  String current_app_version = "", new_app_version = "";
  String ack = "", ack_msg = "";
  String first_nam = "", business_name = "", later_app_version = "";
  String total_coupon = "", total_user = "";
  String isApprove_open = "";
  String app_update_msg = "";
  String total_revenue = "0";
  String app_new_version = "";
  String footerText = "";

  Future<String> CheckVendorStatus() async {
    print("calling....");
    isProgress = true;
    var response = await retrofit.checkVendorStatus(
        await SharedPreferencesHelper.getPreference("user_id"));
    //  await SharedPreferencesHelper.setPreference("isApprove_open", "1");

    isApprove_open =
        await SharedPreferencesHelper.getPreference("isApprove_open");
    setState(() {
      var extractdata = json.decode(response.body);
      ack = extractdata["ack"].toString();
      ack_msg = extractdata["ack_msg"].toString();

      if (extractdata['ack'] == 1) {
        /*print(app_new_version);
        print(app_version);

        if (app_version < app_new_version) {
          AppUpdate(extractdata['app_version_msg']);
        } else {*/
        if (extractdata['business_complete'] != "1") {
          Route otproute = MaterialPageRoute(
              builder: (context) => WelcomePage(name: first_nam));
          Navigator.pushReplacement(context, otproute).then(onGoBack);
        } else {
          if (extractdata['status'] ==
              "2") //array("1"=>"Active","2"=>"Rejected","3"=>"Under approval","4"=>"Blocked");
          {
            Route otproute = MaterialPageRoute(
                builder: (context) => AccountVerifyFailedPage(
                    msg: extractdata['status_message'],
                    type: extractdata['status']));
            Navigator.pushReplacement(context, otproute);
          } else if (extractdata['status'] == "4") {
            Route otproute = MaterialPageRoute(
                builder: (context) => AccountVerifyFailedPage(
                    msg: extractdata['status_message'],
                    type: extractdata['status']));
            Navigator.pushReplacement(context, otproute);
          } else if (extractdata['status'] == "1") {
            if (isApprove_open == "1") {
              Route otproute =
                  MaterialPageRoute(builder: (context) => AccountVerifiy());
              Navigator.push(context, otproute).then(onGoBack);
            } else {
              this.getBanner();
            }
          } else if (extractdata['status'] ==
              "3") //array("1"=>"Active","2"=>"Rejected","3"=>"Under approval","4"=>"Blocked");
          {
            Route otproute =
                MaterialPageRoute(builder: (context) => WaitingForApprovel());
            Navigator.pushReplacement(context, otproute);
          } else {
            this.getBanner();
          }
        }
        //}
      } else if (extractdata['ack'] == 2) {
        isProgress = false;
        navigationLogout();
        // print(extractdata['ack_msg']);
      } else {
        isProgress = false;

        this.getBanner();
      }
      try {
//      /app_versionapp_version
        //app_new_version = extractdata["app_version"].toString();
        //app_update_msg = extractdata["app_version_msg"].toString();

        if (Platform.isAndroid && extractdata['app_update_android'] == "1") {
          print("First IF Condition");
          new_app_version = extractdata['app_version_android'];
          if (later_app_version !=
              extractdata['app_version_android'].toString()) {
            print("Second IF Condition:= $later_app_version");
            if (extractdata['app_version_android'].toString() !=
                current_app_version) {
              print("third IF Condition:=$current_app_version");
              AppUpdate(extractdata['app_version_android_msg'].toString(),
                  extractdata['update_android_compelsory'].toString());
            }
          }
        }
        if (Platform.isIOS && extractdata['app_update_ios'] == "1") {
          new_app_version = extractdata['app_version_ios'];
          if (later_app_version != extractdata['app_version_ios'].toString()) {
            if (extractdata['app_version_ios'].toString() !=
                current_app_version) {
              AppUpdate(extractdata['app_version_ios_msg'].toString(),
                  extractdata['update_ios_compelsory'].toString());
            }
          }
        }

        /*if(later_app_version!=extractdata['app_version'].toString()){

        if (extractdata['app_version'].toString() != current_app_version) {
          AppUpdate(extractdata['app_version_msg'].toString(),
              extractdata['update_compelsory'].toString());
        }
      }*/

      } catch (e) {
        print(e);
      }
    });
  }

  Future<String> getBanner() async {
    isProgress = true;
    var response = await retrofit
        .getbanner(await SharedPreferencesHelper.getPreference("user_id"));
    first_nam = await SharedPreferencesHelper.getPreference("name");

    setState(() {
      var extractdata = json.decode(response.body);
      ack = extractdata["ack"].toString();
      ack_msg = extractdata["ack_msg"].toString();

      if (extractdata['ack'] == 1) {
        banner_data = List<Banner>.from(
            extractdata["result"].map((x) => Banner.fromJson(x)));
        total_coupon = extractdata["totalCoupon"].toString();
        /*!= null
            ? extractdata["totalCoupon"]
            : ""*/
        total_user = extractdata["totalUser"].toString();
        total_revenue = extractdata["total_revenue"];
        footerText = extractdata["footer_text"];
        print(footerText);

        /*!= null ? extractdata["totalUser"] : "";*/
        //isProgress = false;
        // getCategoryData();
      } else if (extractdata['ack'] == 2) {
        navigationLogout();
        // print(extractdata['ack_msg']);
        isProgress = false;
      } else {
        isProgress = false;

        // print(extractdata['ack_msg']);
      }
    });
  }

  navigationLogout() async {
    isProgress = false;
    await SharedPreferencesHelper.clearAllPreference();
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/loginpage', (Route<dynamic> route) => false);
  }

  getPrafrence() async {
    first_nam = await SharedPreferencesHelper.getPreference("name");
    business_name =
        await SharedPreferencesHelper.getPreference("business_name");
    later_app_version =
        await SharedPreferencesHelper.getPreference("later_app_version");
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
    _initPackageInfo();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    setState(() {
      if (is_connected) {
        // TODO: implement initState
        getPrafrence();
        this.CheckVendorStatus();
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
          if (is_connected == false) {
            getPrafrence();
            this.CheckVendorStatus();
          }
          is_connected = true;
        });
        break;
      case ConnectivityResult.mobile:
        setState(() {
          if (is_connected == false) {
            getPrafrence();
            this.CheckVendorStatus();
          }
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

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    //setState(() {
    current_app_version = info.version;

    print("BUild:-${info.buildNumber}");

    //});
  }

  FutureOr onGoBack(dynamic value) {
    getPrafrence();
    CheckVendorStatus();
    setState(() {});
  }

  void navigateSecondPage() {
    Route route = MaterialPageRoute(builder: (context) => AllCouponPage());
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
        primaryColor: color.primery_color,
        //   accentColor: Theme.colors.button,
      ),
      home: Scaffold(
        backgroundColor: color.white,
        key: _scaffoldKey,
        /*appBar: new AppBar(
          shadowColor: null,
          elevation: 0.0,
          backgroundColor: color.black,
          title: Text("John Doe!!"),
          leading: new IconButton(
              icon: new Icon(Icons.dehaze),
              onPressed: () => _scaffoldKey.currentState.openDrawer()),
        ),*/
        drawer: Drawer(
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the drawer if there isn't enough vertical
          // space to fit everything.
          child: Container(
            color: color.primery_color_dark,
            child: Column(
              children: [
                SizedBox(
                  height: 150,
                  child: DrawerHeader(
                    child: Center(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 100.0,
                          width: 200.0,
                          child: new Image.asset("assets/logo.png",
                              fit: BoxFit.cover),
                        ),
                      ],
                    )),
                  ),
                ),
                Expanded(
                  child: ListView(
                    // Important: Remove any padding from the ListView.
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      ListTile(
                        title: Text('My Coupons',
                            style: TextStyle(
                                color: color.white,
                                fontFamily: 'poppins_medium',
                                fontSize: 18)),
                        onTap: () {
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AllCouponPage()))
                              .then(onGoBack);
                          _scaffoldKey.currentState.openEndDrawer();
                        },
                      ),
                      ListTile(
                        title: Text('Create Coupon',
                            style: TextStyle(
                                color: color.white,
                                fontFamily: 'poppins_medium',
                                fontSize: 18)),
                        onTap: () {
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CreateCoupon()))
                              .then(onGoBack);
                          _scaffoldKey.currentState.openEndDrawer();
                        },
                      ),
                      ListTile(
                        title: Text('Profile',
                            style: TextStyle(
                                color: color.white,
                                fontFamily: 'poppins_medium',
                                fontSize: 18)),
                        onTap: () {
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Profile()))
                              .then(onGoBack);
                          _scaffoldKey.currentState.openEndDrawer();
                        },
                      ),
                      ListTile(
                        title: Text('About Us',
                            style: TextStyle(
                                color: color.white,
                                fontFamily: 'poppins_medium',
                                fontSize: 18)),
                        onTap: () {
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AboutUs()))
                              .then(onGoBack);
                          _scaffoldKey.currentState.openEndDrawer();
                        },
                      ),
                      ListTile(
                        title: Text('History',
                            style: TextStyle(
                                color: color.white,
                                fontFamily: 'poppins_medium',
                                fontSize: 18)),
                        onTap: () {
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HistoryPage()))
                              .then(onGoBack);
                          _scaffoldKey.currentState.openEndDrawer();
                        },
                      ),
                      ListTile(
                        title: Text('Ratings & Reviews',
                            style: TextStyle(
                                color: color.white,
                                fontFamily: 'poppins_medium',
                                fontSize: 18)),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ReatingReviewPage())).then(onGoBack);
                          _scaffoldKey.currentState.openEndDrawer();
                        },
                      ),
                      ListTile(
                        title: Text('Logout',
                            style: TextStyle(
                                color: color.red,
                                fontFamily: 'poppins_medium',
                                fontSize: 18)),
                        onTap: () {
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title:
                                      Text("Are you sure you want to logout?"),
                                  actions: <Widget>[
                                    FlatButton(
                                        onPressed: () async {
                                          await SharedPreferencesHelper
                                              .clearAllPreference();
                                          Navigator.of(context)
                                              .pushNamedAndRemoveUntil(
                                                  '/loginpage',
                                                  (Route<dynamic> route) =>
                                                      false);
                                        },
                                        child: Text("Yes")),
                                    FlatButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                        child: Text("No"))
                                  ],
                                );
                              });
                          _scaffoldKey.currentState.openEndDrawer();
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: new EdgeInsets.only(bottom: 20.0, top: 10.0),
                  child: Column(
                    children: [
                      Text("V " + current_app_version,
                          style: TextStyle(
                              color: color.primery_color,
                              fontFamily: 'poppins_medium',
                              fontSize: 14)),
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Text("Copyright By Dealtors Pvt. Ltd.",
                            style: TextStyle(
                                color: color.primery_color,
                                fontFamily: 'poppins_medium',
                                fontSize: 12)),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        //drawer(context, _scaffoldKey, "home", app_version),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(top: statusBarHeight),
            child: Container(
              //height: MediaQuery.of(context).size.height,
              color: color.white,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ack == "3"
                        ? Container(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                                child: Text(
                              ack_msg,
                              style: TextStyle(
                                  fontSize: 14, fontFamily: 'poppins_bold'),
                            )),
                          )
                        : Container(
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    InkWell(
                                      child: new Icon(Icons.dehaze),
                                      onTap: () {
                                        _scaffoldKey.currentState.openDrawer();
                                      },
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: SizedBox(
                                        height: 40.0,
                                        width: 150.0,
                                        child: new Image.asset(
                                            "assets/home_logo.jpg",
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                  ),
                  !is_connected
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
                          ? Container(child: empty(ack_msg))
                          : banner_data == null
                              ? Visibility(
                                  maintainSize: false,
                                  maintainAnimation: true,
                                  maintainState: true,
                                  visible: isProgress,
                                  child: Center(
                                    child: Container(
                                        margin: EdgeInsets.only(
                                            top: statusBarHeight),
                                        child: LinearProgressIndicator()),
                                  ))
                              : Container(
                                  height:
                                      MediaQuery.of(context).size.height / 3.5,
                                  color: color.light_gray,
                                  child: CarouselSlider(
                                    options: CarouselOptions(
                                        height: (MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                3.5) -
                                            20,
                                        autoPlay: true),
                                    items: banner_data.map((i) {
                                      return Builder(
                                        builder: (BuildContext context) {
                                          return InkWell(
                                            onTap: () async {
                                              if (i.link_type == "1") {
                                                if (await canLaunch(i.link)) {
                                                  await launch(i.link);
                                                } else {
                                                  throw 'Could not launch';
                                                }
                                              }
                                            },
                                            child: Card(
                                              clipBehavior: Clip.antiAlias,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0)), //this right here) ,
                                              child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                  child:
                                                      FadeInImage.assetNetwork(
                                                    placeholder:
                                                        'assets/loader.gif',
                                                    image: i.image_path,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width -
                                                            70,
                                                    fit: BoxFit.fill,
                                                  )),
                                            ),
                                          );
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 10.0, left: 40.0, right: 40.0),
                    child: Container(
                      child: Column(
                        children: [
                          Text(
                            "Welcome " + first_nam,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 25, fontFamily: 'poppins_bold'),
                          ),
                          Text(
                            business_name != null ? "" + business_name : "",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 25, fontFamily: 'poppins_bold'),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 40.0, right: 40),
                            child: Text(
                              "Create coupon for your guest & customer",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18, fontFamily: 'poppins_medium'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0, bottom: 20),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  Route route = MaterialPageRoute(
                                      builder: (context) => AllCouponPage());
                                  //Route route = MaterialPageRoute(builder: (context) => UploadImageDemo1());
                                  Navigator.push(context, route).then(onGoBack);
                                  // Navigator.push( context, MaterialPageRoute( builder: (context) => AllCouponPage()), ).then((value) => setState(() {}));
/*

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              AllCouponPage()));
*/
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: color.light_gray,
                                      borderRadius: BorderRadius.circular(30)),
                                  height: 150.0,
                                  width: 150,
                                  child: Center(
                                    child: SizedBox(
                                      height: 100.0,
                                      child: new Image.asset(
                                        "assets/my_coupon.png",
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: Text(
                                  "My Coupon",
                                  style: TextStyle(
                                      color: color.black,
                                      fontSize: 16,
                                      fontFamily: 'poppins_medium'),
                                ),
                              )
                            ],
                          ),
                          Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ValidateCoupon())).then(onGoBack);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: color.light_gray,
                                      borderRadius: BorderRadius.circular(30)),
                                  height: 150.0,
                                  width: 150,
                                  child: Center(
                                    child: SizedBox(
                                      height: 100.0,
                                      child: new Image.asset(
                                        "assets/verify_coupon.png",
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: Text(
                                  "Verify Coupon",
                                  style: TextStyle(
                                      color: color.black,
                                      fontSize: 16,
                                      fontFamily: 'poppins_medium'),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Container(
                            decoration: BoxDecoration(
                                color: color.light_gray,
                                borderRadius: BorderRadius.circular(10)),
                            height: 90.0,
                            width: 250,
                            child: Center(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Monthly Revenue",
                                  style: TextStyle(
                                      fontFamily: 'poppins_regular',
                                      fontSize: 20),
                                ),
                                Text(total_revenue + "HKD",
                                    style: TextStyle(
                                        fontFamily: 'poppins_bold',
                                        fontSize: 25)),
                              ],
                            )),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  total_user +
                                      " live user | " +
                                      total_coupon +
                                      " coupons",
                                  style: TextStyle(
                                      color: color.black,
                                      fontSize: 12,
                                      fontFamily: 'poppins_medium'),
                                ),
                                Text(
                                  footerText,
                                  style: TextStyle(
                                      color: color.black,
                                      fontSize: 14,
                                      fontFamily: 'poppins_medium'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ) /*Container(
                    child: ListView(
                      primary: false,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      children: <Widget>[
                        _buildStoryListView(),
                      ],
                    ),
                  ),*/
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> AppUpdate(String msg, String iscompelsory) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return WillPopScope(
            onWillPop: () async => false,
            child: Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0)), //this right here
              child: SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          //mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 0, top: 10.0, right: 0, bottom: 10),
                              child: Center(
                                child: Html(
                                  data: msg,
                                  defaultTextStyle: TextStyle(
                                      color: color.black,
                                      fontSize: 15,
                                      fontFamily: 'poppins_regular'),
                                ),
                              ),
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  iscompelsory != "1"
                                      ? Expanded(
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () async {
                                                    await SharedPreferencesHelper
                                                        .setPreference(
                                                            "later_app_version",
                                                            new_app_version);
                                                    Navigator.pop(context);
                                                  },
                                                  child: Center(
                                                    child: Text(
                                                      "Later",
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontFamily:
                                                              'poppins_bold'),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 20.0, left: 5),
                                                child: Container(
                                                  width: 1,
                                                  height: 50,
                                                  color: color.light_gray,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container(),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        StoreRedirect.redirect(
                                            androidAppId: "com.dealtors_vendor",
                                            iOSAppId: "1560983107");
                                        /*StoreRedirect.redirect(androidAppId: "com.karaoke_pitch_and_speed_changer",
                                            iOSAppId: "585027354");*/
                                      },
                                      child: Center(
                                        child: Text(
                                          "Update Now",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontFamily: 'poppins_bold'),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            /*Padding(
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
                            ),*/
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }
}

class Banner {
  final String image_path;
  final String id;
  final String link_type;
  final String link;
  final String redirect_id;

  Banner(
      {this.id, this.image_path, this.link_type, this.redirect_id, this.link});

  factory Banner.fromJson(Map<String, dynamic> json) => Banner(
        id: json["id"],
        image_path: json["image_path"],
        link_type: json["link_type"],
        redirect_id: json["redirect_id"],
        link: json["link"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "image_path": image_path,
        "link_type": link_type,
        "redirect_id": redirect_id,
        "link": link,
      };
}
