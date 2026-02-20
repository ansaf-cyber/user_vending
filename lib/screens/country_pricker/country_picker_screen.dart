import 'dart:convert';
import 'dart:developer';

import 'package:circle_flags/circle_flags.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user/globalwidgets/custom_components.dart';
import 'package:user/localization/localisation.dart';
import 'package:user/models/country_model.dart';
import 'package:user/providers/init_provider.dart';
import 'package:user/providers/language_provider.dart';
import 'package:user/theme/apptheme.dart';

// CountryListScreen widget to display a fixed list of countries (India + 6 GCC countries)
class CountryListScreen extends StatefulWidget {
  final bool isWhatsapp;

  const CountryListScreen({super.key, this.isWhatsapp = false});

  @override
  CountryListScreenState createState() => CountryListScreenState();
}

class CountryListScreenState extends State<CountryListScreen> {
  // List to store country data
  List<CountryDataStruct> countries = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCountryData();
  }

  Future<void> loadCountryData() async {
    try {
      final langCode = Provider.of<LanguageProvider>(
        context,
        listen: false,
      ).locale.languageCode;

      // Fetch localized names from Firestore
      final docSnapshot = await FirebaseFirestore.instance
          .collection('targetedCountries')
          .doc('default')
          .get();

      Map<String, String> localizedNames = {};
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null && data.containsKey('countries')) {
          localizedNames = (data['countries'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(
              key.toString().toLowerCase(),
              value[langCode] ?? value['en'] ?? key,
            ),
          );
          log('Localized names from Firestore: $localizedNames');
        }
      }

      // Fallback if Firestore is missing or empty
      if (localizedNames.isEmpty) {
        localizedNames = {
          'bh': langCode == 'ar' ? 'البحرين' : 'Bahrain',
          'kw': langCode == 'ar' ? 'الكويت' : 'Kuwait',
          'om': langCode == 'ar' ? 'عُمان' : 'Oman',
          'qa': langCode == 'ar' ? 'قطر' : 'Qatar',
          'sa': langCode == 'ar' ? 'المملكة العربية السعودية' : 'Saudi Arabia',
          'ae': langCode == 'ar'
              ? 'الإمارات العربية المتحدة'
              : 'United Arab Emirates',
        };
      }

      final String jsonString = await DefaultAssetBundle.of(
        context,
      ).loadString('assets/jsons/countryData.json');
      final List<dynamic> jsonData = json.decode(jsonString);

      setState(() {
        countries =
            jsonData
                .map((json) => CountryDataStruct.fromJson(json))
                .where(
                  (country) =>
                      localizedNames.containsKey(country.code.toLowerCase()),
                )
                .map(
                  (country) => CountryDataStruct(
                    flag: '',
                    code: country.code,
                    name:
                        localizedNames[country.code.toLowerCase()] ??
                        country.name,
                    dialCode: country.dialCode,
                  ),
                )
                .toList()
              ..sort((a, b) => a.name.compareTo(b.name));
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading country data: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Apptheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          children: [
            HeaderWithIcon(
              iconFirst: true,
              isSub: true,
              title: FFLocalizations.of(context).getText('country'),
              leading: const CustomIcon(),
            ),
            const SizedBox(height: 50),
            Consumer<InitilisationProvider>(
              builder: (context, provider, child) {
                return Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : countries.isEmpty
                      ? const Center(child: Text('No countries found'))
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: countries.length,
                          itemBuilder: (context, index) {
                            final country = countries[index];
                            return InkWell(
                              onTap: () {
                                // Return the selected country
                                
                                provider.setSelectedCountry(country);
                                Navigator.pop(context);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: theme.alternate.withOpacity(0.1),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 5,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CircleFlag(country.code, size: 30),
                                    const SizedBox(width: 16),
                                    // Country Name
                                    Expanded(
                                      child: Text(
                                        FFLocalizations.of(
                                          context,
                                        ).getText(country.name.toLowerCase()),
                                        style: TextStyle(
                                          color: theme.primaryText,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    // Dial Code
                                    Text(
                                      textDirection: TextDirection.ltr,
                                      country.dialCode,
                                      style: TextStyle(
                                        color: theme.primaryText.withOpacity(
                                          0.6,
                                        ),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
