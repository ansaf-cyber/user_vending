import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:universal_io/io.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:user/globalwidgets/custom_components.dart';
import 'package:user/globalwidgets/snackbars/custom_snackbar.dart';
import 'package:user/localization/localisation.dart';
import 'package:user/providers/language_provider.dart';
import 'package:user/providers/user_provider.dart';
import 'package:user/screens/settings/dialog/about_us_dialog.dart';
import 'package:user/screens/settings/screen/account_info_screen.dart';
import 'package:user/screens/settings/screen/change_email_screen.dart';
import 'package:user/screens/settings/screen/change_password_screen.dart';
import 'package:user/screens/settings/screen/language_picker_screen.dart';
import 'package:user/screens/signin_page/provider/auth_provider.dart';
import 'package:user/screens/signin_page/screen/auth_screen.dart';
import 'package:user/theme/apptheme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Modified to take isoCode as a parameter
  Future<String> getLocalizedCountryName(
    BuildContext context,
    String isoCode,
  ) async {
    final langCode = Provider.of<LanguageProvider>(
      context,
      listen: false,
    ).locale.languageCode;

    try {
      // Fetch the document from Firestore
      final docSnapshot = await FirebaseFirestore.instance
          .collection('targetedCountries')
          .doc('default')
          .get();

      if (!docSnapshot.exists || docSnapshot.data() == null) {
        return _getFallbackCountryName(isoCode, langCode);
      }

      final data = docSnapshot.data()!;
      if (!data.containsKey('countries')) {
        return _getFallbackCountryName(isoCode, langCode);
      }

      final countries = data['countries'] as Map<String, dynamic>;
      if (!countries.containsKey(isoCode.toLowerCase())) {
        return _getFallbackCountryName(isoCode, langCode);
      }

      final localizedData =
          countries[isoCode.toLowerCase()] as Map<String, dynamic>?;
      if (localizedData == null || !localizedData.containsKey(langCode)) {
        return _getFallbackCountryName(isoCode, langCode);
      }

      final countryName = localizedData[langCode] as String;

      return countryName;
    } catch (e) {
      return _getFallbackCountryName(isoCode, langCode);
    }
  }

  // Helper function to provide fallback country names
  String _getFallbackCountryName(String isoCode, String langCode) {
    const fallbackNames = {
      'bh': {'en': 'Bahrain', 'ar': 'البحرين'},
      'kw': {'en': 'Kuwait', 'ar': 'الكويت'},
      'om': {'en': 'Oman', 'ar': 'عُمان'},
      'qa': {'en': 'Qatar', 'ar': 'قطر'},
      'sa': {'en': 'Saudi Arabia', 'ar': 'المملكة العربية السعودية'},
      'ae': {'en': 'United Arab Emirates', 'ar': 'الإمارات العربية المتحدة'},
    };

    final country = fallbackNames[isoCode.toLowerCase()];
    if (country == null) {
      log('No fallback name for country code $isoCode, using default.');
      return langCode == 'ar' ? 'الكويت' : 'Kuwait';
    }

    final name = country[langCode] ?? country['en'] ?? 'Kuwait';
    log("Using fallback country name: $name");
    return name;
  }

  String _appVersion = '';
  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = info.version;
        log("app version $_appVersion");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isSocialUser =
        user?.providerData.any(
          (p) =>
              p.providerId == 'google.com' ||
              p.providerId == 'apple.com' ||
              p.providerId == 'facebook.com',
        ) ??
        false;

    final languageProvider = Provider.of<LanguageProvider>(context);
    final languageText = languageProvider.languageCode == 'ar'
        ? 'العربية'
        : 'English';

    return Scaffold(
      backgroundColor: Apptheme.of(context).primaryBackground,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 10),
            HeaderWithIcon(
              iconFirst: true,
              needtoShow: false,
              title: FFLocalizations.of(context).getText('profile'),
              leading: const SizedBox(),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    title: Text(
                      FFLocalizations.of(context).getText('accountInfo'),
                      style: TextStyle(
                        color: Apptheme.of(context).primaryText,
                        fontSize: 16,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AccountInfoScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),

                  const Divider(height: 1),
                  if (!isSocialUser) ...[
                    ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      title: Text(
                        FFLocalizations.of(context).getText('changeEmail'),
                        style: TextStyle(
                          color: Apptheme.of(context).primaryText,
                          fontSize: 16,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChangeEmailScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      title: Text(
                        FFLocalizations.of(context).getText('changePassword'),
                        style: TextStyle(
                          color: Apptheme.of(context).primaryText,
                          fontSize: 16,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChangePasswordScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                  ],
                  // Notifications

                  // Language
                  ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    title: Text(
                      FFLocalizations.of(context).getText('language'),
                      style: TextStyle(
                        color: Apptheme.of(context).primaryText,
                        fontSize: 16,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          languageText,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                            decorationThickness: 2,
                            decorationColor: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LanguageSelectionScreen(),
                        ),
                      );
                    },
                  ),
                  // const Divider(height: 1),
                  // // Country
                  // StreamBuilder<DocumentSnapshot>(
                  //   stream:
                  //       customFirestore
                  //           .collection('users')
                  //           .doc(user?.uid)
                  //           .snapshots(),
                  //   builder: (context, snapshot) {
                  //     if (snapshot.connectionState == ConnectionState.waiting) {
                  //       return const ListTile(
                  //         dense: true,
                  //         contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  //         title: Text('Loading...'),
                  //       );
                  //     }
                  //     if (snapshot.hasError) {
                  //       log("Error fetching country: ${snapshot.error}");
                  //       return const ListTile(
                  //         dense: true,
                  //         contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  //         title: Text('Error'),
                  //       );
                  //     }
                  //     if (!snapshot.hasData || !snapshot.data!.exists) {
                  //       return ListTile(
                  //         dense: true,
                  //         contentPadding: const EdgeInsets.symmetric(
                  //           horizontal: 10,
                  //         ),
                  //         title: Text(
                  //           FFLocalizations.of(context).getText('country'),
                  //           style: TextStyle(
                  //             color: Apptheme.of(context).primaryText,
                  //             fontSize: 16,
                  //           ),
                  //         ),
                  //         trailing: FutureBuilder<String>(
                  //           future: getLocalizedCountryName(context, 'kw'),
                  //           builder: (context, futureSnapshot) {
                  //             final countryName =
                  //                 futureSnapshot.data ?? 'Kuwait';
                  //             return Row(
                  //               mainAxisSize: MainAxisSize.min,
                  //               children: [
                  //                 Text(
                  //                   countryName,
                  //                   style: const TextStyle(
                  //                     color: Colors.grey,
                  //                     fontSize: 16,
                  //                     decoration: TextDecoration.underline,
                  //                     decorationThickness: 2,
                  //                     decorationColor: Colors.grey,
                  //                   ),
                  //                 ),
                  //                 const SizedBox(width: 8),
                  //                 const Icon(Icons.arrow_forward_ios, size: 16),
                  //               ],
                  //             );
                  //           },
                  //         ),
                  //         onTap: () async {
                  //           await Navigator.push(
                  //             context,
                  //             MaterialPageRoute(
                  //               builder:
                  //                   (context) =>
                  //                       const CountryDeliverListScreen(),
                  //             ),
                  //           );
                  //         },
                  //       );
                  //     }

                  //     final data =
                  //         snapshot.data!.data() as Map<String, dynamic>?;
                  //     final isoCode =
                  //         data?['country_code']?.toString().toLowerCase() ??
                  //         'kw';

                  //     return ListTile(
                  //       dense: true,
                  //       contentPadding: const EdgeInsets.symmetric(
                  //         horizontal: 10,
                  //       ),
                  //       title: Text(
                  //         FFLocalizations.of(context).getText('country'),
                  //         style: TextStyle(
                  //           color: Apptheme.of(context).primaryText,
                  //           fontSize: 16,
                  //         ),
                  //       ),
                  //       trailing: FutureBuilder<String>(
                  //         future: getLocalizedCountryName(context, isoCode),
                  //         builder: (context, futureSnapshot) {
                  //           final countryName = futureSnapshot.data ?? 'Kuwait';
                  //           return Row(
                  //             mainAxisSize: MainAxisSize.min,
                  //             children: [
                  //               Text(
                  //                 countryName,
                  //                 style: const TextStyle(
                  //                   color: Colors.grey,
                  //                   fontSize: 14,
                  //                   decoration: TextDecoration.underline,
                  //                   decorationThickness: 2,
                  //                   decorationColor: Colors.grey,
                  //                 ),
                  //               ),
                  //               const SizedBox(width: 8),
                  //               const Icon(Icons.arrow_forward_ios, size: 16),
                  //             ],
                  //           );
                  //         },
                  //       ),
                  //       onTap: () async {
                  //         await Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //             builder:
                  //                 (context) => const CountryDeliverListScreen(),
                  //           ),
                  //         );
                  //       },
                  //     );
                  //   },
                  // ),
                  const Divider(height: 1),
                  ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    title: Text(
                      FFLocalizations.of(context).getText('aboutUs'),
                      style: TextStyle(
                        color: Apptheme.of(context).primaryText,
                        fontSize: 16,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      showAboutUsDialog(context, _appVersion);
                    },
                  ),

                  const Divider(height: 1),

                  // ...
                  // ListTile(
                  //   dense: true,
                  //   contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  //   title: Text(
                  //     FFLocalizations.of(context).getText('support'),
                  //     style: TextStyle(
                  //       color: Apptheme.of(context).primaryText,
                  //       fontSize: 16,
                  //     ),
                  //   ),
                  //   trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  //   onTap: () async {
                  //     final Uri url = Uri.parse('https://support.dcab.com');
                  //     if (await canLaunchUrl(url)) {
                  //       await launchUrl(
                  //         url,
                  //         mode: LaunchMode.externalApplication,
                  //       );
                  //     } else {
                  //       // Optionally show error if URL can't be launched
                  //       // ignore: use_build_context_synchronously
                  //       ScaffoldMessenger.of(context).showSnackBar(
                  //         const SnackBar(
                  //           content: Text('Could not launch support'),
                  //         ),
                  //       );
                  //     }
                  //   },
                  // ),
                  if (Platform.isIOS) ...[
                    const Divider(height: 1),

                    // ...
                    ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      title: Text(
                        FFLocalizations.of(context).getText('termsOfUse'),
                        style: TextStyle(
                          color: Apptheme.of(context).primaryText,
                          fontSize: 16,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () async {
                        final Uri url = Uri.parse('https://www.dcab.com/terms');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          // Optionally show error if URL can't be launched
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Could not launch support'),
                            ),
                          );
                        }
                      },
                    ),
                  ],

                  const Divider(height: 1),

                  // ...
                  ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    title: Text(
                      FFLocalizations.of(context).getText('privacyPolicy'),
                      style: TextStyle(
                        color: Apptheme.of(context).primaryText,
                        fontSize: 16,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      final Uri url = Uri.parse('https://www.dcab.com/privacy');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        // Optionally show error if URL can't be launched
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Could not launch the privacy policy.',
                            ),
                          ),
                        );
                      }
                    },
                  ),

                  const Divider(height: 1),
                  // Logout
                  Consumer2<SignInProvider, UserProvider>(
                    builder: (context, signinprovider, userprovider, child) {
                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        title: Text(
                          FFLocalizations.of(context).getText('logout'),
                          style: TextStyle(
                            color: Apptheme.of(context).primaryText,
                            fontSize: 16,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () async {
                          FocusScope.of(context).unfocus();
                          final t = FFLocalizations.of(context);

                          final shouldLogout = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(t.getText('logout')),
                              content: Text(t.getText('logoutConfirmation')),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text(
                                    t.getText('cancel'),
                                    style: TextStyle(
                                      color: Apptheme.of(context).primaryText,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: Text(
                                    t.getText('confirm'),
                                    style: TextStyle(
                                      color: Apptheme.of(
                                        context,
                                      ).primaryBackground,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (shouldLogout == true && context.mounted) {
                            try {
                              await signinprovider.signOut();

                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AuthScreen(),
                                ),
                                (Route<dynamic> route) => false,
                              );
                            } catch (e) {
                              log(e.toString());
                              showCustomSnackbar(
                                type: SnackbarType.error,
                                context: context,
                                message: 'Logout Error',
                              );
                            }
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
