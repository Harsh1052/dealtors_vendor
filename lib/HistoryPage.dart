import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:dealtors_vendor/Model/Coupon.dart';
import 'package:dealtors_vendor/netutils/Retrofit.dart';
import 'package:flutter/material.dart';
import 'package:dealtors_vendor/style/Color.dart' as color;
import 'package:dealtors_vendor/netutils/Retrofit.dart' as retrofit;
import 'package:flutter/services.dart';
import 'dart:convert';

import 'CustomWidget/empty.dart';
import 'netutils/preferences.dart';

class HistoryPage extends StatefulWidget {
  @override
  _UsedCouponState createState() => _UsedCouponState();
}

class _UsedCouponState extends State<HistoryPage> {
  List<UsedCouponModel> coupon_data=new List();

  bool isProgress = false;
  String ack = "", ack_msg = "";
  bool is_connected = false;
  int ul = 50, ll = 0;
  ScrollController history_scrollController = ScrollController();

  final Connectivity _connectivity = Connectivity();

  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    // TODO: implement initState
    // _populateData();
    super.initState();
    initConnectivity();

    history_scrollController.addListener(() {
      if (history_scrollController.position.pixels ==
          history_scrollController.position.maxScrollExtent) {
        getUsedCoupon();
        setState(() {});
      }
    });
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    setState(() {
      if (is_connected) {
        // TODO: implement initState
        getUsedCoupon();
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
          ll = 0;
          getUsedCoupon();
        });
        break;
      case ConnectivityResult.mobile:
        setState(() {
          is_connected = true;
          ll = 0;
          getUsedCoupon();
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

  Future<String> getUsedCoupon() async {
    isProgress = true;
    var response = await retrofit.getUsedCoupon(
        await SharedPreferencesHelper.getPreference("user_id"),
        ll.toString(),
        ul.toString());
    setState(() {
      var extractdata = json.decode(response.body);
      ack = extractdata['ack'].toString();
      ack_msg = extractdata['ack_msg'].toString();
      if (extractdata['ack'] == 1) {
        try {
          /* coupon_data = List<UsedCouponModel>.from(
              extractdata["result"].map((x) => UsedCouponModel.fromJson(x)));*/
          for (int i = 0; i <= extractdata['result'].length; i++) {
            UsedCouponModel uc = UsedCouponModel();
            uc.id = extractdata["result"][i]['id'].toString();
            uc.title = extractdata["result"][i]['coupon_name'].toString();
            uc.description = extractdata["result"][i]['description'].toString();
            uc.used_date = extractdata["result"][i]['used_date'].toString();
            uc.vendor_id = extractdata["result"][i]['vendor_id'].toString();
            uc.business_category_name =
                extractdata["result"][i]['business_category_name'].toString();
            uc.customer_name = extractdata["result"][i]['user_name'].toString();
            uc.bill_amount = extractdata["result"][i]['bill_amount'].toString();
            coupon_data.add(uc);
          }
        } catch (e) {
          print(e);
        }
        ll = ll + coupon_data.length;

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
          accentColor: color.primery_color_dark

          //   accentColor: Theme.colors.button,
          ),
      home: Scaffold(
        backgroundColor: color.light_gray,
        appBar: new AppBar(
          shadowColor: null,
          elevation: 0.0,
          // backgroundColor: color.white,
          title: Text(
            "History",
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
              : ack != "1" && isProgress == false && is_connected && ll == 0
                  ? Container(
                      height: MediaQuery.of(context).size.height,
                      child: empty(ack_msg))
                  : coupon_data == null
                      ? Visibility(
                          maintainSize: false,
                          maintainAnimation: true,
                          maintainState: true,
                          visible: isProgress,
                          child: LinearProgressIndicator())
                      : Container(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                                child: ListView(
                              primary: false,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              children: [_buildCardListView()],
                            )),
                          ),
                        ),
        ),
      ),
    );
  }

  Widget _buildCardListView() {
    return Container(
      child: ListView.builder(
        shrinkWrap: true,
        primary: false,
        scrollDirection: Axis.vertical,
        itemCount: coupon_data.length,
        itemBuilder: (context, index) {
          var item = coupon_data[index];
          return InkWell(
            onTap: () {
              /*  Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CoupenDetail(
                            item_id: item.id,
                            cat_name: "",
                          )));
            */
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
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                            fontSize: 20,
                            color: color.primery_color,
                            fontFamily: 'poppins_bold'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Used On",
                                    style: TextStyle(
                                        color: color.gray,
                                        fontFamily: 'poppins_regular'),
                                  ),
                                  Text(
                                    item.used_date,
                                    style: TextStyle(
                                        color: color.black,
                                        fontFamily: 'poppins_bold'),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 20.0, right: 20),
                                child: Container(
                                  width: 2,
                                  height: 30,
                                  color: color.light_gray,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Customer Name",
                                    style: TextStyle(
                                        color: color.gray,
                                        fontFamily: 'poppins_regular'),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        item.customer_name,
                                        softWrap: false,
                                        overflow: TextOverflow.fade,
                                        style: TextStyle(
                                            color: color.black,
                                            fontFamily: 'poppins_bold'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 20.0, right: 20),
                                child: Container(
                                  width: 2,
                                  height: 30,
                                  color: color.light_gray,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Bill Amount",
                                    style: TextStyle(
                                        color: color.gray,
                                        fontFamily: 'poppins_regular'),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        item.bill_amount,
                                        style: TextStyle(
                                            color: color.black,
                                            fontFamily: 'poppins_bold'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ]),
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
}
