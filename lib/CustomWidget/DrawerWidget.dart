import 'package:dealtors_vendor/AboutUs.dart';
import 'package:dealtors_vendor/AllCouponPage.dart';
import 'package:dealtors_vendor/CoupenDetail.dart';
import 'package:dealtors_vendor/CreateCoupon.dart';
import 'package:dealtors_vendor/HistoryPage.dart';
import 'package:dealtors_vendor/HomePage.dart';
import 'package:dealtors_vendor/Model/Coupon.dart';
import 'package:dealtors_vendor/ReatingReviewPage.dart';
import 'package:dealtors_vendor/netutils/preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dealtors_vendor/style/Color.dart' as color;

import '../Profile.dart';

//final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

Drawer drawer(BuildContext context, GlobalKey<ScaffoldState> _scaffoldKey,
    String pagename, String app_version) {
  return Drawer(
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
                    child:
                        new Image.asset("assets/logo.png", fit: BoxFit.cover),
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
                            builder: (context) => AllCouponPage()));
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
                            builder: (context) => CreateCoupon()));
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
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Profile()));
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
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AboutUs()));
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
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HistoryPage()));
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
                            builder: (context) => ReatingReviewPage()));
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
                            title: Text("Are you sure you want to logout?"),
                            actions: <Widget>[
                              FlatButton(
                                  onPressed: () async {
                                    await SharedPreferencesHelper
                                        .clearAllPreference();
                                    Navigator.of(context)
                                        .pushNamedAndRemoveUntil('/loginpage',
                                            (Route<dynamic> route) => false);
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
                Text("V " + app_version,
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
  );
}
