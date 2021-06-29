import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:dealtors_vendor/CoupenDetail.dart';
import 'package:dealtors_vendor/CreateCoupon.dart';
import 'package:dealtors_vendor/Model/Coupon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dealtors_vendor/style/Color.dart' as color;
import 'package:flutter/services.dart';
import 'package:dealtors_vendor/netutils/Retrofit.dart' as retrofit;
import 'dart:convert';
import 'CustomWidget/DrawerWidget.dart';
import 'CustomWidget/ToastFile.dart';
import 'CustomWidget/empty.dart';
import 'Model/GenrelModel.dart';
import 'netutils/preferences.dart';

class AllCouponPage extends StatefulWidget {
  @override
  _AllCouponPageState createState() => _AllCouponPageState();
}

class _AllCouponPageState extends State<AllCouponPage> {
  List<Coupon> expier_data = new List();
  List<Coupon> disable_data = new List();
  List<Coupon> live_data = new List();
  bool isProgress = false;
  bool isProgressL = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String live_ack = "",
      live_ack_msg = "",
      exp_ack = "",
      exp_ack_msg = "",
      disable_ack = "",
      disable_ack_msg = "";
  bool is_connected = false;
  int live_ul = 50,
      live_ll = 0,
      disable_ul = 50,
      disable_ll = 0,
      expier_ul = 50,
      expier_ll = 0;

  final Connectivity _connectivity = Connectivity();
  ScrollController live_scrollController = ScrollController();
  ScrollController disable_scrollController = ScrollController();
  ScrollController expier_scrollController = ScrollController();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  String _selected_contury_code = "+852";
  List<GenrelModel> contry_data = new List();

  @override
  void initState() {
    // TODO: implement initState
    // _populateData();
    super.initState();
    initConnectivity();
    //myList = List.generate(10, (i) => "Item : ${i + 1}");
    live_scrollController.addListener(() {
      if (live_scrollController.position.pixels ==
          live_scrollController.position.maxScrollExtent) {
        getLiveCoupon();
        setState(() {});
      }
    });
    disable_scrollController.addListener(() {
      if (disable_scrollController.position.pixels ==
          disable_scrollController.position.maxScrollExtent) {
        getDisableCoupon();
        setState(() {});
      }
    });
    expier_scrollController.addListener(() {
      if (expier_scrollController.position.pixels ==
          expier_scrollController.position.maxScrollExtent) {
        getExpireCoupon();
        setState(() {});
      }
    });
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    setState(() {
      if (is_connected) {
        // TODO: implement initState
        getLiveCoupon();
        getDisableCoupon();
        getExpireCoupon();
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
          live_ll = 0;
          disable_ll = 0;
          expier_ll = 0;
          is_connected = true;
          getLiveCoupon();
          getDisableCoupon();
          getExpireCoupon();
        });
        break;
      case ConnectivityResult.mobile:
        setState(() {
          live_ll = 0;
          disable_ll = 0;
          expier_ll = 0;
          is_connected = true;
          getLiveCoupon();
          getDisableCoupon();
          getExpireCoupon();
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

  Future<String> couponStatus(
      String status, String coupon_id, String type) async {
    isProgressL = true;
    var response = await retrofit.couponStatus(
        await SharedPreferencesHelper.getPreference("user_id"),
        coupon_id,
        status);
    setState(() {
      try {
        var extractdata = json.decode(response.body);
        print(extractdata);
        if (extractdata['ack'] == 1) {
          print(extractdata['ack_msg']);
          live_ll = 0;
          disable_ll = 0;
          getLiveCoupon();
          getDisableCoupon();
          isProgressL = false;
        } else {
          isProgressL = false;
          print(extractdata['ack_msg']);
        }
      } catch (e) {
        print(e);
      }
    });
  }

  Future<String> getLiveCoupon() async {
    isProgressL = true;
    var response = await retrofit.getLiveCoupon(
        await SharedPreferencesHelper.getPreference("user_id"),
        live_ll.toString(),
        live_ul.toString());
    setState(() {
      try {
        var extractdata = json.decode(response.body);
        print(extractdata);
        live_ack = extractdata['ack'].toString();
        live_ack_msg = extractdata['ack_msg'].toString();
        if (extractdata['ack'] == 1) {
          /*   live_data=List<Coupon>.from(
              extractdata["result"].map((x) => Coupon.fromJson(x)));
*/
          if (live_ll == 0) {
            live_data.clear();
          }
          try {
            for (int i = 0; i <= extractdata['result'].length; i++) {
              Coupon c = new Coupon();
              c.title = extractdata["result"][i]['title'].toString();
              c.id = extractdata["result"][i]['id'].toString();
              c.description =
                  extractdata["result"][i]['description'].toString();
              c.start_date =
                  extractdata["result"][i]['start_date_format'].toString();
              c.expiery_date =
                  extractdata["result"][i]['expiry_date_format'].toString();
              c.used_count =
                  extractdata["result"][i]['total_used_count'].toString();
              c.business_category_name =
                  extractdata["result"][i]['business_category_name'].toString();
              c.isActive = extractdata["result"][i]['isActive'].toString();
              live_data.add(c);
            }
          } catch (e) {
            print(e);
          }
          live_ll = live_ll + live_data.length;

          print(extractdata['ack_msg']);
          // print(ll.toString());
          isProgressL = false;
        } else {
          isProgressL = false;

          print(extractdata['ack_msg']);
        }
      } catch (e) {
        print(e);
      }
    });
  }

  Future<String> getDisableCoupon() async {
    isProgress = true;
    var response = await retrofit.getDisableCoupon(
        await SharedPreferencesHelper.getPreference("user_id"),
        disable_ll.toString(),
        disable_ul.toString());
    setState(() {
      try {
        var extractdata = json.decode(response.body);
        print(extractdata);
        disable_ack = extractdata['ack'].toString();
        disable_ack_msg = extractdata['ack_msg'].toString();
        if (extractdata['ack'] == 1) {
          /*     disable_data = List<Coupon>.from(
              extractdata["result"].map((x) => Coupon.fromJson(x)));
     */
          if (disable_ll == 0) {
            disable_data.clear();
          }
          try {
            for (int i = 0; i <= extractdata['result'].length; i++) {
              Coupon c = new Coupon();
              c.title = extractdata["result"][i]['title'].toString();
              c.id = extractdata["result"][i]['id'].toString();
              c.description =
                  extractdata["result"][i]['description'].toString();
              c.start_date =
                  extractdata["result"][i]['start_date_format'].toString();
              c.expiery_date =
                  extractdata["result"][i]['expiry_date_format'].toString();
              c.used_count =
                  extractdata["result"][i]['total_used_count'].toString();
              c.business_category_name =
                  extractdata["result"][i]['business_category_name'].toString();
              c.isActive = extractdata["result"][i]['isActive'].toString();
              disable_data.add(c);
            }
          } catch (e) {
            print(e);
          }
          disable_ll = disable_ll + disable_data.length;
          //isProgress = false;
          print(extractdata['ack_msg']);
          isProgress = false;
        } else {
          isProgress = false;
          print(extractdata['ack_msg']);
        }
      } catch (e) {
        print(e);
      }
    });
  }

  Future<String> getExpireCoupon() async {
    isProgress = true;
    var response = await retrofit.getExpireCoupon(
        await SharedPreferencesHelper.getPreference("user_id"),
        expier_ll.toString(),
        expier_ul.toString());
    setState(() {
      try {
        var extractdata = json.decode(response.body);
        print(extractdata);
        exp_ack = extractdata['ack'].toString();
        exp_ack_msg = extractdata['ack_msg'].toString();
        if (extractdata['ack'] == 1) {
          /*  expier_data = List<Coupon>.from(
              extractdata["result"].map((x) => Coupon.fromJson(x)));*/

          try {
            for (int i = 0; i <= extractdata['result'].length; i++) {
              Coupon c = new Coupon();
              c.title = extractdata["result"][i]['title'].toString();
              c.id = extractdata["result"][i]['id'].toString();
              c.description =
                  extractdata["result"][i]['description'].toString();
              c.start_date =
                  extractdata["result"][i]['start_date_format'].toString();
              c.expiery_date =
                  extractdata["result"][i]['expiry_date_format'].toString();
              c.used_count =
                  extractdata["result"][i]['total_used_count'].toString();
              c.business_category_name =
                  extractdata["result"][i]['business_category_name'].toString();
              c.isActive = extractdata["result"][i]['isActive'].toString();
              expier_data.add(c);
            }
          } catch (e) {
            print(e);
          }
          expier_ll = expier_ll + expier_data.length;

          //isProgress = false;
          print(extractdata['ack_msg']);
          isProgress = false;
        } else {
          isProgress = false;
          print(extractdata['ack_msg']);
        }
      } catch (e) {
        print(e);
      }
    });
  }

  Future<String> deleteCoupon(
      String id, String type, BuildContext context1) async {
    isProgress = true;
    var response = await retrofit.deleteCoupon(id);

    setState(() {
      try {
        var extractdata = json.decode(response.body);
        print(extractdata);
        if (extractdata['ack'] == 1) {
          print(extractdata['ack_msg']);
          SnackBarSuccess(extractdata['ack_msg'], context1, _scaffoldKey);
          isProgress = false;
          if (type == "1") {
            live_ll = 0;

            getLiveCoupon();
          } else if (type == "2") {
            disable_ll = 0;

            getDisableCoupon();
          } else if (type == "3") {
            expier_ll = 0;
            getExpireCoupon();
          }
        } else {
          isProgress = false;
          print(extractdata['ack_msg']);
          SnackBarFail(extractdata['ack_msg'], context1, _scaffoldKey);
        }
        Navigator.pop(context, true);
      } catch (e) {
        print(e);
      }
    });
  }
  BuildContext maincontext;

  @override
  Widget build(BuildContext context) {
    maincontext = context;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return MaterialApp(
      theme: ThemeData(
        // Define the default brightness and colors.
        // brightness: Brightness.dark,
        primaryColor: color.white,
        //   accentColor: Theme.colors.button,
      ),
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: color.light_gray,
          appBar: new AppBar(
            brightness: Brightness.dark,
            shadowColor: null,
            elevation: 0.0,
            titleSpacing: 0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: new Icon(Icons.arrow_back_ios_outlined),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Text(
                  "All Coupon",
                  style: TextStyle(fontSize: 18, fontFamily: 'poppins_bold'),
                )
                /*  SizedBox(
                  height: 40.0,
                  width: 150.0,
                  child: new Image.asset("assets/home_logo.jpg",
                      fit: BoxFit.cover),
                ),
              */ // Your widgets here
              ],
            ),
            // backgroundColor: color.white,
            /*title: Text(
              "My Subscription",
              style: TextStyle(color: color.white),
            ),*/
            automaticallyImplyLeading: false,

            bottom: TabBar(
              tabs: [
                Tab(
                  child: Text(
                    'Live Coupon',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'poppins_bold',
                        color: color.black),
                  ),
                ),
                Tab(
                  child: Text(
                    'Disable Coupon',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'poppins_bold',
                        color: color.black),
                  ),
                ),
                Tab(
                  child: Text(
                    'Expired Coupon',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'poppins_bold',
                        color: color.black),
                  ),
                ),
              ],
            ),
          ),
          // drawer: drawer(context, _scaffoldKey, "main"),
          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: TabBarView(
              children: [
                !is_connected
                    ? Container(
                        height: 5,
                        width: MediaQuery.of(context).size.width,
                        color: color.white,
                        child: Center(
                            child: Text(
                          "No Internet",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: color.black),
                        )),
                      )
                    : live_ack != "1" &&
                            isProgressL == false &&
                            is_connected &&
                            live_ll == 0
                        ? empty(live_ack_msg)
                        : live_data == null
                            ? Container(
                                child: Center(child: Text("Loading...")),
                              )
                            : ListView(
                                padding: const EdgeInsets.only(
                                    bottom: kFloatingActionButtonMargin + 48),

                                controller: live_scrollController,
                                primary: false,
                                shrinkWrap: true,
                                //physics: NeverScrollableScrollPhysics(),
                                children: [getLiveCards()],
                              ),
                disable_ack != "1" &&
                        isProgress == false &&
                        is_connected &&
                        disable_ll == 0
                    ? empty(disable_ack_msg)
                    : disable_data == null
                        ? Container(
                            child: Center(child: Text("Loading...")),
                          )
                        : ListView(
                            padding: const EdgeInsets.only(
                                bottom: kFloatingActionButtonMargin + 48),

                            controller: disable_scrollController,
                            primary: false,
                            shrinkWrap: true,
                            //physics: NeverScrollableScrollPhysics(),
                            children: [getDisableCards()],
                          ),
                exp_ack != "1" &&
                        isProgress == false &&
                        is_connected &&
                        expier_ll == 0
                    ? empty(exp_ack_msg)
                    : expier_data == null
                        ? Container(
                            child: Center(child: Text("Loading...")),
                          )
                        : ListView(
                            padding: const EdgeInsets.only(
                                bottom: kFloatingActionButtonMargin + 48),
                            controller: expier_scrollController,
                            primary: false,
                            shrinkWrap: true,
                            //  physics: NeverScrollableScrollPhysics(),
                            children: [getExpierCards()],
                          ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              navigateSecondPage("");
              /*   Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CreateCoupon()));
           */ // Add your onPressed code here!
            },
            child: Icon(Icons.add),
            backgroundColor: color.primery_color,
          ),
        ),
      ),
    );
  }

  FutureOr onGoBack(dynamic value) {
    live_ll = 0;
    expier_ll = 0;
    disable_ll = 0;
    getLiveCoupon();
    getDisableCoupon();
    getExpireCoupon();
    setState(() {});
  }

  void navigateSecondPage(String id) {
    //  Route route;
    //if (id == "") {
    Route route = MaterialPageRoute(builder: (context) => CreateCoupon());
    /*} else {
      route = MaterialPageRoute(
          builder: (context) => CreateCoupon(
                id: id,
              ));
    }*/
    Navigator.push(context, route).then(onGoBack);
  }

  void editNavigator(String id) {
    Route route = MaterialPageRoute(
        builder: (context) => CreateCoupon(
              id: id,
            ));

    Navigator.push(context, route).then(onGoBack);
  }

  Widget getLiveCards() {
    return Container(
      child: ListView.builder(
        shrinkWrap: true,
        primary: false,
        scrollDirection: Axis.vertical,
        itemCount: live_data.length,
        itemBuilder: (context, index) {
          var item = live_data[index];

          if (index == live_data.length) {
            return CupertinoActivityIndicator();
          }
          return InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CoupenDetail(
                            item_id: item.id,
                            cat_name: item.business_category_name,
                          )));
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: color.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 10.0, right: 10, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              style: TextStyle(
                                  fontSize: 20,
                                  color: color.primery_color,
                                  fontFamily: 'poppins_bold'),
                            ),
                          ),
                          myPopMenu(item.id, item.business_category_name,
                              item.isActive, "1", context),
                        ],
                      ),

                      Text(
                        item.description,
                        maxLines: 2,

                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14,
                            color: color.gray,
                            fontFamily: 'poppins_raguler'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0, right: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Start On",
                                  style: TextStyle(
                                      color: color.gray,
                                      fontFamily: 'poppins_regular'),
                                ),
                                Text(
                                  item.start_date,
                                  style: TextStyle(
                                      color: color.black,
                                      fontFamily: 'poppins_bold'),
                                ),
                              ],
                            ),
                            Container(
                              width: 2,
                              height: 30,
                              color: color.light_gray,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Expire On",
                                  style: TextStyle(
                                      color: color.gray,
                                      fontFamily: 'poppins_regular'),
                                ),
                                Text(
                                  item.expiery_date,
                                  style: TextStyle(
                                      color: color.black,
                                      fontFamily: 'poppins_bold'),
                                ),
                              ],
                            ),
                            Container(
                              width: 2,
                              height: 30,
                              color: color.light_gray,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Used By",
                                  style: TextStyle(
                                      color: color.gray,
                                      fontFamily: 'poppins_regular'),
                                ),
                                Text(
                                  item.used_count + " Users",
                                  style: TextStyle(
                                      color: color.black,
                                      fontFamily: 'poppins_bold'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
          // }
        },
      ),
    );
  }

  Widget getDisableCards() {
    return Container(
      child: ListView.builder(
        shrinkWrap: true,
        primary: false,
        scrollDirection: Axis.vertical,
        itemCount: disable_data.length,
        itemBuilder: (context, index) {
          var item = disable_data[index];
          if (index == disable_data.length) {
            return CupertinoActivityIndicator();
          }

          return InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CoupenDetail(
                            item_id: item.id,
                            cat_name: item.business_category_name,
                          )));
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: color.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 10.0, right: 10, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              style: TextStyle(
                                  fontSize: 20,
                                  color: color.primery_color,
                                  fontFamily: 'poppins_bold'),
                            ),
                          ),
                          myPopMenu(item.id, item.business_category_name,
                              item.isActive, "2", maincontext),
                        ],
                      ),
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14,
                            color: color.gray,
                            fontFamily: 'poppins_regular'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0, right: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Start On",
                                  style: TextStyle(
                                      color: color.gray,
                                      fontFamily: 'poppins_regular'),
                                ),
                                Text(
                                  item.start_date,
                                  style: TextStyle(
                                      color: color.black,
                                      fontFamily: 'poppins_bold'),
                                ),
                              ],
                            ),
                            Container(
                              width: 2,
                              height: 30,
                              color: color.light_gray,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Expire On",
                                  style: TextStyle(
                                      color: color.gray,
                                      fontFamily: 'poppins_regular'),
                                ),
                                Text(
                                  item.expiery_date,
                                  style: TextStyle(
                                      color: color.black,
                                      fontFamily: 'poppins_bold'),
                                ),
                              ],
                            ),
                            Container(
                              width: 2,
                              height: 30,
                              color: color.light_gray,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Used By",
                                  style: TextStyle(
                                      color: color.gray,
                                      fontFamily: 'poppins_regular'),
                                ),
                                Text(
                                  item.used_count + " Users",
                                  style: TextStyle(
                                      color: color.black,
                                      fontFamily: 'poppins_bold'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget getExpierCards() {
    return Container(
      child: ListView.builder(
        shrinkWrap: true,
        primary: false,
        scrollDirection: Axis.vertical,
        itemCount: expier_data.length,
        itemBuilder: (context, index) {
          var item = expier_data[index];
          if (index == expier_data.length) {
            return CupertinoActivityIndicator();
          }

          return InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CoupenDetail(
                            item_id: item.id,
                            cat_name: item.business_category_name,
                          )));
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: color.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 10.0, right: 10, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              style: TextStyle(
                                  fontSize: 20,
                                  color: color.primery_color,
                                  fontFamily: 'poppins_bold'),
                            ),
                          ),
                          myPopMenuExp(item.id, item.business_category_name,
                              item.isActive, "3", maincontext),
                        ],
                      ),
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14,
                            color: color.gray,
                            fontFamily: 'poppins_raguler'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0, right: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Start On",
                                  style: TextStyle(
                                      color: color.gray,
                                      fontFamily: 'poppins_medium'),
                                ),
                                Text(
                                  item.start_date,
                                  style: TextStyle(
                                      color: color.black,
                                      fontFamily: 'poppins_bold'),
                                ),
                              ],
                            ),
                            Container(
                              width: 2,
                              height: 30,
                              color: color.light_gray,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Expire On",
                                  style: TextStyle(
                                      color: color.gray,
                                      fontFamily: 'poppins_medium'),
                                ),
                                Text(
                                  item.expiery_date,
                                  style: TextStyle(
                                      color: color.black,
                                      fontFamily: 'poppins_bold'),
                                ),
                              ],
                            ),
                            Container(
                              width: 2,
                              height: 30,
                              color: color.light_gray,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Used By",
                                  style: TextStyle(
                                      color: color.gray,
                                      fontFamily: 'poppins_medium'),
                                ),
                                Text(
                                  item.used_count + " Users",
                                  style: TextStyle(
                                      color: color.black,
                                      fontFamily: 'poppins_bold'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget myPopMenu(String id, String category_name, String isActive,
      String type, BuildContext context1) {
    return PopupMenuButton(
        onSelected: (value) {
          if (value == 1) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CoupenDetail(
                          item_id: id,
                          cat_name: category_name,
                        )));
          } else if (value == 2) {
            editNavigator(id);
          } else if (value == 3) {
            if (isActive == "1") {
              couponStatus("0", id, type);
            } else {
              couponStatus("1", id, type);
            }
          } else if (value == 4) {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Are you sure you want to delete?"),
                    actions: <Widget>[
                      FlatButton(
                          onPressed: () async {
                            deleteCoupon(id, type, context);
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
          }
        },
        icon: Icon(Icons.more_vert, color: color.primery_color),
        itemBuilder: (context) => [
              PopupMenuItem(value: 1, child: Container(child: Text('View'))),
              PopupMenuItem(value: 2, child: Text('Edit')),
              PopupMenuItem(value: 4, child: Text('Delete')),
              PopupMenuItem(
                  value: 3,
                  child: type == "3"
                      ? Container()
                      : isActive == "1"
                          ? Text('Disable')
                          : Text('Active')),
            ]);
  }

  Widget myPopMenuExp(String id, String category_name, String isActive,
      String type, BuildContext context1) {
    return PopupMenuButton(
        onSelected: (value) {
          if (value == 1) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CoupenDetail(
                          item_id: id,
                          cat_name: category_name,
                        )));
          } else if (value == 4) {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Are you sure you want to delete?"),
                    actions: <Widget>[
                      FlatButton(
                          onPressed: () async {
                            deleteCoupon(id, type, context);
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
          }
        },
        icon: Icon(Icons.more_vert, color: color.primery_color),
        itemBuilder: (context) => [
              PopupMenuItem(value: 1, child: Container(child: Text('View'))),
              PopupMenuItem(value: 4, child: Text('Delete')),
            ]);
  }
}
