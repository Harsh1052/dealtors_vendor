import 'package:flutter/material.dart';

//final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

void SnackBarSuccess(String value, BuildContext context,GlobalKey<ScaffoldState> _scaffoldKey1) {
  FocusScope.of(context).requestFocus(new FocusNode());
  _scaffoldKey1.currentState?.removeCurrentSnackBar();
  _scaffoldKey1.currentState.showSnackBar(new SnackBar(
    content: new Text(
      value,
      textAlign: TextAlign.center,
      style: TextStyle(
          color: Colors.white, fontSize: 12.0, fontFamily: "poppins_medium"),
    ),
    backgroundColor: Colors.green,
    duration: Duration(seconds: 2),
  ));
}

void SnackBarFail(String value, BuildContext context,GlobalKey<ScaffoldState> _scaffoldKey) {
  FocusScope.of(context).requestFocus(new FocusNode());
  _scaffoldKey.currentState?.removeCurrentSnackBar();
  _scaffoldKey.currentState.showSnackBar(new SnackBar(
    content: new Text(
      value,
      textAlign: TextAlign.center,
      style: TextStyle(
          color: Colors.white, fontSize: 12.0, fontFamily: "poppins_medium"),
    ),
    backgroundColor: Colors.red,
    duration: Duration(seconds: 2),
  ));
}
