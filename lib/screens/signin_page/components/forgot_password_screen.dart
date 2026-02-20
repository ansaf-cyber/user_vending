import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user/globalwidgets/snackbars/custom_snackbar.dart';
import 'package:user/localization/localisation.dart';
import 'package:user/screens/signin_page/components/auth_page_components.dart';
import 'package:user/screens/signin_page/provider/auth_provider.dart';
import 'package:user/theme/apptheme.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isRtl = FFLocalizations.of(context).locale.languageCode == 'ar';
    return Scaffold(
      backgroundColor: Apptheme.of(context).primaryBackground,
      body: SafeArea(
        top: true,
        child: Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: _LogoWidget(),
                ),
                Container(
                  constraints: const BoxConstraints(maxWidth: 602),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _ForgotPasswordForm(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 20, bottom: 60),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          'assets/images/logo.png',
          width: 200.1,
          height: 100.1,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _ForgotPasswordForm extends StatefulWidget {
  @override
  State<_ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<_ForgotPasswordForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();

  @override
  void dispose() {
    emailController.dispose();
    emailFocusNode.dispose();
    super.dispose();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return FFLocalizations.of(context).getText("emailRequired");
    }
    if (!value.contains('@')) {
      return FFLocalizations.of(context).getText("enterValidEmail");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SignInProvider>(
      builder: (context, authProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Text(
                    FFLocalizations.of(
                      context,
                    ).getText('forgotPasswordTitle') /* Reset Your Password */,
                    style: labelStyle(context),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Text(
                    FFLocalizations.of(context).getText(
                      'forgotPasswordSubtitle',
                    ) /* Enter your email to receive a password reset link */,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                FormFieldCustom(
                  controller: emailController,
                  focusNode: emailFocusNode,
                  label: FFLocalizations.of(
                    context,
                  ).getText('email') /* Email */,
                  autofillHints: const [AutofillHints.email],
                  keyboardType: TextInputType.emailAddress,
                  validator: validateEmail,
                ),
                AuthButton(
                  isLoading: authProvider.forgotLoading,
                  text: FFLocalizations.of(
                    context,
                  ).getText('sendResetLink') /* Send Reset Link */,
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        final success = await authProvider.resetPassword(
                          context,
                          emailController.text,
                        );
                        if (!mounted) return;
                        if (success) {
                          emailController.clear();
                          showCustomSnackbar(
                            context: context,
                            type: SnackbarType.success,
                            message: FFLocalizations.of(context).getText(
                              'resetLinkSent',
                            ) /* Reset link sent successfully! */,
                          );
                        }
                      } on FirebaseAuthException catch (e) {
                        if (!mounted) return;
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
                        showCustomSnackbar(
                          context: context,
                          type: SnackbarType.error,
                          message: FFLocalizations.of(
                            context,
                          ).getText(errorMessage),
                        );
                      }
                    }
                  },
                ),
                TextButtonCustom(
                  text: FFLocalizations.of(
                    context,
                  ).getText('backToSignIn') /* Back to Sign In */,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
