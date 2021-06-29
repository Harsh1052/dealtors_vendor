import 'package:dealtors_vendor/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:dealtors_vendor/style/Color.dart' as color;

Future<void> ShowAlert(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)), //this right here
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                //mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context, true);
                        },
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Icon(
                            Icons.close,
                            size: 24.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: SizedBox(
                      height: 120.0,
                      width: 120.0,
                      child: new Image.asset(
                        "assets/alert_green.jpg",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 10, top: 0.0, right: 10.0, bottom: 0),
                      child: Text(
                        "Are You Sure you want to\n use this Coupon",
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 20, fontFamily: 'poppins_bold'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: MaterialButton(
                        height: 40,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                        onPressed: () {
                          Navigator.pop(context, true);
                          ShowCouponCode(context);
                        },
                        child: Text(
                          "Yes",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: color.primery_color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Future<void> ShowCouponCode(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true, // user must tap button!
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)), //this right here
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 20),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                //mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: SizedBox(
                      height: 120.0,
                      width: 120.0,
                      child: new Image.asset(
                        "assets/alert_green.jpg",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Text(
                      "Congratulation!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 25,
                          color: color.black,
                          fontFamily: 'poppins_bold'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Here's the code for  your 50% off",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          color: color.gray,
                          fontFamily: 'poppins_medium'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Text(
                      "ZP10USE",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 30,
                          color: color.black,
                          fontFamily: 'poppins_bold'),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 20.0, left: 20, right: 20),
                    child: Text(
                      "Please share this code with restaurant",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          color: color.gray,
                          fontFamily: 'poppins_medium'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: MaterialButton(
                        height: 40,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                        onPressed: () {
                          Navigator.pop(context, true);
                          /*  Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FeedBackPage()));
                        */
                        },
                        child: Text(
                          " Done ",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: color.primery_color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
