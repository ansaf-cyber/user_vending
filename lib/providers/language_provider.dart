
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  Locale _locale = const Locale('en'); // Default locale
  final SharedPreferences _prefs;

 
  LanguageProvider(this._prefs) {


    // Load saved language on initialization
    _locale = Locale(_prefs.getString('selectedLanguage') ?? 'en');
  }

  Locale get locale => _locale;

  String get languageCode => _locale.languageCode; // ✅ ADD THIS

  void setLocale(String languageCode) async {
    if (['en', 'ar'].contains(languageCode)) {
      _locale = Locale(languageCode);
      await _prefs.setString('selectedLanguage', languageCode);
      notifyListeners();
    }
  }

 
}
