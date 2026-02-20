import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user/globalwidgets/custom_components.dart';
import 'package:user/localization/localisation.dart';
import 'package:user/models/country_model.dart';
import 'package:user/providers/language_provider.dart';
import 'package:user/screens/signin_page/components/auth_page_components.dart';
import 'package:user/screens/signin_page/screen/auth_screen.dart';
import 'package:user/theme/apptheme.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  List<CountryDataStruct> countries = [];
  bool isLoading = true;
  String? selectedLanguage;
  // CountryDataStruct? selectedCountry;
  late SharedPreferences prefs;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late PageController _pageController;
  int _currentPage = 0;
  bool showCountrySelection = false; // Set to false to hide for now

  final List<Map<String, String>> languages = [
    {'name': 'English', 'code': 'en'},
    {'name': 'عربي', 'code': 'ar'},
  ];

  bool get isLanguageStepComplete => selectedLanguage != null;
  // bool get isCountryStepComplete => selectedCountry != null;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _pageController = PageController();
    initPreferences();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> initPreferences() async {
    prefs = await SharedPreferences.getInstance();
    selectedLanguage = prefs.getString('selectedLanguage') ?? 'en';
    // String? savedIsoCode = prefs.getString('selectedDeliveringCountry');
    // await loadCountryData(context, selectedLanguage!);
    // if (savedIsoCode != null) {
    //   selectedCountry = countries.firstWhere(
    //     (c) => c.code.toLowerCase() == savedIsoCode,
    //     orElse: () => countries.first,
    //   );
    // }
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      if (mounted) {
        isLoading = false;
      }
    });
  }

  Future<void> loadCountryData(BuildContext context, String loc) async {
    try {
      final langCode = Provider.of<LanguageProvider>(
        context,
        listen: false,
      ).locale.languageCode;

      // Fetch localized country names from Firestore
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
              value[langCode] ?? value[loc] ?? key,
            ),
          );
          log('Localized names from Firestore: $localizedNames');
        } else {
          log('No "countries" field found in Firestore.');
        }
      } else {
        log('Document does not exist.');
      }

      // Load countryData.json
      final String jsonString = await DefaultAssetBundle.of(
        context,
      ).loadString('assets/jsons/countryData.json');
      final List<dynamic> jsonData = json.decode(jsonString);

      // Convert JSON to objects and update with localized names
      final List<CountryDataStruct> allCountries = jsonData
          .map((json) => CountryDataStruct.fromJson(json))
          .toList();

      // Filter countries and update names with localized versions
      countries =
          allCountries
              .where(
                (country) =>
                    localizedNames.containsKey(country.code.toLowerCase()),
              )
              .map((country) {
                // Update the name with the localized version
                return CountryDataStruct(
                  flag: '',
                  code: country.code,
                  name:
                      localizedNames[country.code.toLowerCase()] ??
                      country.name,
                  dialCode: country.dialCode,
                );
              })
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name));

      log(
        'Filtered countries: ${countries.map((c) => "${c.name} (${c.code})").toList()}',
      );
      setState(() {}); // Ensure UI updates after loading
    } catch (e) {
      log(e.toString());
      //  rethrow;
    }
  }

  void saveLanguage(String code) async {
    await prefs.setString('selectedLanguage', code);
    setState(() => selectedLanguage = code);
    Provider.of<LanguageProvider>(context, listen: false).setLocale(code);
    loadCountryData(context, code);
    // Removed the animation reset that was causing flickering
  }

  // void saveCountry(CountryDataStruct country) async {
  //   await prefs.setString(
  //     'selectedDeliveringCountry',
  //     country.code.toLowerCase(),
  //   );
  //   setState(() => selectedCountry = country);
  //   if (context.mounted) {
  //     Provider.of<InitilisationProvider>(
  //       context,
  //       listen: false,
  //     ).setSelectedCountry(country);
  //   }
  //   // Removed the animation reset that was causing flickering
  // }

  void _nextPage() {
    if (_currentPage == 0 && isLanguageStepComplete) {
      if (showCountrySelection) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthScreen()),
        );
      }
    }
    //else if (_currentPage == 1 && isCountryStepComplete) {
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (_) => const AuthScreen()),
    //   );
    // }
  }

  void _previousPage() {
    if (_currentPage == 1) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Apptheme.of(context);
    final t = FFLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    HeaderWithIcon(
                      iconFirst: true,
                      isSub: true,
                      title: _currentPage == 0
                          ? t.getText('selectLanguage')
                          : t.getText('selectCountry'),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.secondaryBackground,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: theme.alternate.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Expanded(
                              child: PageView(
                                controller: _pageController,
                                physics: const NeverScrollableScrollPhysics(),
                                onPageChanged: (index) =>
                                    setState(() => _currentPage = index),
                                children: [
                                  _buildLanguageSelection(theme, t),
                                  // if (showCountrySelection)
                                  //   _buildCountrySelection(theme),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (_currentPage == 1)
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: AuthButton(
                                        onPressed: _previousPage,
                                        text: t.getText('back'),
                                        isEnabled: true,
                                      ),
                                    ),
                                  ),
                                if (_currentPage == 1)
                                  const SizedBox(width: 10),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: AuthButton(
                                      onPressed: _nextPage,
                                      text:
                                          // _currentPage == 1 &&
                                          //         isCountryStepComplete
                                          //     ? t.getText('continue')
                                          t.getText('continue'),
                                      isEnabled:
                                          (_currentPage == 0 &&
                                          isLanguageStepComplete),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLanguageSelection(Apptheme theme, FFLocalizations t) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: languages.length,
      itemBuilder: (context, index) {
        final lang = languages[index];
        final isSelected = lang['code'] == selectedLanguage;
        return InkWell(
          onTap: () => saveLanguage(lang['code']!),
          child: _buildListItem(lang['name']!, isSelected, theme),
        );
      },
    );
  }

  // Widget _buildCountrySelection(Apptheme theme) {
  //   log("Building country selection with ${countries.length} countries");
  //   if (countries.isEmpty) {
  //     return const Center(child: Text('No countries available'));
  //   }
  //   return ListView.builder(
  //     padding: const EdgeInsets.all(8),
  //     itemCount: countries.length,
  //     itemBuilder: (context, index) {
  //       final country = countries[index];
  //       log("Country: ${country.name} (${country.code})");
  //       final isSelected = selectedCountry == country;
  //       return InkWell(
  //         onTap: () => saveCountry(country),
  //         child: Row(
  //           children: [
  //             CircleFlag(country.code, size: 30),
  //             const SizedBox(width: 12),
  //             Expanded(child: _buildListItem(country.name, isSelected, theme)),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget _buildListItem(String title, bool isSelected, Apptheme theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 4),

      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: theme.primaryText,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          AnimatedScale(
            scale: isSelected ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.elasticOut,
            child: Icon(Icons.check_circle, color: theme.primary, size: 24),
          ),
        ],
      ),
    );
  }
}
