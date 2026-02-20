import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  static const String _phoneVerifiedKey = 'phone_verified';
  static const String _phoneNumberKey = 'phone_number';
  static const String _userUidKey = 'user_uid';
  static const String _userRoleKey = 'user_role';

  bool _isLoading = true;
  bool _isPhoneVerified = false;
  String? _phoneNumber;
  String? _cachedUid;
  String? _role;

  bool get isLoading => _isLoading;
  bool get isPhoneVerified => _isPhoneVerified;
  String? get phoneNumber => _phoneNumber;
  String? get role => _role;

  bool get isAuthorized => _role == 'user';

  Future<void> checkUserStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      // User not logged in, clear cache and show splash
      await _clearCache();
      _isLoading = false;
      notifyListeners();
      return;
    }

    final currentUid = currentUser.uid;
    final prefs = await SharedPreferences.getInstance();
    final cachedUid = prefs.getString(_userUidKey);
    final cachedPhoneVerified = prefs.getBool(_phoneVerifiedKey) ?? false;
    final cachedPhoneNumber = prefs.getString(_phoneNumberKey);
    final cachedRole = prefs.getString(_userRoleKey);

    // If same user and phone is verified in cache, use cached data
    if (cachedUid == currentUid &&
        cachedPhoneVerified &&
        cachedPhoneNumber != null &&
        cachedRole != null) {
      _isPhoneVerified = true;
      _phoneNumber = cachedPhoneNumber;
      _role = cachedRole;
      _cachedUid = currentUid;
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Otherwise, fetch from Firebase and update cache
    await _fetchAndCacheUserData(currentUid);
  }

  Future<void> _fetchAndCacheUserData(String uid) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      final data = userDoc.data();
      if (data != null) {
        _phoneNumber = data['phoneNumber'];
        _isPhoneVerified = data['isPhoneVerified'] == true;
        _role = data['role'];
        _cachedUid = uid;

        // Cache the data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userUidKey, uid);
        await prefs.setBool(_phoneVerifiedKey, _isPhoneVerified);
        if (_phoneNumber != null) {
          await prefs.setString(_phoneNumberKey, _phoneNumber!);
        }
        if (_role != null) {
          await prefs.setString(_userRoleKey, _role!);
        }
      } else {
        // User document doesn't exist
        _isPhoneVerified = false;
        _phoneNumber = null;
        _role = null;
      }
    } catch (e) {
      // Error fetching data, fall back to cached data or default
      log('Error fetching user data: $e');
      _isPhoneVerified = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Call this method when user signs out
  Future<bool> clearUserCache() async {
    final success = await _clearCache();
    _isPhoneVerified = false;
    _phoneNumber = null;
    _role = null;
    _cachedUid = null;
    _isLoading = true; // Set loading to true when clearing cache
    notifyListeners();
    return success;
  }

  Future<bool> _clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_phoneVerifiedKey);
    await prefs.remove(_phoneNumberKey);
    await prefs.remove(_userUidKey);
    await prefs.remove(_userRoleKey);
    return true;
  }

  // Call this when phone verification status changes
  Future<void> updatePhoneVerificationStatus(
    bool isVerified,
    String? phoneNumber,
  ) async {
    _isPhoneVerified = isVerified;
    _phoneNumber = phoneNumber;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_phoneVerifiedKey, isVerified);
    if (phoneNumber != null) {
      await prefs.setString(_phoneNumberKey, phoneNumber);
    }

    notifyListeners();
  }

  // Force refresh from Firebase (useful for manual refresh)
  Future<void> refreshUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _isLoading = true;
      notifyListeners();
      await _fetchAndCacheUserData(currentUser.uid);
    }
  }
}
