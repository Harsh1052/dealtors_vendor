import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dealtors_vendor/style/Color.dart' as color;

Future<void> FailVerifyDialog(BuildContext context,String msg) async {

  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40.0)), //this right here
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 60.0, bottom: 40, left: 20, right: 20),
                child: Column(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: SizedBox(
                        height: 100.0,
                        width: 100.0,
                        child: new Image.asset(
                          "assets/blocked_user.jpg",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 0, top: 10.0, right: 0, bottom: 0),
                      child: Center(
                        child: Text(
                          "Sorry !!",
                          style: TextStyle(
                              color: color.black,
                              fontSize: 25,
                              fontFamily: 'poppins_bold'),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 0, top: 10.0, right: 0, bottom: 0),
                      child: Center(
                        child: Text(
                          ""+msg,
                          style: TextStyle(color: color.gray),
                        ),
                      ),
                    ),
                    Padding(
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

                            },
                            child: Text(
                              "Try Again",
                              style: TextStyle(color: Colors.white),
                            ),
                            color: color.primery_color,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
