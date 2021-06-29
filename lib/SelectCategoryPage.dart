import 'dart:async';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:dealtors_vendor/netutils/Retrofit.dart' as retrofit;
import 'package:dealtors_vendor/AccountVerifyPage.dart';
import 'package:dealtors_vendor/AddRestaurantPage.dart';
import 'package:dealtors_vendor/HomePage.dart';
import 'package:dealtors_vendor/Model/Category.dart';
import 'package:dealtors_vendor/style/Color.dart' as color;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'CustomWidget/ToastFile.dart';

import 'CustomWidget/empty.dart';
import 'netutils/preferences.dart';

class SelectCategoryPage extends StatefulWidget {
  @override
  _SelectCategoryPageState createState() => _SelectCategoryPageState();
}

class _SelectCategoryPageState extends State<SelectCategoryPage> {
  List<Category> _category = new List();
  int category_id = null;
  String category_name = "";
  String ack = "", ack_msg = "";
  bool isProgress = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool is_connected = false;

  final Connectivity _connectivity = Connectivity();
  /*int ul = 50, ll = 0;
  ScrollController category_scrollController = ScrollController();
*/
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    // TODO: implement initState
    // _populateData();
    super.initState();

    initConnectivity();
   /* category_scrollController.addListener(() {
      if (category_scrollController.position.pixels ==
          category_scrollController.position.maxScrollExtent) {
        getCategoryData();
        setState(() {});
      }
    });
   */ _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    setState(() {
      if (is_connected) {
        // TODO: implement initState
        getCategoryData();
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
       //   ll = 0;
          _category.clear();
          getCategoryData();
        });
        break;
      case ConnectivityResult.mobile:
        setState(() {
          is_connected = true;
         // ll = 0;
          _category.clear();
          getCategoryData();
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

  Future<String> getCategoryData() async {
    var response = await retrofit.getCategory(
        await SharedPreferencesHelper.getPreference("user_id"),
       /* ll.toString(),
        ul.toString()*/);
    isProgress = true;
    setState(() {
      var extractdata = json.decode(response.body);
      print(extractdata);
      ack = extractdata["ack"].toString();
      ack_msg = extractdata["ack_msg"].toString();
      if (extractdata['ack'] == 1) {
        _category.clear();
        /*if (ll == 0) {
          _category.clear();
        }*/
        /*_category = List<Category>.from(
            extractdata["result"].map((x) => Category.fromJson(x)));*/
        try {
          for (int i = 0; i <= extractdata['result'].length; i++) {
            Category c = new Category();
            c.id = extractdata['result'][i]['id'];
            c.name = extractdata['result'][i]['name'];
            _category.add(c);
          }
        } catch (e) {
          print(e);
        }
     //   ll = ll + _category.length;
        isProgress = false;
        print(extractdata['ack_msg']);
      } else {
        isProgress = false;
        print(extractdata['ack_msg']);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        backgroundColor: color.white,
        body: SingleChildScrollView(
          child: Container(
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
                    ? Container(
                        height: MediaQuery.of(context).size.height,
                        child: empty(ack_msg))
                    : _category == null
                        ? Visibility(
                            maintainSize: false,
                            maintainAnimation: true,
                            maintainState: true,
                            visible: isProgress,
                            child: Center(
                              child: Container(
                                  margin: EdgeInsets.only(top: statusBarHeight),
                                  child: LinearProgressIndicator()),
                            ))
                        : Stack(
                            children: [
                              Container(
                                color: color.primery_color_dark,
                                height: MediaQuery.of(context).size.height / 3,
                                width: MediaQuery.of(context).size.width,
                                child: Center(
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 2,
                                    child: new Image.asset(
                                      "assets/logo.png",
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 0.0,
                                    top:
                                        MediaQuery.of(context).size.height / 3 -
                                            40,
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
                                    padding: const EdgeInsets.only(
                                        left: 30.0, right: 30.0),
                                    child: Container(
                                      color: Colors.transparent,
                                      child: Column(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 20.0, bottom: 10.0),
                                            child: Text(
                                              "Select Category",
                                              style: new TextStyle(
                                                  fontSize: 25.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 10.0),
                                            child: Text(
                                              "Choose your Business Category from list",
                                              style:
                                                  new TextStyle(fontSize: 15.0),
                                            ),
                                          ),
                                          Divider(
                                            indent: 100,
                                            endIndent: 100,
                                            thickness: 2,
                                            color: color.primery_color,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 0.0),
                                            child: Container(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: _category
                                                    .map((t) => RadioListTile(
                                                          title: Text(
                                                            "${t.name}",
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'poppins_medium',
                                                                fontSize: 18),
                                                          ),
                                                          groupValue:
                                                              category_id,
                                                          value:
                                                              int.parse(t.id),
                                                          onChanged: (val) {
                                                            setState(() {
                                                              category_id = val;
                                                              category_name =
                                                                  t.name;
                                                            });
                                                          },
                                                        ))
                                                    .toList(),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 20.0,
                                                bottom: 10.0,
                                                left: 0.0,
                                                right: 0.0),
                                            child: MaterialButton(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25)),
                                                color: color.primery_color,
                                                height: 50,
                                                minWidth: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 5.0,
                                                      horizontal: 18.0),
                                                  child: Text(
                                                    "  Next  ",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15.0,
                                                    ),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  print(category_id);
                                                  if (category_id == "" ||
                                                      category_id == null) {
                                                    SnackBarFail(
                                                        "Please Select Business Category",
                                                        context,
                                                        _scaffoldKey);
                                                  } else {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                AddRestaurantPage(
                                                                  mode: 'add',
                                                                  category_id:
                                                                      category_id
                                                                          .toString(),
                                                                  category_name:
                                                                      category_name
                                                                          .toString(),
                                                                )));
                                                  }

                                                  //userBlockDialog();
                                                  //showInSnackBarFail("testtt");
                                                }),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
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
