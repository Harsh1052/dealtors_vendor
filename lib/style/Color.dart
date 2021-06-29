library flutter_images.colors;

import 'package:flutter/material.dart';

//const primaryColor = Colors.blue;
const black = Colors.black;
const white = Colors.white;
Color background = HexColor("#E8EAE9");
Color primery_color = HexColor("#3196b0");
Color  primery_color_dark= HexColor("#000000");
Color  red= HexColor("#B52506");
Color  gray= HexColor("#757575");
Color  light_gray= HexColor("#dadada");
Color  blue= HexColor("#0000FF");
Color  hint_color= HexColor("#bababa");
Color  resend= HexColor("#5302dd");

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

/*static const primaryGradient = const LinearGradient(
    colors: const [loginGradientStart, loginGradientEnd],
    stops: const [0.0, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );*/
}
