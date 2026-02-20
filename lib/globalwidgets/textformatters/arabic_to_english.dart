import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ArabicToWesternDigitsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Map of Arabic-Indic numerals to Western digits
    const Map<String, String> arabicToWestern = {
      '٠': '0',
      '١': '1',
      '٢': '2',
      '٣': '3',
      '٤': '4',
      '٥': '5',
      '٦': '6',
      '٧': '7',
      '٨': '8',
      '٩': '9',
    };

    String convertedText = newValue.text;

    // Convert Arabic-Indic numerals to Western digits
    arabicToWestern.forEach((arabic, western) {
      convertedText = convertedText.replaceAll(arabic, western);
    });

    // DON'T remove other characters - keep letters, symbols, spaces, etc.
    // Only convert the Arabic numerals, leave everything else as is

    return TextEditingValue(
      text: convertedText,
      selection: TextSelection.collapsed(offset: convertedText.length),
    );
  }
}
