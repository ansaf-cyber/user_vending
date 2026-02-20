import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:geolocator/geolocator.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user/firebase_options.dart';
import 'package:user/localization/localisation.dart';
import 'package:user/providers/init_provider.dart';
import 'dart:developer';

import 'package:user/providers/language_provider.dart';
import 'package:user/providers/machine_map_provider.dart';
import 'package:user/providers/user_provider.dart';
import 'package:user/screens/home/home_screen.dart';
import 'package:user/screens/otp_screen/provider/otp_service_provider.dart';
import 'package:user/screens/signin_page/provider/auth_provider.dart';
import 'package:user/screens/signin_page/screen/auth_screen.dart';
import 'package:user/theme/apptheme.dart';
import 'package:user/providers/user_products_provider.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:user/providers/navigation_provider.dart';

late final bool isAndroid;
late final String serverVersion;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await handleLocationPermission();

    final prefs = await SharedPreferences.getInstance();

    // ServerVersionService().initialize();

    // // Anywhere in your app:
    // log('Server version: ${ServerVersionService().serverVersion}');

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SignInProvider()),

          ChangeNotifierProvider(create: (_) => InitilisationProvider()),
          ChangeNotifierProvider(create: (_) => OTPVerificationProvider()),
          ChangeNotifierProvider(create: (_) => LanguageProvider(prefs)),
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => NavigationProvider()),
          ChangeNotifierProvider(create: (_) => UserProductsProvider()),
          ChangeNotifierProvider(create: (_) => MachineMapProvider()),
        ],
        child: const MyApp(),
      ),
    );

    // 🔐 Initialize Firestore with custom DB only once

    await Apptheme.initialize();
  } catch (e) {
    runApp(ErrorFallbackApp(error: e.toString()));
  }
}

class ErrorFallbackApp extends StatelessWidget {
  final String error;
  const ErrorFallbackApp({required this.error, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red.shade50,
        body: Center(
          child: Text(
            "App failed to start:\n$error",
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    // Handle notification launch after loading is complete

    return MaterialApp(
      navigatorKey: navigatorKey,
      localizationsDelegates: const [
        FFLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ar')],
      locale: languageProvider.locale,
      debugShowCheckedModeBanner: false,
      title: 'Login App',
      themeMode: ThemeMode.light,
      theme: buildAppTheme(LightModeTheme()),
      darkTheme: buildAppTheme(DarkModeTheme()),
      home: const CustomSplashScreen(),
    );
  }
}

Future<void> handleLocationPermission() async {
  try {
    LocationPermission permission;

    final isLocationServiceEnabled =
        await Geolocator.isLocationServiceEnabled();
    if (!isLocationServiceEnabled) {
      log('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        log('Location permission denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      log('Location permission permanently denied');
      return;
    }
  } catch (e) {
    log(e.toString());
  }

  log('Location permission granted');
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading only for the initial connection
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Apptheme.of(context).primaryBackground,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return const HomeWrapper();
        } else {
          return const StartupWrapper();
        }
      },
    );
  }
}

class CustomSplashScreen extends StatefulWidget {
  const CustomSplashScreen({super.key});

  @override
  State<CustomSplashScreen> createState() => _CustomSplashScreenState();
}

class _CustomSplashScreenState extends State<CustomSplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize app preferences
      await AppInitializer().initialize();

      // Add a minimum splash duration for better UX (optional)
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthGate()));
      }
    } catch (e) {
      log('Error during app initialization: $e');
      // Handle initialization error
      if (mounted) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthGate()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Apptheme.of(
        context,
      ).primaryBackground, // match native splash background
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Image.asset(
            'assets/images/mainLogoFull.png',
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class AppInitializer {
  static final AppInitializer _instance = AppInitializer._internal();
  factory AppInitializer() => _instance;
  AppInitializer._internal();

  bool _isInitialized = false;
  bool _hasCompletedOnboarding = false;
  SharedPreferences? _prefs;

  bool get isInitialized => _isInitialized;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  Future<void> initialize() async {
    try {
      if (_isInitialized) return;

      _prefs = await SharedPreferences.getInstance();
      final language = _prefs?.getString('selectedLanguage') ?? 'en';
      final country = _prefs?.getString('selectedDeliveringCountry');

      log('country ${country.toString()}');
      log('language${language.toString()}');

      _hasCompletedOnboarding = language != null && country != null;
      _isInitialized = true;
      log(" ${_hasCompletedOnboarding.toString()}");
    } catch (e) {
      log(e.toString());
    }
  }
}
