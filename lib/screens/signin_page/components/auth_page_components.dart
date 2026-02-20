import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:user/localization/localisation.dart';
import 'package:user/screens/signin_page/provider/auth_provider.dart';
import 'package:user/theme/apptheme.dart';

class FormFieldCustom extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final List<String>? autofillHints;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final FormFieldValidator<String>? validator;

  const FormFieldCustom({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.label,
    this.autofillHints,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        onTapOutside: (event) {
          FocusScope.of(context).unfocus();
        },
        controller: controller,
        focusNode: focusNode,

        autofillHints: autofillHints,
        obscureText: obscureText,
        validator: validator, // ✅ Pass validator here
        decoration: InputDecoration(
          labelText: label,
          labelStyle: labelStyle(context),
          enabledBorder: _border(context, Apptheme.of(context).alternate),
          focusedBorder: _border(
            context,
            Theme.of(context).colorScheme.primary,
          ),
          errorBorder: _border(context, Theme.of(context).colorScheme.error),
          focusedErrorBorder: _border(
            context,
            Theme.of(context).colorScheme.error,
          ),
          filled: true,
          fillColor: Apptheme.of(context).primaryBackground,
          contentPadding: const EdgeInsets.all(24),
          suffixIcon: suffixIcon,
        ),
        style: bodyStyle(context),
        keyboardType: keyboardType,
        cursorColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

OutlineInputBorder _border(BuildContext context, Color color) {
  return OutlineInputBorder(
    borderSide: BorderSide(color: color, width: 2),
    borderRadius: BorderRadius.circular(40),
  );
}

class VisibilityToggle extends StatelessWidget {
  final bool isVisible;
  final VoidCallback onToggle;

  const VisibilityToggle({required this.isVisible, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      focusNode: FocusNode(skipTraversal: true),
      child: Icon(
        isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: Theme.of(context).colorScheme.secondary,
        size: 24,
      ),
    );
  }
}

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;
  final Color? newcolor;

  const AuthButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.newcolor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ElevatedButton(
        onPressed: (isLoading || !isEnabled) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: isEnabled
              ? newcolor ?? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.primary.withOpacity(0.5),
          minimumSize: const Size(230, 52),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          elevation: isEnabled ? 3 : 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2.5,
                ),
              )
            : Text(text, style: buttonStyle(context)),
      ),
    );
  }
}

class TextButtonCustom extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const TextButtonCustom({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size(230, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(text, style: bodyStyle(context)),
    );
  }
}

class SocialLoginSection extends StatelessWidget {
  final bool isSignIn;
  const SocialLoginSection({super.key, required this.isSignIn});

  @override
  Widget build(BuildContext context) {
    return Consumer<SignInProvider>(
      builder: (context, signinProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Text(
              FFLocalizations.of(
                context,
              ).getText('orSignUpWith') /* Or sign up with */,
              style: labelStyle(context),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _SocialButton(
                  loading: signinProvider.googleLoading,
                  text: FFLocalizations.of(
                    context,
                  ).getText('continueWithGoogle') /* Continue with Google */,
                  icon: FontAwesomeIcons.google,
                  onPressed: () async {
                    if (isSignIn) {
                      signinProvider.signInWithGoogle(context);
                      log("pressed googl signin ");
                    } else {
                      signinProvider.signInWithGoogle(context);
                      log("pressesdgoogl signup ");
                    }
                  },
                ),

                // _SocialButton(
                //   loading: signinProvider.faceBookLoading,
                //   text: FFLocalizations.of(context).getText(
                //     'continueWithFacebook',
                //   ) /* Continue with Facebook */,
                //   icon: Icons.facebook_sharp,
                //   onPressed: () async {
                //     if (isSignIn) {
                //       signinProvider.signInWithFacebook(context);
                //     } else {
                //       signinProvider.signInWithFacebook(context);
                //       log("presses facebook signup ");
                //     }
                //   },
                // ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final bool loading;

  const _SocialButton({
    required this.text,
    required this.icon,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(230, 44),
          side: BorderSide(color: Apptheme.of(context).alternate, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          backgroundColor: Apptheme.of(context).primaryBackground,
        ),
        child: loading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Apptheme.of(context).primary,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(
                    icon,
                    size: 20,
                    color: Apptheme.of(context).primaryText,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    text,
                    style: bodyStyle(
                      context,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }
}

TextStyle labelStyle(BuildContext context) {
  return Theme.of(context).textTheme.labelMedium!.copyWith(letterSpacing: 0.0);
}

TextStyle bodyStyle(BuildContext context) {
  return Theme.of(context).textTheme.bodyMedium!.copyWith(letterSpacing: 0.0);
}

TextStyle buttonStyle(BuildContext context) {
  return Theme.of(
    context,
  ).textTheme.titleSmall!.copyWith(color: Colors.white, letterSpacing: 0.0);
}
