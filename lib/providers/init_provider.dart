import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user/models/country_model.dart';

class InitilisationProvider extends ChangeNotifier {
  CountryDataStruct? _selectedCountry;

  CountryDataStruct? get selectedCountry => _selectedCountry;
  InitilisationProvider() {
    //
  }
  // Function to initialize the selected country from SharedPreferences
  Future<void> initializeCountry(BuildContext context) async {
    try {
      // Load SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      String? savedIsoCode =
          prefs.getString('selectedDeliveringCountry') ?? 'kw';

      // Load country data from JSON
      final String jsonString = await DefaultAssetBundle.of(
        context,
      ).loadString('assets/jsons/countryData.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      final countries =
          jsonData.map((json) => CountryDataStruct.fromJson(json)).toList();

      // Find the country matching the saved ISO code, default to Kuwait if not found
      final selectedCountry = countries.firstWhere(
        (country) => country.code.toLowerCase() == savedIsoCode.toLowerCase(),
        orElse:
            () => countries.firstWhere(
              (country) => country.code.toLowerCase() == 'kw',
              orElse:
                  () => CountryDataStruct(
                    code: 'kw',
                    dialCode: '+965',
                    name: 'Kuwait',
                    flag: '',
                  ), // Hardcoded fallback
            ),
      );

      // Update the selected country and notify listeners
      _selectedCountry = selectedCountry;
      notifyListeners();

      // Save the selected country code to SharedPreferences (in case it was 'kw' by default)
      await prefs.setString(
        'selectedDeliveringCountry',
        selectedCountry.code.toLowerCase(),
      );
    } catch (e) {
      // Handle errors (e.g., JSON file not found or invalid)
      print('Error initializing country: $e');
      // Fallback to Kuwait if an error occurs
      _selectedCountry = CountryDataStruct(
        code: 'kw',
        dialCode: '+965',
        name: 'Kuwait',
        flag: '',
      );
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedDeliveringCountry', 'kw');
    }
  }

  // Function to set a new selected country and save to SharedPreferences
  Future<void> setSelectedCountry(CountryDataStruct country) async {
    _selectedCountry = country;
    notifyListeners();

    // Save the new country code to SharedPreferences
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setString(
    //   'selectedDeliveringCountry',
    //   country.code.toLowerCase(),
    // );
  }
}




class PlanLimitService {
  final FirebaseFirestore _firestore;

  // Cache for products
  final Map<String, Map<String, dynamic>> _productCache = {};

  PlanLimitService(this._firestore);

  /// Initialize and fetch product limits for "free" and "pro"
  Future<void> initialize() async {
    try {
      final productQuery = await _firestore
          .collection('products')
          .where('name', whereIn: ['free', 'pro'])
          .get();

      for (var doc in productQuery.docs) {
        _productCache[doc.id] = doc.data();
      }

      // Optional: log to verify
      log("Product cache initialized: $_productCache");
    } catch (e) {
      log("Error initializing product cache: $e");
    }
  }

 
}


