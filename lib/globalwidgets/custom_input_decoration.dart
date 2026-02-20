import 'package:flutter/material.dart';
import 'package:user/theme/apptheme.dart';

InputDecoration customInputDecoration({
  required BuildContext context,
  required String hintText,
  Widget? suffixIcon,
}) {
  final theme = Apptheme.of(context);
  return InputDecoration(
    hintText: hintText,

    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: theme.alternate.withOpacity(0.9), // alternate
        width: 2,
      ),
      borderRadius: BorderRadius.circular(15),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: theme.primary, width: 2),
      borderRadius: BorderRadius.circular(15),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red, width: 2),
      borderRadius: BorderRadius.circular(15),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red, width: 2),
      borderRadius: BorderRadius.circular(15),
    ),
    filled: true,
    fillColor: theme.secondaryBackground,
    contentPadding: const EdgeInsetsDirectional.fromSTEB(15, 20, 0, 20),
    suffixIcon: suffixIcon,
  );
}
