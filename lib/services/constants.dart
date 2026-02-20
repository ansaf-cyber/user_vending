import 'package:flutter/material.dart';
import 'package:user/theme/apptheme.dart';

class AppTextStyles {
  static TextStyle headerTextstyle(BuildContext context) => TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 25,
    color: Apptheme.of(context).primaryText,
  );
  static TextStyle headingStyle2(BuildContext context) => TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: Apptheme.of(context).primaryText,
  );
}
