import 'package:flutter/material.dart';

class IconHelper {
  static IconData iconFromCodePoint(int codePoint) {
    return IconData(
      codePoint,
      fontFamily: 'MaterialIcons',
    );
  }
}