import 'package:flutter/material.dart';
import 'package:dealtors_vendor/style/Color.dart' as color;

class ChangePhoneNumber extends StatefulWidget {
  @override
  _ChangePhoneNumberState createState() => _ChangePhoneNumberState();
}

class _ChangePhoneNumberState extends State<ChangePhoneNumber> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        // Define the default brightness and colors.
        // brightness: Brightness.dark,
        primaryColor: color.primery_color_dark,
        //   accentColor: Theme.colors.button,
      ),
      home: Scaffold(
        appBar: new AppBar(
          shadowColor: null,
          elevation: 0.0,
          // backgroundColor: color.white,
          title: Text(
            "Change Phone Number",
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
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, top: 30),
                    child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "New Mobile Number",
                          style: TextStyle(fontFamily: 'poppins_medium'),
                        )),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: 10.0, bottom: 10.0, left: 0.0, right: 0.0),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          fillColor: color.light_gray,
                          filled: true,
                          //   suffixIcon: Icon(Icons.phone),
                          enabledBorder: OutlineInputBorder(
                              // width: 0.0 produces a thin "hairline" border
                              borderSide: BorderSide(color: color.light_gray),
                              borderRadius: BorderRadius.circular(25.0)),
                          focusedBorder: new OutlineInputBorder(
                              borderSide: BorderSide(color: color.gray),
                              borderRadius: BorderRadius.circular(25.0)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0)),
                          hintText: "Enter New Mobile No",
                          hintStyle: TextStyle(color: color.hint_color)
                          // labelText: 'Phone number',
                          ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, top: 30),
                    child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "OTP",
                          style: TextStyle(fontFamily: 'poppins_medium'),
                        )),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: 10.0, bottom: 10.0, left: 0.0, right: 0.0),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          fillColor: color.light_gray,
                          filled: true,
                          //   suffixIcon: Icon(Icons.phone),
                          enabledBorder: OutlineInputBorder(
                              // width: 0.0 produces a thin "hairline" border
                              borderSide: BorderSide(color: color.light_gray),
                              borderRadius: BorderRadius.circular(25.0)),
                          focusedBorder: new OutlineInputBorder(
                              borderSide: BorderSide(color: color.gray),
                              borderRadius: BorderRadius.circular(25.0)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0)),
                          hintText: "OTP",
                          hintStyle: TextStyle(color: color.hint_color)
                          // labelText: 'Phone number',
                          ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: 10.0, bottom: 10.0, left: 25.0, right: 25.0),
                    child: MaterialButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                        color: color.primery_color,
                        height: 45,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 18.0),
                          child: Text(
                            "  Verify  ",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                            ),
                          ),
                        ),
                        onPressed: () {
                          /*Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePage()));
                        */ //userBlockDialog();
                          //showInSnackBarFail("testtt");
                        }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
