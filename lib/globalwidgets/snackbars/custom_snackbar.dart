import 'package:flutter/material.dart';

enum SnackbarType { success, warning, error }

void showCustomSnackbar({
  required BuildContext context,
  required SnackbarType type,
  required String message,
}) {
  // final colorScheme = Theme.of(context).colorScheme;

  Color backgroundColor;
  IconData iconData;

  switch (type) {
    case SnackbarType.success:
      backgroundColor = Colors.green;
      iconData = Icons.check_circle;
      break;
    case SnackbarType.warning:
      backgroundColor = Colors.orange;
      iconData = Icons.warning_amber_rounded;
      break;
    case SnackbarType.error:
      backgroundColor = Colors.red;
      iconData = Icons.error;
      break;
  }

  final snackBar = SnackBar(
    content: Row(
      children: [
        Icon(iconData, color: Colors.white),
        const SizedBox(width: 12),
        Expanded(
          child: Text(message, style: const TextStyle(color: Colors.white)),
        ),
      ],
    ),
    backgroundColor: backgroundColor,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    duration: const Duration(seconds: 3),
  );

  if (context.mounted) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

//need to fix error when logout from otp screen
