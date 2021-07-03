import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:date_format/date_format.dart';
import 'package:dealtors_vendor/HomePage.dart';
import 'package:dealtors_vendor/netutils/Retrofit.dart' as retrofit;
import 'package:dealtors_vendor/style/Color.dart' as color;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'AccountVerifyFailedPage.dart';
import 'CustomWidget/ToastFile.dart';
import 'Model/Vendor.dart';
import 'WaitingForApprovel.dart';
import 'netutils/preferences.dart';

class AddRestaurantPage extends StatefulWidget {
  String mode, category_id, category_name;

  AddRestaurantPage({Key key, this.mode, this.category_id, this.category_name})
      : super(key: key);

  @override
  _AddRestaurantPageState createState() => _AddRestaurantPageState();
}

class _AddRestaurantPageState extends State<AddRestaurantPage> {
  List<VendorDetail> vendor_detail;
  bool isProgress = false;
  String ack = "", ack_msg = "";
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String category_id = "";
  final close_time = TextEditingController();
  final open_time = TextEditingController();
  final close_time_evening = TextEditingController();
  final open_time_evening = TextEditingController();
  final close_time_morning = TextEditingController();
  final open_time_morning = TextEditingController();
  final buisness_name = TextEditingController();
  final business_contact = TextEditingController();
  final business_area = TextEditingController();
  final business_landmark = TextEditingController();
  final business_location = TextEditingController();
  final business_about = TextEditingController();
  String _hour, _minute, _time;
  var result;
  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);
  String _setTime = "";

  Future<File> file;
  String status = '';
  String base64Image;
  File tmpFile;
  String errMessage = 'Error Uploading Image';
  String image_path = "";
  bool is_connected = false;
  bool isSplite = false;

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
        if (widget.mode == 'edit' || widget.mode == 'reapply') {
          this.getVendorDetail();
        } else {
          category_id = widget.category_id;
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
          if (widget.mode == 'edit' || widget.mode == 'reapply') {
            this.getVendorDetail();
          } else {
            category_id = widget.category_id;
          }
        });
        break;
      case ConnectivityResult.mobile:
        setState(() {
          is_connected = true;
          if (widget.mode == 'edit' || widget.mode == 'reapply') {
            this.getVendorDetail();
          } else {
            category_id = widget.category_id;
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

  Future<String> editBussiness() async {
    setState(() {
      isProgress = true;
    });
    var response = null;

    if (base64Image != null) {
      response = await retrofit.editBussinessWithImage(
          await SharedPreferencesHelper.getPreference("user_id"),
          await SharedPreferencesHelper.getPreference("name"),
          await SharedPreferencesHelper.getPreference("email_address"),
          await SharedPreferencesHelper.getPreference("mobile_no"),
          category_id,
          buisness_name.text,
          business_about.text,
          business_contact.text,
          business_location.text,
          business_area.text,
          business_landmark.text,
          open_time.text,
          close_time.text,
          base64Image,
          open_time_morning.text,
          close_time_morning.text,
          open_time_evening.text,
          close_time_evening.text,
          isSplite);
    } else {
      response = await retrofit.editBussiness(
          await SharedPreferencesHelper.getPreference("user_id"),
          await SharedPreferencesHelper.getPreference("name"),
          await SharedPreferencesHelper.getPreference("email_address"),
          await SharedPreferencesHelper.getPreference("mobile_no"),
          category_id,
          buisness_name.text,
          business_about.text,
          business_contact.text,
          business_location.text,
          business_area.text,
          business_landmark.text,
          open_time.text,
          close_time.text,
          open_time_morning.text,
          close_time_morning.text,
          open_time_evening.text,
          close_time_evening.text,
          isSplite);
    }

    var extractdata = json.decode(response.body);
    print(extractdata);
    if (extractdata['ack'] == 1) {
      result = extractdata["result"];

      SharedPreferencesHelper.setPreference("user_id", result["id"]);
      SharedPreferencesHelper.setPreference("name", result["first_name"]);
      SharedPreferencesHelper.setPreference(
          "business_name", result["business_name"]);
      SharedPreferencesHelper.setPreference("mobile_no", result["mobile_no"]);
      SharedPreferencesHelper.setPreference(
          "email_address", result["email_address"]);
      //  print("3 is active"+ result['isActive'] );
      //SnackBarSuccess(extractdata['ack_msg'], this.context, _scaffoldKey);
      isProgress = false;
      print(result['status']);
      //if (widget.mode == 'edit') {
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
      } else if (result['status'] ==
          "3") //array("1"=>"Active","2"=>"Rejected","3"=>"Under approval","4"=>"Blocked");
      {
        print(result['status']);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => WaitingForApprovel()),
          (Route<dynamic> route) => false,
        );
      } else if (widget.mode == "edit") {
        Navigator.pop(context);
      } else if (widget.mode == "reapply") {
        Route home = MaterialPageRoute(builder: (context) => HomePage());
        Navigator.pushReplacement(context, home);
      } else {
        Route home = MaterialPageRoute(builder: (context) => HomePage());
        Navigator.pushReplacement(context, home);
      }
      /* } else {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HomePage()));
        }*/

      print(extractdata['ack_msg']);
    } else {
      //  SnackBarFail(extractdata['ack_msg'], context, _scaffoldKey);
      print(extractdata['ack_msg']);
      isProgress = false;
    }
  }

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
          category_id = vendor_detail[0].business_category_id;
          buisness_name.text = vendor_detail[0].business_name;
          business_about.text = vendor_detail[0].about_business;
          business_contact.text = vendor_detail[0].business_contact_no;
          business_area.text = vendor_detail[0].business_area;
          business_landmark.text = vendor_detail[0].business_landmark;
          business_location.text = vendor_detail[0].business_location;
          open_time.text = vendor_detail[0].open_time;
          close_time.text = vendor_detail[0].close_time;
          open_time_morning.text = vendor_detail[0].open_time;
          close_time_morning.text = vendor_detail[0].close_time;
          open_time_evening.text = vendor_detail[0].openTimeEvening;
          close_time_evening.text = vendor_detail[0].closeTimeEvening;
          print("Close Time=${close_time_evening.text}");
          print("Close Time=${vendor_detail[0].closeTimeEvening}");
          image_path = vendor_detail[0].image_path;
          isSplite = vendor_detail[0].splitFlag == "0" ? false : true;
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

  chooseImage() {
    setState(() {
      file = ImagePicker.pickImage(source: ImageSource.gallery);
    });
  }

  Future<Null> _selectTime(
      BuildContext context, TextEditingController text_controller) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null)
      setState(() {
        print("hello");
        selectedTime = picked;
        _hour = selectedTime.hour.toString();
        _minute = selectedTime.minute.toString();
        _time = _hour + ' : ' + _minute;
        text_controller.text = _time;
        text_controller.text = formatDate(
            DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
            [hh, ':', nn, " ", am]).toString();
      });
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

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
                Visibility(
                    maintainSize: false,
                    maintainAnimation: true,
                    maintainState: true,
                    visible: isProgress,
                    child: LinearProgressIndicator()),
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
                                widget.mode == 'edit' ||
                                        widget.mode == 'reapply'
                                    ? Text(
                                        "Edit Your Business",
                                        style: TextStyle(
                                            fontSize: 25,
                                            fontFamily: 'poppins_bold',
                                            color: color.white),
                                      )
                                    : Text(
                                        "Open Your Business",
                                        style: TextStyle(
                                            fontSize: 25,
                                            fontFamily: 'poppins_bold',
                                            color: color.white),
                                      ),
                                Text(
                                  "Enter Your Business Details here ",
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
                                  "Business Logo",
                                  style: TextStyle(
                                    fontFamily: 'poppins_medium',
                                    fontSize: 12,
                                  ),
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: showImage(),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0, top: 20),
                            child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "Business Name",
                                  style: TextStyle(
                                    fontFamily: 'poppins_medium',
                                    fontSize: 12,
                                  ),
                                )),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: 10.0, bottom: 10.0, left: 0.0, right: 0.0),
                            child: TextFormField(
                              autofocus: false,
                              controller: buisness_name,
                              keyboardType: TextInputType.text,
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
                                hintText: "Enter your Business Name here",
                                hintStyle: TextStyle(
                                  color: color.hint_color,
                                  fontSize: 14,
                                ),
                                // labelText: 'Phone number',
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "About Business",
                                  style: TextStyle(
                                    fontFamily: 'poppins_medium',
                                    fontSize: 12,
                                  ),
                                )),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: 10.0, bottom: 10.0, left: 0.0, right: 0.0),
                            child: TextFormField(
                              autofocus: false,
                              controller: business_about,
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
                                    "Enter Full Detail About Your Business here",
                                hintStyle: TextStyle(
                                  color: color.hint_color,
                                  fontSize: 14,
                                ),
                                // labelText: 'Phone number',
                              ),
                              maxLines: 15,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "Business Contact",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'poppins_medium'),
                                )),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: 10.0, bottom: 10.0, left: 0.0, right: 0.0),
                            child: TextFormField(
                              autofocus: false,
                              controller: business_contact,
                              keyboardType: TextInputType.number,
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
                                  hintText: "Enter Contact Number",
                                  hintStyle: TextStyle(
                                      color: color.hint_color, fontSize: 14)
                                  // labelText: 'Phone number',
                                  ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0, top: 0),
                            child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "Area",
                                  style: TextStyle(
                                    fontFamily: 'poppins_medium',
                                    fontSize: 12,
                                  ),
                                )),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: 10.0, bottom: 10.0, left: 0.0, right: 0.0),
                            child: TextFormField(
                              autofocus: false,
                              controller: business_area,
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
                                  hintText: "Enter area",
                                  hintStyle: TextStyle(
                                    color: color.hint_color,
                                    fontSize: 14,
                                  )
                                  // labelText: 'Phone number',
                                  ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0, top: 0),
                            child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "Landmark",
                                  style: TextStyle(
                                    fontFamily: 'poppins_medium',
                                    fontSize: 12,
                                  ),
                                )),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: 10.0, bottom: 10.0, left: 0.0, right: 0.0),
                            child: TextFormField(
                              autofocus: false,
                              controller: business_landmark,
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
                                  hintText: "Enter landmark",
                                  hintStyle: TextStyle(
                                    color: color.hint_color,
                                    fontSize: 14,
                                  )
                                  // labelText: 'Phone number',
                                  ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0, top: 0),
                            child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  " Address",
                                  style: TextStyle(
                                    fontFamily: 'poppins_medium',
                                    fontSize: 12,
                                  ),
                                )),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: 10.0, bottom: 10.0, left: 0.0, right: 0.0),
                            child: TextFormField(
                              autofocus: false,
                              controller: business_location,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  suffixIcon:
                                      new Icon(Icons.location_on_outlined),
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
                                  hintText: "Enter Your Full Address here",
                                  hintStyle: TextStyle(
                                    color: color.hint_color,
                                    fontSize: 14,
                                  )
                                  // labelText: 'Phone number',
                                  ),
                            ),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value: isSplite,
                                onChanged: (value) {
                                  setState(() {
                                    isSplite = value;
                                  });
                                },
                                activeColor: color.primery_color,
                              ),
                              SizedBox(
                                width: 5.0,
                              ),
                              Text(
                                "Split Time",
                                style: TextStyle(
                                  fontFamily: 'poppins_medium',
                                  fontSize: 14,
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          isSplite
                              ? showSpliteWidget()
                              : Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 20.0, top: 0),
                                              child: Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Text(
                                                    "Opening Time",
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'poppins_medium',
                                                        fontSize: 12),
                                                  )),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: 10.0,
                                                  bottom: 0.0,
                                                  left: 0.0,
                                                  right: 5.0),
                                              child: InkWell(
                                                onTap: () {
                                                  _selectTime(
                                                      context, open_time);
                                                },
                                                child: TextFormField(
                                                  autofocus: false,
                                                  showCursor: false,
                                                  controller: open_time,
                                                  decoration: InputDecoration(
                                                      suffixIcon: new Icon(Icons
                                                          .date_range_sharp),
                                                      fillColor:
                                                          color.light_gray,
                                                      filled: true,
                                                      //   suffixIcon: Icon(Icons.phone),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                              // width: 0.0 produces a thin "hairline" border
                                                              borderSide: BorderSide(
                                                                  color: color
                                                                      .light_gray),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      25.0)),
                                                      focusedBorder:
                                                          new OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                      color: color
                                                                          .gray),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      25.0)),
                                                      border: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  25.0)),
                                                      hintText: "Select Time",
                                                      hintStyle: TextStyle(
                                                          color: color.hint_color,
                                                          fontSize: 14)
                                                      // labelText: 'Phone number',
                                                      ),
                                                  enabled: false,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 20.0, top: 0),
                                              child: Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Text(
                                                    "Closing Time",
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'poppins_medium',
                                                        fontSize: 12),
                                                  )),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: 10.0,
                                                  bottom: 0.0,
                                                  left: 5.0,
                                                  right: 0.0),
                                              child: InkWell(
                                                onTap: () {
                                                  _selectTime(
                                                      context, close_time);
                                                },
                                                child: TextFormField(
                                                  autofocus: false,
                                                  showCursor: false,
                                                  controller: close_time,
                                                  decoration: InputDecoration(
                                                      suffixIcon: new Icon(Icons
                                                          .date_range_sharp),
                                                      fillColor:
                                                          color.light_gray,
                                                      filled: true,
                                                      //   suffixIcon: Icon(Icons.phone),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                              // width: 0.0 produces a thin "hairline" border
                                                              borderSide: BorderSide(
                                                                  color: color
                                                                      .light_gray),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      25.0)),
                                                      focusedBorder:
                                                          new OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                      color: color
                                                                          .gray),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      25.0)),
                                                      border: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  25.0)),
                                                      hintText: "Select Time",
                                                      hintStyle: TextStyle(
                                                          color: color.hint_color,
                                                          fontSize: 14)
                                                      // labelText: 'Phone number',
                                                      ),
                                                  onSaved: (String val) {
                                                    _setTime = val;
                                                  },
                                                  enabled: false,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 30.0),
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
                                    child: Stack(
                                      children: [
                                        Text(
                                          "  Next  ",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.0,
                                          ),
                                        ),
                                        Visibility(
                                            maintainSize: false,
                                            maintainAnimation: true,
                                            maintainState: true,
                                            visible: isProgress,
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            )),
                                      ],
                                    ),
                                  ),
                                  onPressed: () async {
                                    print(
                                        "Open Morning:=${open_time_morning.text}");
                                    print(
                                        "Close Morning:=${close_time_morning.text}");

                                    print(
                                        "Open Morning:=${open_time_evening.text}");
                                    print(
                                        "Close Morning:=${close_time_evening.text}");

                                    if (is_connected) {
                                      if (isProgress == false) {
                                        if (buisness_name.text == "") {
                                          isProgress = false;
                                          SnackBarFail(
                                              "Please Enter Business Name",
                                              context,
                                              _scaffoldKey);
                                        } else if (business_contact.text ==
                                            "") {
                                          isProgress = false;
                                          SnackBarFail(
                                              "Please Enter Business Contact",
                                              context,
                                              _scaffoldKey);
                                        } else if (business_location.text ==
                                            "") {
                                          isProgress = false;
                                          SnackBarFail("Please Enter Location",
                                              context, _scaffoldKey);
                                        } else if (open_time.text == "" &&
                                            open_time_morning.text == "") {
                                          isProgress = false;
                                          SnackBarFail(
                                              "Please Enter Opening time",
                                              context,
                                              _scaffoldKey);
                                        } else if (close_time.text == "" &&
                                            close_time_morning.text == "") {
                                          isProgress = false;

                                          SnackBarFail(
                                              "Please Enter Closing time",
                                              context,
                                              _scaffoldKey);
                                        } else if (open_time_evening.text ==
                                            "") {
                                          isProgress = false;

                                          SnackBarFail(
                                              "Please Enter Eveninig Open time",
                                              context,
                                              _scaffoldKey);
                                        } else if (close_time_evening.text ==
                                            "") {
                                          isProgress = false;

                                          SnackBarFail(
                                              "Please Enter Evening Closing time",
                                              context,
                                              _scaffoldKey);
                                        } else {
                                          isProgress = true;
                                          await editBussiness();
                                        }
                                      }
                                      /*else {
                                        SnackBarFail(
                                            "Still Your old process working",
                                            context,
                                            _scaffoldKey);
                                      }*/
                                    } else {
                                      SnackBarFail("Please Check Your Internet",
                                          context, _scaffoldKey);
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

  Widget showImage() {
    return FutureBuilder<File>(
      future: file,
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            null != snapshot.data) {
          tmpFile = snapshot.data;
          base64Image = base64Encode(snapshot.data.readAsBytesSync());
          return InkWell(
            onTap: () {
              chooseImage();
            },
            child: new Container(
                width: 120.0,
                height: 120,
                decoration: new BoxDecoration(
                  image: new DecorationImage(
                      image: new FileImage(snapshot.data), fit: BoxFit.fill),
                  borderRadius: BorderRadius.circular(10.0),
                )),
          );
        } else if (null != snapshot.error) {
          return InkWell(
            onTap: () {
              chooseImage();
            },
            child: new Container(
                width: 120.0,
                height: 120,
                decoration: new BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    image: new DecorationImage(
                        fit: BoxFit.fill,
                        image: image_path != ""
                            ? new NetworkImage(image_path)
                            : new NetworkImage(retrofit.image)))),
          );
        } else {
          return InkWell(
            onTap: () {
              chooseImage();
            },
            child: new Container(
                width: 120.0,
                height: 120,
                decoration: new BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    image: new DecorationImage(
                        fit: BoxFit.fill,
                        image: image_path != ""
                            ? new NetworkImage(image_path)
                            : new NetworkImage(retrofit.image)))),
          );
        }
      },
    );
  }

  Widget showSpliteWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            "Morning",
            style: TextStyle(
                fontFamily: 'poppins_medium',
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 5.0,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 0),
                      child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Opening Time",
                            style: TextStyle(
                                fontFamily: 'poppins_medium', fontSize: 12),
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: 10.0, bottom: 0.0, left: 0.0, right: 5.0),
                      child: InkWell(
                        onTap: () {
                          _selectTime(context, open_time_morning);
                        },
                        child: TextFormField(
                          autofocus: false,
                          showCursor: false,
                          controller: open_time_morning,
                          decoration: InputDecoration(
                              suffixIcon: new Icon(Icons.date_range_sharp),
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
                              hintText: "Select Time",
                              hintStyle: TextStyle(
                                  color: color.hint_color, fontSize: 14)
                              // labelText: 'Phone number',
                              ),
                          enabled: false,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 0),
                      child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Closing Time",
                            style: TextStyle(
                                fontFamily: 'poppins_medium', fontSize: 12),
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: 10.0, bottom: 0.0, left: 5.0, right: 0.0),
                      child: InkWell(
                        onTap: () {
                          _selectTime(context, close_time_morning);
                        },
                        child: TextFormField(
                          autofocus: false,
                          showCursor: false,
                          controller: close_time_morning,
                          decoration: InputDecoration(
                              suffixIcon: new Icon(Icons.date_range_sharp),
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
                              hintText: "Select Time",
                              hintStyle: TextStyle(
                                  color: color.hint_color, fontSize: 14)
                              // labelText: 'Phone number',
                              ),
                          onSaved: (String val) {
                            _setTime = val;
                          },
                          enabled: false,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            "Evening",
            style: TextStyle(
                fontFamily: 'poppins_medium',
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 5.0,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 0),
                      child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Opening Time",
                            style: TextStyle(
                                fontFamily: 'poppins_medium', fontSize: 12),
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: 10.0, bottom: 0.0, left: 0.0, right: 5.0),
                      child: InkWell(
                        onTap: () {
                          _selectTime(context, open_time_evening);
                        },
                        child: TextFormField(
                          autofocus: false,
                          showCursor: false,
                          controller: open_time_evening,
                          decoration: InputDecoration(
                              suffixIcon: new Icon(Icons.date_range_sharp),
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
                              hintText: "Select Time",
                              hintStyle: TextStyle(
                                  color: color.hint_color, fontSize: 14)
                              // labelText: 'Phone number',
                              ),
                          enabled: false,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 0),
                      child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Closing Time",
                            style: TextStyle(
                                fontFamily: 'poppins_medium', fontSize: 12),
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: 10.0, bottom: 0.0, left: 5.0, right: 0.0),
                      child: InkWell(
                        onTap: () {
                          _selectTime(context, close_time_evening);
                        },
                        child: TextFormField(
                          autofocus: false,
                          showCursor: false,
                          controller: close_time_evening,
                          decoration: InputDecoration(
                              suffixIcon: new Icon(Icons.date_range_sharp),
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
                              hintText: "Select Time",
                              hintStyle: TextStyle(
                                  color: color.hint_color, fontSize: 14)
                              // labelText: 'Phone number',
                              ),
                          onSaved: (String val) {
                            _setTime = val;
                          },
                          enabled: false,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
