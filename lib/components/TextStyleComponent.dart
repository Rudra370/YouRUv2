import 'dart:ui';

import 'package:flutter/material.dart';

class TextComponent {
  static TextStyle uTextStyle(Size size, double fontSize,{Color color, FontWeight fontWeight, double wordSpacing, double letterSpacing}) => TextStyle(
        color: color != null? color : Colors.white,
        fontSize: size.height * (fontSize / 720),
        fontWeight: fontWeight != null ? fontWeight : FontWeight.normal,
        wordSpacing: wordSpacing,
        letterSpacing: letterSpacing,
      );
}
