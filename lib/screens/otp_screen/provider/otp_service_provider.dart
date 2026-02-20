import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user/globalwidgets/snackbars/custom_snackbar.dart';
import 'package:user/localization/localisation.dart';
import 'package:user/screens/home/home_screen.dart';

class OTPVerificationProvider extends ChangeNotifier {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;
  bool isScreenLoading = false;
  String sentNumber = '';
  String sentDial = '';
  String sendCountrycode = '';
  bool otpSent = false;
  String verificationSid = '';
  String selectedMethod = 'SMS';
  bool showMethodSelection = false;

  // Resend delay variables
  Timer? _resendTimer;
  int _resendCountdown = 0;
  bool _canResend = true;
  int _currentResendAttempt = 0;
  DateTime? _lastSendTime;
  bool _isFirstSend = true;

  // Initialize Cloud Functions instance with Europe West 1 region
  late FirebaseFunctions functions;

  OTPVerificationProvider() {
    functions = FirebaseFunctions.instanceFor(region: 'me-central1');
    _loadResendDataFromFirebase();
  }

  void changeMethod(bool val) {
    showMethodSelection = val;
    notifyListeners();
  }

  void setMethod(String value) {
    selectedMethod = value;
    notifyListeners();
  }

  Future<void> _loadResendDataFromFirebase() async {
    try {
      isScreenLoading = true;
      notifyListeners();
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        final otpData = data['otpResendData'] as Map<String, dynamic>?;

        if (otpData != null) {
          _currentResendAttempt = otpData['resendAttempt'] ?? 0;
          final firebaseLastSend = otpData['lastSendTime'] as Timestamp?;
          _isFirstSend = otpData['isFirstSend'] ?? true;

          if (firebaseLastSend != null) {
            _lastSendTime = firebaseLastSend.toDate();
            _checkResendCooldown();
          }
        } else {
          // No OTP data exists, reset to initial state
          _resetToInitialState();
        }
      } else {
        _resetToInitialState();
      }
    } catch (e) {
      log('Error loading resend data from Firebase: $e');
      _resetToInitialState();
    }
    isScreenLoading = false;
    notifyListeners();
  }

  void _resetToInitialState() {
    _currentResendAttempt = 0;
    _lastSendTime = null;
    isScreenLoading = false;
    _canResend = true;
    _resendCountdown = 0;
    _isFirstSend = true;
    _resendTimer?.cancel();
  }

  void _checkResendCooldown() {
    if (_lastSendTime == null) return;

    final now = DateTime.now();
    final timeDifference = now.difference(_lastSendTime!);
    int requiredWaitTime = _getWaitTimeForAttempt(_currentResendAttempt);

    if (timeDifference.inSeconds < requiredWaitTime) {
      _canResend = false;
      _resendCountdown = requiredWaitTime - timeDifference.inSeconds;
      _startCountdownTimer();
    } else {
      _canResend = true;
      _resendCountdown = 0;
    }
  }

  int _getWaitTimeForAttempt(int attempt) {
    switch (attempt) {
      case 0:
        return 60; // 1 minute after first send
      case 1:
        return 300; // 5 minutes after first resend
      default:
        return 86400; // 24 hours after second resend
    }
  }

  void _startCountdownTimer() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        _resendCountdown--;
      } else {
        _canResend = true;
        timer.cancel();
      }
      notifyListeners();
    });
  }

  String formatCountdown(int seconds) {
    if (seconds >= 86400) {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      return '${hours}h ${minutes}m';
    } else if (seconds >= 3600) {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      return '${hours}h ${minutes}m';
    } else if (seconds >= 60) {
      final minutes = seconds ~/ 60;
      final secs = seconds % 60;
      return '${minutes}m ${secs}s';
    } else {
      return '${seconds}s';
    }
  }

  Future<void> _updateSendDataInFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final now = DateTime.now();

      // If this is the first send, mark it as no longer first and don't increment attempt
      if (_isFirstSend) {
        _isFirstSend = false;
        _lastSendTime = now;

        // Start countdown immediately after first send
        final waitTime = _getWaitTimeForAttempt(
          _currentResendAttempt,
        ); // This will be 60 seconds
        _canResend = false;
        _resendCountdown = waitTime;
        _startCountdownTimer();
      } else {
        // This is a resend, increment attempt counter
        _currentResendAttempt++;
        _lastSendTime = now;

        final waitTime = _getWaitTimeForAttempt(_currentResendAttempt);
        if (waitTime > 0) {
          _canResend = false;
          _resendCountdown = waitTime;
          _startCountdownTimer();
        }
      }

      // Update Firebase only
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'otpResendData': {
          'resendAttempt': _currentResendAttempt,
          'lastSendTime': Timestamp.fromDate(now),
          'isFirstSend': _isFirstSend,
          'phoneNumber': phoneController.text,
          'updatedAt': Timestamp.fromDate(now),
        },
      }, SetOptions(merge: true));
    } catch (e) {
      log('Error updating send data in Firebase: $e');
    }
    notifyListeners();
  }

  Future<void> resetResendData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      _resetToInitialState();

      // Remove OTP data from Firebase
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'otpResendData': FieldValue.delete()},
      );
    } catch (e) {
      log('Error resetting resend data: $e');
    }
    notifyListeners();
  }

  String getCooldownMessage(BuildContext context) {
    if (!_canResend && _resendCountdown > 0) {
      return 'Please wait ${formatCountdown(_resendCountdown)} before resending OTP';
    }
    return '';
  }

  Future<void> sendOTP(
    String dialCode,
    String countryCode,
    BuildContext context,
  ) async {
    if (phoneController.text.isEmpty) {
      _showError(
        FFLocalizations.of(context).getText('enterPhoneNumber'),
        context,
      );
      return;
    }

    // Check cooldown before sending
    if (!_canResend && _resendCountdown > 0) {
      _showError(getCooldownMessage(context), context);
      return;
    }

    isLoading = true;
    sentNumber = phoneController.text;
    sentDial = dialCode;
    sendCountrycode = countryCode;
    notifyListeners();

    try {
      final HttpsCallable callable = functions.httpsCallable('sendOTP');
      final result = await callable.call({
        'phoneNumber': phoneController.text,
        'dialCode': dialCode,
        'method': selectedMethod,
      });

      final data = result.data;

      if (data['success'] == true) {
        // Update send data after successful OTP send
        await _updateSendDataInFirebase();

        verificationSid = data['verificationSid'] ?? '';
        otpSent = true;
        isLoading = false;
        showMethodSelection = false;
        if (context.mounted) {
          _showSuccess(
            FFLocalizations.of(context).getText('otpSentSuccess'),
            context,
          );
        }
      } else {
        throw Exception(data['message'] ?? 'Failed to send OTP');
      }
    } on FirebaseFunctionsException catch (e) {
      log('Firebase Functions Exception: ${e.code} - ${e.message}');
      isLoading = false;
      String errorMessage;
      switch (e.code) {
        case 'already-exists':
          errorMessage = e.message?.contains('same as before') == true
              ? FFLocalizations.of(context).getText('phoneSameAsBefore')
              : FFLocalizations.of(context).getText('phoneNumberAlreadyLinked');
          break;
        case 'failed-precondition':
          errorMessage = FFLocalizations.of(
            context,
          ).getText('phoneChangeLimitExceeded');
          break;
        case 'unauthenticated':
          errorMessage = 'Authentication required. Please log in again.';
          break;
        case 'invalid-argument':
          errorMessage = FFLocalizations.of(
            context,
          ).getText('enterPhoneNumber');
          break;
        default:
          errorMessage = FFLocalizations.of(context)
              .getText('sendOtpFailed')
              .replaceAll('{error}', e.message ?? 'Unknown error');
      }
      if (context.mounted) {
        _showError(errorMessage, context);
      }
    } catch (e) {
      log('Error sending OTP: $e');
      isLoading = false;
      final errorMessage = FFLocalizations.of(
        context,
      ).getText('sendOtpFailed').replaceAll('{error}', e.toString());
      if (context.mounted) {
        _showError(errorMessage, context);
      }
    }
    notifyListeners();
  }

  Future<void> verifyOTP(
    String dialCode,
    String countryCode,
    BuildContext context,
  ) async {
    if (otpController.text.isEmpty) {
      _showError(FFLocalizations.of(context).getText('enterOtp'), context);
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final HttpsCallable callable = functions.httpsCallable('verifyOTP');
      final result = await callable.call({
        'phoneNumber': phoneController.text,
        'dialCode': dialCode,
        'otpCode': otpController.text,
        'countryCode': countryCode,
      });

      final data = result.data;

      if (data['success'] == true) {
        await resetResendData();
        final message = FFLocalizations.of(
          context,
        ).getText('otpVerifiedSuccess');
        _showSuccess(message, context);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('selectedDeliveringCountry', countryCode);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        throw Exception(data['message'] ?? 'Failed to verify OTP');
      }
    } on FirebaseFunctionsException catch (e) {
      log('Firebase Functions Exception: ${e.code} - ${e.message}');
      String errorMessage;
      switch (e.code) {
        case 'invalid-argument':
          errorMessage = e.message?.contains('Invalid OTP') == true
              ? FFLocalizations.of(context).getText('invalidOtp')
              : FFLocalizations.of(context).getText('enterOtp');
          break;
        case 'not-found':
          errorMessage = FFLocalizations.of(context).getText('invalidOtp');
          break;
        case 'unauthenticated':
          errorMessage = 'Authentication required. Please log in again.';
          break;
        default:
          errorMessage = FFLocalizations.of(context)
              .getText('verifyOtpFailed')
              .replaceAll('{error}', e.message ?? 'Unknown error');
      }
      _showError(errorMessage, context);
    } catch (e) {
      log('Error verifying OTP: $e');
      final errorMessage = FFLocalizations.of(
        context,
      ).getText('verifyOtpFailed').replaceAll('{error}', e.toString());
      _showError(errorMessage, context);
    }

    isLoading = false;
    notifyListeners();
  }

  void _showError(String message, BuildContext context) {
    showCustomSnackbar(
      context: context,
      type: SnackbarType.error,
      message: message,
    );
  }

  void _showSuccess(String message, BuildContext context) {
    showCustomSnackbar(
      context: context,
      type: SnackbarType.success,
      message: message,
    );
  }

  bool get canResend => _canResend;
  int get resendCountdown => _resendCountdown;
  int get currentResendAttempt => _currentResendAttempt;
  bool get isFirstSend => _isFirstSend;

  @override
  void dispose() {
    phoneController.dispose();
    otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }
}
