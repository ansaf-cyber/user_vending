import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:user/globalwidgets/custom_components.dart';
import 'package:user/globalwidgets/snackbars/custom_snackbar.dart';
import 'package:user/localization/localisation.dart';
import 'package:user/screens/signin_page/components/auth_page_components.dart';
import 'package:user/theme/apptheme.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
 

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

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
          key: _formKey,
          child: Column(
            children: [
              HeaderWithIcon(
                iconFirst: true,
                isSub: true,
                title: FFLocalizations.of(context).getText('changePassword'),
                leading: const CustomIcon(),
              ),
              const SizedBox(height: 50),
              _buildEditableField(
                t.getText('currentPassword'),
                _currentPasswordController,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password.';
                  }
                  if (value.length < 6) {
                    return FFLocalizations.of(
                      context,
                    ).getText("passwordTooShort");
                  }
                  return null;
                },
              ),
              _buildEditableField(
                t.getText('newPassword'),
                _newPasswordController,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your new password.';
                  }
                  if (value.length < 6) {
                    return FFLocalizations.of(
                      context,
                    ).getText("passwordTooShort");
                  }
                  return null;
                },
              ),
              _buildEditableField(
                t.getText('confirmPassword'),
                _confirmPasswordController,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password.';
                  }
                  if (value != _newPasswordController.text) {
                    return FFLocalizations.of(
                      context,
                    ).getText("passwordsDoNotMatch");
                  }
                  return null;
                },
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 70,
                      child: AuthButton(
                        isLoading: isLoading,
                        text: t.getText('changePassword'),
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          final currentPassword =
                              _currentPasswordController.text;
                          final newPassword = _newPasswordController.text;
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
                              password: currentPassword,
                            );
                            await user.reauthenticateWithCredential(cred);
                            log('Reauthentication successful.');

                            // Step 2: Update the password
                            await user.updatePassword(newPassword);

                            // Step 3: Notify user of success
                            showCustomSnackbar(
                              type: SnackbarType.success,
                              context: context,
                              message: FFLocalizations.of(
                                context,
                              ).getText("passwordUpdated"),
                            );

                            // Step 4: Optionally update Firestore if needed
                            // For example, log the password change timestamp
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .update({
                                  'lastPasswordChange':
                                      FieldValue.serverTimestamp(),
                                });

                            Navigator.pop(context);
                          } on FirebaseAuthException catch (e) {
                            String errorMsg;
                            if (e.code == 'wrong-password') {
                              errorMsg = 'incorrectCurrentPassword';
                            } else if (e.code == 'requires-recent-login') {
                              errorMsg = 'reloginTryAgain';
                            } else if (e.code == 'weak-password') {
                              errorMsg = 'weakPassword';
                            } else {
                              errorMsg =
                                  e.message ??
                                  FFLocalizations.of(
                                    context,
                                  ).getText("errorOccurred");
                            }
                            showCustomSnackbar(
                              type: SnackbarType.error,
                              context: context,
                              message: FFLocalizations.of(
                                context,
                              ).getText(errorMsg),
                            );
                          } catch (e) {
                            showCustomSnackbar(
                              type: SnackbarType.error,
                              context: context,
                              message: FFLocalizations.of(
                                context,
                              ).getText("unexpectedError"),
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
