import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:user/globalwidgets/snackbars/custom_snackbar.dart';

import 'package:user/localization/localisation.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:user/screens/home/home_screen.dart';

class SignInProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _loading = false;
  bool _googleLoading = false;
  bool _faceBookLoading = false;
  bool _appleLoading = false;

  bool get loading => _loading;
  bool get googleLoading => _googleLoading;
  bool get faceBookLoading => _faceBookLoading;
  bool get appleLoading => _appleLoading;
  bool _forgotLoading = false;

  bool get forgotLoading => _forgotLoading;

  void _setforgetLOading(bool value) {
    _forgotLoading = value;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<bool> signIn(
    BuildContext context,
    String email,
    String password,
  ) async {
    _setLoading(true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      await _storeUserFcmToken(_auth.currentUser!);
      if (context.mounted) {
        await saveUserCountryCode(_auth.currentUser!);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
      return true;
    } on FirebaseAuthException catch (e) {
      log('FirebaseAuthException during sign-in: ${e.code}');
      if (context.mounted) {
        String message;
        switch (e.code) {
          case 'user-not-found':
            message = 'noUserWithEmail';
            break;
          case 'wrong-password':
            message = 'incorrectPassword';
            break;
          case 'invalid-email':
            message = 'invalidEmail';
            break;
          case 'user-disabled':
            message = 'userDisabled';
            break;
          default:
            message = 'signInFailed';
        }
        showCustomSnackbar(
          context: context,
          type: SnackbarType.error,
          message: FFLocalizations.of(context).getText(message),
        );
      }
      return false;
    } catch (e) {
      log('Unexpected error during sign-in: $e');
      if (context.mounted) {
        showCustomSnackbar(
          context: context,
          type: SnackbarType.error,
          message:
              '${FFLocalizations.of(context).getText("signInFailed")} ${e.toString()}',
        );
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(BuildContext context, String email) async {
    _setforgetLOading(true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      return true;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'emailInvalid';
          break;
        case 'user-not-found':
          errorMessage = 'noUserWithEmail';
          break;
        default:
          errorMessage = 'unexpectedError';
      }
      if (context.mounted) {
        showCustomSnackbar(
          context: context,
          type: SnackbarType.error,
          message: FFLocalizations.of(context).getText(errorMessage),
        );
      }
      return false;
    } finally {
      _setforgetLOading(false);
    }
  }

  Future<bool> signUp(
    BuildContext context,
    String email,
    String password, {
    String? name,
  }) async {
    _setLoading(true);
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      log("user created successfully");
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'uid': userCredential.user!.uid,
            'display_name': name ?? email.split('@')[0],
            'photo_url': '',
            'created_time': FieldValue.serverTimestamp(),
            'email': userCredential.user!.email,
            'role': 'user',
            "customLinksUsed": 0,
            "randomLinksUsed": 0,
            "addressesUsed": 0,
          });

      //   await getuserCountryCode(context, userCredential.user!);
      //Purchases.logIn(userCredential.user!.uid);
      // await _storeUserFcmToken(userCredential.user!);

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
      return true;
    } on FirebaseAuthException catch (e) {
      log('FirebaseAuthException: ${e.code}');
      if (context.mounted) {
        String message;
        switch (e.code) {
          case 'email-already-in-use':
            message = 'emailInUse';
            break;
          case 'invalid-email':
            message = 'invalidEmail';
            break;
          case 'weak-password':
            message = 'The password is too weak.';
            break;
          default:
            message =
                '${FFLocalizations.of(context).getText("")}: ${e.message ?? 'Unknown error.'}';
        }
        showCustomSnackbar(
          context: context,
          type: SnackbarType.error,
          message: FFLocalizations.of(context).getText(message),
        );
      }
      return false;
    } catch (e) {
      log('Unexpected error during sign-up: $e');
      if (context.mounted) {
        showCustomSnackbar(
          context: context,
          type: SnackbarType.error,
          message:
              '${FFLocalizations.of(context).getText("signUpFailed")}: ${e.toString()}',
        );
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    _googleLoading = true;
    notifyListeners();
    try {
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        _googleLoading = false;
        notifyListeners();
        return;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);

      final user = userCredential.user;

      await saveUserCountryCode(_auth.currentUser!);
      // Purchases.logIn(userCredential.user!.uid);
      if (user == null) {
        _googleLoading = false;
        notifyListeners();
        return;
      }
      final fullName = user.displayName ?? '';
      final nameParts = fullName.trim().split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : '';
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'display_name': firstName,
        'last_name': lastName,
        'email': user.email,
        'photo_url': user.photoURL,
        'created_time': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // await getuserCountryCode(context, user);
      //  await _storeUserFcmToken(user);

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      log('Error during Google sign-in: $e');
      if (context.mounted) {
        showCustomSnackbar(
          context: context,
          type: SnackbarType.error,
          message:
              '${FFLocalizations.of(context).getText("googleSignInFailed")} ${e.toString()}',
        );
      }
    } finally {
      _googleLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      // CacheClearService.clearFlutterCache(
      //   clearAppDirectories: true,
      //   clearSharedPreferences: true,
      // );
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // 1. Delete FCM token
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'fcmToken': FieldValue.delete()});

        // 2. Sign out based on provider
        for (final providerProfile in user.providerData) {
          switch (providerProfile.providerId) {
            case 'google.com':
              await GoogleSignIn().disconnect();
              await GoogleSignIn().signOut();
              break;
            case 'apple.com':
              // no explicit “AppleSignIn().signOut()” required
              // (Apple doesn't provide a proper SDK-side signout)
              break;
            // add more providers here if needed
          }
        }

        // 3. Firebase sign out (must always be called last)

        await FirebaseAuth.instance.signOut();
      }
    } catch (e) {
      log('Error signing out: $e');
    }
  }

  Future<void> saveUserCountryCode(User user) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      String countryCode = 'kw'; // default fallback

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final fetchedCode = data['country_code']?.toString();

        if (fetchedCode != null && fetchedCode.isNotEmpty) {
          countryCode = fetchedCode.toLowerCase();
          log(
            'Fetched country code $countryCode from Firestore for user ${user.uid}',
          );
        } else {
          log(
            'No country code found in Firestore for user ${user.uid}, using default "kw"',
          );
        }
      } else {
        log('User document not found for ${user.uid}, using default "kw"');
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedDeliveringCountry', countryCode);

      log(
        'Country code $countryCode saved to SharedPreferences for user ${user.uid}',
      );
    } catch (e) {
      log('Error fetching/saving country code: $e');
    }
  }

  Future<void> _storeUserFcmToken(User user) async {
    try {
      log("storing token");
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'fcmToken': token,
        }, SetOptions(merge: true));

        // Listen for token refresh
        FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'fcmToken': newToken});
        });
      }
    } catch (e) {
      log('Error storing FCM token: $e');
    }
  }
}
