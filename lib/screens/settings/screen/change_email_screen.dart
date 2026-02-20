import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:user/globalwidgets/custom_components.dart';
import 'package:user/globalwidgets/snackbars/custom_snackbar.dart';
import 'package:user/localization/localisation.dart';
import 'package:user/screens/signin_page/components/auth_page_components.dart';
import 'package:user/theme/apptheme.dart';

class ChangeEmailScreen extends StatefulWidget {
  const ChangeEmailScreen({super.key});

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {


  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Apptheme.of(context);
    final t = FFLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey, // <-- Add Form key here
          child: Column(
            children: [
              HeaderWithIcon(
                iconFirst: true,
                isSub: true,
                title: FFLocalizations.of(context).getText('changeEmail'),
                leading: const CustomIcon(),
              ),
              const SizedBox(height: 50),
              _buildEditableField(
                t.getText('newEmail'),
                _emailController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your new email.';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
                    return FFLocalizations.of(
                      context,
                    ).getText("enterValidEmail");
                  }
                  return null;
                },
              ),
              _buildEditableField(
                t.getText('confirmEmail'),
                _confirmEmailController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please confirm your new email.';
                  }
                  if (value.trim() != _emailController.text.trim()) {
                    return 'Emails do not match.';
                  }
                  return null;
                },
              ),
              _buildEditableField(
                t.getText('password'),
                _passwordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password.';
                  }
                  if (value.length < 6) {
                    return FFLocalizations.of(
                      context,
                    ).getText('passwordTooShort');
                  }
                  return null;
                },
                // optionally obscure text for password
                obscureText: true,
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 70,
                      child: AuthButton(
                        isLoading: isLoading,
                        text: t.getText('changeEmail'),
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          final newEmail = _emailController.text.trim();
                          final password = _passwordController.text;
                          final user = FirebaseAuth.instance.currentUser;

                          if (user == null) {
                            showCustomSnackbar(
                              type: SnackbarType.error,
                              context: context,
                              message: FFLocalizations.of(
                                context,
                              ).getText("noLoggedInUser"),
                            );
                            return;
                          }

                          setState(() => isLoading = true);

                          try {
                            // Step 1: Reauthenticate user with current email and password
                            final cred = EmailAuthProvider.credential(
                              email: user.email!,
                              password: password,
                            );
                            await user.reauthenticateWithCredential(cred);
                            log('Reauthentication successful.');

                            // Step 2: Check if the new email is already verified
                            // Note: Firebase does not provide a direct way to check if an email is verified
                            // Instead, send a verification email to the new email
                            await user.verifyBeforeUpdateEmail(newEmail);

                            // Step 3: Inform the user to check their email
                            showCustomSnackbar(
                              type: SnackbarType.success,
                              context: context,
                              message: FFLocalizations.of(
                                context,
                              ).getText("verificationEmailSent"),
                            );

                            // Step 4: Update Firestore email (optional, only after verification)
                            // You can listen for email verification status or prompt the user to retry
                            // For simplicity, we assume the user will verify and then log in again
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .update({'email': newEmail});

                            Navigator.pop(context);
                          } on FirebaseAuthException catch (e) {
                            String errorKey;

                            switch (e.code) {
                              case 'wrong-password':
                                errorKey = 'incorrectPassword';
                                break;
                              case 'email-already-in-use':
                                errorKey = 'emailInUse';
                                break;
                              case 'user-not-found':
                                errorKey = 'noUserFound';
                                break;
                              case 'invalid-email':
                                errorKey = 'invalidEmail';
                                break;
                              default:
                                errorKey =
                                    'errorOccurred'; // fallback to a generic key
                            }

                            showCustomSnackbar(
                              type: SnackbarType.error,
                              context: context,
                              message: FFLocalizations.of(
                                context,
                              ).getText(errorKey),
                            );
                          } catch (e) {
                            showCustomSnackbar(
                              type: SnackbarType.error,
                              context: context,
                              message: FFLocalizations.of(
                                context,
                              ).getText('unexpectedError'),
                            );
                          } finally {
                            setState(() => isLoading = false);
                          }
                        },
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

  Widget _buildEditableField(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
    Widget? suffixIcon,
    VoidCallback? onTap,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    final theme = Apptheme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        onTapOutside: (event) {
          FocusScope.of(context).unfocus();
        },
        controller: controller,
        readOnly: readOnly,
        obscureText: obscureText,
        validator: validator,
        onTap: onTap,
        style: TextStyle(color: theme.primaryText),
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(width: 2, color: theme.primary),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: theme.primaryText.withValues(alpha: 0.2),
            ),
          ),
          labelText: label,
          labelStyle: TextStyle(
            color: theme.primaryText.withValues(alpha: 0.6),
          ),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
