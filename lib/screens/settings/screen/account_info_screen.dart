import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart' as dateformatr;

import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:user/globalwidgets/custom_components.dart';
import 'package:user/globalwidgets/snackbars/custom_snackbar.dart';
import 'package:user/localization/localisation.dart';
import 'package:user/screens/otp_screen/screen/otp_screen.dart';
import 'package:user/screens/signin_page/screen/auth_screen.dart';
import 'package:user/theme/apptheme.dart';

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _phoneControler = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  String? gender;
  bool isLoading = true;
  bool isEditing = false;
  bool isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final data = doc.data() ?? {};
    _phoneControler.text = data['phoneNumber'] ?? '';
    _firstNameController.text = data['display_name'] ?? '';
    _emailController.text = data['email'] ?? '';
    _lastNameController.text = data['last_name'] ?? '';
    _dobController.text = data['dob'] ?? '';
    gender = data['gender'];

    setState(() {
      if (mounted) {
        isLoading = false;
      }
    });
  }

  Future<void> _selectDOB() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          DateTime.tryParse(
            _dobController.text.split('/').reversed.join('-'),
          ) ??
          DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _dobController.text = dateformatr.DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  Future<void> _changePhone() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OTPVerificationScreen(changePhone: true),
      ),
    );
  }

  Future<void> _saveChanges() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'display_name': _firstNameController.text,
      'last_name': _lastNameController.text,
      'dob': _dobController.text,
      'gender': gender,
    });

    setState(() {
      if (mounted) {
        isEditing = false;
      }
    });
    if (context.mounted) {
      showCustomSnackbar(
        context: context,
        type: SnackbarType.success,
        message: FFLocalizations.of(context).getText("profileUpdated"),
      );
    }
  }

  Future<void> confirmDeleteAccount(BuildContext context) async {
    final t = FFLocalizations.of(context); // Localization support

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          t.getText('deleteAccount'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          t.getText('deleteAccountConfirmation'),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              t.getText('cancel'),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              t.getText('confirm'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await deleteAccount(context);
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    try {
      setState(() {
        isDeleting = true;
      });

      // CacheClearService.clearFlutterCache(
      //   clearAppDirectories: true,
      //   clearSharedPreferences: true,
      // );

      final user = FirebaseAuth.instance.currentUser;
      final t = FFLocalizations.of(context);

      if (user == null) throw Exception("No user logged in");

      final providerId = user.providerData.first.providerId;
      AuthCredential? credential;

      // ... your existing reauthentication code ...
      if (providerId == 'password') {
        final email = user.email;
        if (email == null) throw Exception("No email found for user");

        final password = await promptPassword(context);
        if (password == null || password.isEmpty) return;

        credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
      } else if (providerId == 'google.com') {
        final googleUser = await GoogleSignIn().signIn();
        final googleAuth = await googleUser?.authentication;

        if (googleAuth == null)
          throw Exception("Failed to reauthenticate with Google");

        credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
      } else if (providerId == 'facebook.com') {
        throw UnimplementedError('Facebook reauth not implemented');
      } else if (providerId == 'apple.com') {
        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );

        credential = OAuthProvider("apple.com").credential(
          idToken: appleCredential.identityToken,
          accessToken: appleCredential.authorizationCode,
        );
      } else {
        throw Exception("Unsupported auth provider: $providerId");
      }

      // Reauthenticate with correct credentials
      await user.reauthenticateWithCredential(credential);

      // Finally delete the Firebase Auth user
      await user.delete();

      setState(() {
        isDeleting = false;
      });

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthScreen()),
          (route) => false,
        );

        showCustomSnackbar(
          context: context,
          type: SnackbarType.success,
          message: t.getText('accountDeleted'),
        );
      }
    } catch (e) {
      debugPrint("Account deletion error: $e");

      if (context.mounted) {
        final message = e is FirebaseAuthException
            ? e.message ?? 'Unknown error'
            : e.toString();

        showCustomSnackbar(
          context: context,
          type: SnackbarType.error,
          message: message,
        );
      }

      setState(() {
        isDeleting = false;
      });
    }
  }

  /// Delete customer document and ALL its subcollections

  /// Helper function to delete all documents in a subcollection

  Future<String?> promptPassword(BuildContext context) async {
    final controller = TextEditingController();
    final t = FFLocalizations.of(context);
    final theme = Apptheme.of(context);

    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.primaryBackground,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.lock_outline,
                      color: theme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.getText('reauthenticate'),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: theme.primaryText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          t.getText('enterPassword'),
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.primaryText.withOpacity(0.6),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Password Field
              TextField(
                controller: controller,
                obscureText: true,
                autofocus: true,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.primaryText,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: theme.primaryText.withOpacity(0.04),
                  hintText: t.getText('enterPassword'),
                  hintStyle: TextStyle(
                    color: theme.primaryText.withOpacity(0.4),
                    fontWeight: FontWeight.w400,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: theme.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        t.getText('cancel'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: theme.primaryText.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pop(context, controller.text.trim()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        t.getText('confirm'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Apptheme.of(context);
    final t = FFLocalizations.of(context);

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: theme.primaryBackground,

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: HeaderWithIcon(
                    trailing: AppButtonWithLabel(
                      onPressed: () async {
                        if (isEditing) {
                          await _saveChanges();
                        } else {
                          setState(() {
                            isEditing = !isEditing;
                          });
                        }
                      },
                      text: isEditing ? t.getText('save') : t.getText('edit'),
                    ),
                    leading: const CustomIcon(),
                    title: t.getText('accountInfo'),
                    iconFirst: true,
                    isSub: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            _buildEditableField(
              t.getText('email'),
              _emailController,
              readOnly: true,
            ),
            _buildEditableField(
              t.getText('firstName'),
              _firstNameController,
              readOnly: !isEditing,
            ),
            _buildEditableField(
              t.getText('lastName'),
              _lastNameController,
              readOnly: !isEditing,
            ),
            _buildEditableField(
              isPhone: true,
              t.getText('phoneNumber'),
              _phoneControler,
              onTap: isEditing ? _changePhone : null,
              readOnly: true,
            ),
            _buildEditableField(
              t.getText('dobOptional'),
              _dobController,
              readOnly: true,
              suffixIcon: isEditing
                  ? const Icon(Icons.calendar_today_outlined)
                  : null,
              onTap: isEditing ? _selectDOB : null,
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                t.getText('genderOptional'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            Row(
              children: [
                Radio<String>(
                  activeColor: theme.primaryText,
                  value: 'Male',
                  groupValue: gender,
                  onChanged: isEditing
                      ? (value) => setState(() => gender = value)
                      : null,
                ),
                Text(t.getText('male')),
                const SizedBox(width: 20),
                Radio<String>(
                  activeColor: theme.primaryText,
                  value: 'Female',
                  groupValue: gender,
                  onChanged: isEditing
                      ? (value) => setState(() => gender = value)
                      : null,
                ),
                Text(t.getText('female')),
              ],
            ),

            const SizedBox(height: 20),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                isDeleting ? null : confirmDeleteAccount(context);
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                side: BorderSide(color: theme.primaryText),
              ),
              child: isDeleting
                  ? const CircularProgressIndicator()
                  : Text(
                      t.getText('deleteAccount'),
                      style: TextStyle(color: theme.primaryText),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
    Widget? suffixIcon,
    VoidCallback? onTap,
    bool isPhone = false,
  }) {
    log(controller.text);
    final theme = Apptheme.of(context);
    final bool isFieldEnabled = isEditing || readOnly == false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        textDirection: isPhone ? TextDirection.ltr : Directionality.of(context),
        textAlign: isPhone && Directionality.of(context) == TextDirection.rtl
            ? TextAlign.right
            : TextAlign.start,
        onTapOutside: (event) {
          FocusScope.of(context).unfocus();
        },
        controller: controller,
        enabled: isFieldEnabled,
        readOnly: readOnly || !isEditing,
        onTap: isFieldEnabled ? onTap : null,
        style: TextStyle(
          color: isEditing
              ? theme.primaryText
              : theme.primaryText.withOpacity(0.6),
        ),
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              width: 2,
              color: isEditing
                  ? theme.primary
                  : theme.primaryText.withOpacity(0.6),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: isEditing
                  ? theme.primaryText
                  : theme.primaryText.withOpacity(0.6),
            ),
          ),
          labelText: label,
          labelStyle: TextStyle(
            color: isEditing
                ? theme.primaryText
                : theme.primaryText.withOpacity(0.6),
          ),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
