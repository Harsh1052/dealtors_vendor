import 'package:flutter/material.dart';
import 'package:dealtors_vendor/style/Color.dart' as color;
import 'package:dealtors_vendor/netutils/Retrofit.dart' as retrofit;
import 'package:flutter_html/flutter_html.dart';

class empty extends StatelessWidget {
  final String label;

  empty(this.label);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            new Container(
              width: 200.0,
              height: 200.0,
              child: Image.asset("assets/no_data.png", fit: BoxFit.cover),
            ),
            Html(
              data: label != null ? '<center>'+label+'</center>' : "",
              defaultTextStyle:
                  TextStyle(fontSize: 16, fontFamily: 'poppins_regular'),
            ), /*Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontFamily: 'poppins_regular'),
            ),*/
          ],
        ),
      ),
    );
  }
}
