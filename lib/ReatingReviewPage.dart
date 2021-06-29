import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:dealtors_vendor/style/Color.dart' as color;
import 'package:flutter/services.dart';
import 'package:readmore/readmore.dart';
import 'CustomWidget/empty.dart';
import 'Model/ReatingReview.dart';
import 'package:dealtors_vendor/netutils/Retrofit.dart' as retrofit;
import 'dart:convert';

import 'netutils/preferences.dart';

class ReatingReviewPage extends StatefulWidget {
  @override
  _ReatingReviewPageState createState() => _ReatingReviewPageState();
}

class _ReatingReviewPageState extends State<ReatingReviewPage> {
  List<ReatingReview> data=new List();
  String average_rating = "";
  bool isProgress = false;
  String ack = "", ack_msg = "";
  bool is_connected = false;
  int ul = 50, ll = 0;
  ScrollController review_scrollController = ScrollController();

  final Connectivity _connectivity = Connectivity();

  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    // TODO: implement initState
    // _populateData();
    super.initState();
    initConnectivity();
    review_scrollController.addListener(() {
      if (review_scrollController.position.pixels ==
          review_scrollController.position.maxScrollExtent) {
        getReview();
        setState(() {});
      }
    });
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    setState(() {
      if (is_connected) {
        // TODO: implement initState
        getReview();
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
          getReview();
        });
        break;
      case ConnectivityResult.mobile:
        setState(() {
          is_connected = true;
          getReview();
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

  Future<String> getReview() async {
    isProgress = true;
    var response = await retrofit.getReview(
        await SharedPreferencesHelper.getPreference("user_id"),
        ll.toString(),
        ul.toString());
    setState(() {
      var extractdata = json.decode(response.body);
      ack = extractdata['ack'].toString();
      ack_msg = extractdata['ack_msg'].toString();
      average_rating = extractdata['average_rating'].toString();
      if (extractdata['ack'] == 1) {
        try {
          /*data = List<ReatingReview>.from(
              extractdata["result"].map((x) => ReatingReview.fromJson(x)));*/
          for (int i = 0; i <= extractdata['result'].length; i++) {
            ReatingReview rr = new ReatingReview();
            rr.id = extractdata['result'][i]['id'].toString();
            rr.user_name = extractdata['result'][i]['user_name'].toString();
            rr.review_date = extractdata['result'][i]['review_date'].toString();
            rr.image_path = extractdata['result'][i]['image_path'].toString();
            rr.rate = extractdata['result'][i]['rate'].toString();
            rr.review = extractdata['result'][i]['review'].toString();
            data.add(rr);
          }
          //coupon_data = vendor_detail[0].coupons;
        } catch (e) {
          print(e);
        }
        ll = ll + data.length;
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
      ),
      home: Scaffold(
        appBar: new AppBar(
          shadowColor: null,
          elevation: 0.0,
          // backgroundColor: color.white,
          title: Text(
            "Ratings & Reviews ",
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
                  : data == null
                      ? Visibility(
                          maintainSize: false,
                          maintainAnimation: true,
                          maintainState: true,
                          visible: isProgress,
                          child: LinearProgressIndicator())
                      : Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: Text(
                                    "My Ratings",
                                    style: TextStyle(
                                        color: color.black,
                                        fontSize: 15,
                                        fontFamily: 'poppins_medium'),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: color.gray),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                  ),
                                  child: Center(
                                      child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "" + average_rating,
                                        style: TextStyle(
                                            fontFamily: 'poppins_bold',
                                            fontSize: 20),
                                      ),
                                      Icon(
                                        Icons.star,
                                        color: Colors.deepOrange,
                                      )
                                    ],
                                  )),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: Text(
                                    "My Reviews",
                                    style: TextStyle(
                                        color: color.black,
                                        fontSize: 15,
                                        fontFamily: 'poppins_medium'),
                                  ),
                                ),
                                ListView(
                                  primary: false,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  children: [_buildCardListView()],
                                )
                              ],
                            ),
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
        itemCount: data.length,
        itemBuilder: (context, index) {
          var item = data[index];
          return InkWell(
            onTap: () {},
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        new Container(
                            width: 50.0,
                            height: 50.0,
                            decoration: new BoxDecoration(
                                shape: BoxShape.circle,
                                image: new DecorationImage(
                                    fit: BoxFit.fill,
                                    image: new NetworkImage(item.image_path)))),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 10.0, right: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.user_name,
                                  style: TextStyle(
                                      fontSize: 15,
                                      //  color: color.green,
                                      fontFamily: 'poppins_bold'),
                                ),
                                Text(
                                  item.review_date,
                                  style: TextStyle(
                                      fontSize: 15,
                                      //  color: color.green,
                                      fontFamily: 'poppins_reguler'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Text(
                          item.rate,
                          style: TextStyle(
                              fontFamily: 'poppins_bold', fontSize: 15),
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.deepOrange,
                        )
                      ],
                    ),
                    Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ReadMoreText(
                          item.review,
                          trimLines: 2,
                          trimMode: TrimMode.Line,
                          trimCollapsedText: 'View more',
                          trimExpandedText: 'View less',
                          moreStyle: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ) /*Text(
                        item.review,
                        style: TextStyle(
                            fontSize: 15,
                            //  color: color.green,
                            fontFamily: 'poppins_reguler'),
                      ),*/
                        ),
                    Divider(
                      thickness: 2,
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
