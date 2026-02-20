import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:provider/provider.dart';
import 'package:user/globalwidgets/bottomsheets/language_selector_bottomsheet.dart';
import 'package:user/globalwidgets/custom_components.dart';
import 'package:user/globalwidgets/snackbars/custom_snackbar.dart';
import 'package:user/localization/localisation.dart';
import 'package:user/main.dart';
import 'package:user/screens/signin_page/components/auth_page_components.dart';
import 'package:user/screens/signin_page/components/forgot_password_screen.dart';
import 'package:user/screens/signin_page/provider/auth_provider.dart';
import 'package:user/screens/signin_page/screen/onboarding_screen.dart';
import 'package:user/theme/apptheme.dart';

class StartupWrapper extends StatelessWidget {
  const StartupWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Since initialization is already done, we can directly check the state
    final appInitializer = AppInitializer();

    if (appInitializer.hasCompletedOnboarding) {
      return const AuthScreen();
    } else {
      return const OnboardingScreen();
    }
  }
}

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> languages = [
      {'name': 'English', 'code': 'en'},
      {'name': 'عربي', 'code': 'ar'},
    ];
    final bool showFab = MediaQuery.of(context).viewInsets.bottom == 0.0;
    return Scaffold(
      floatingActionButton: showFab
          ? CustomIcon(
              icon:  HugeIcon(
                icon: HugeIcons.strokeRoundedLanguageSkill,
                color: Apptheme.of(context).primaryText,
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  builder: (context) =>
                      LanguageSelectionBottomSheet(languages: languages),
                );
              },
            )
          : null,
      backgroundColor: Apptheme.of(context).primaryBackground,
      body: SafeArea(top: true, child: _AuthForm()),
    );
  }
}

class _AuthForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isRtl = FFLocalizations.of(context).locale.languageCode == 'ar';
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              _LogoWidget(),
              const SizedBox(height: 30),
              Container(
                constraints: const BoxConstraints(maxWidth: 602),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _AuthTabs(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        'assets/images/mainLogoFull.png',
        width: 200,
        height: 100,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _AuthTabs extends StatefulWidget {
  @override
  State<_AuthTabs> createState() => _AuthTabsState();
}

class _AuthTabsState extends State<_AuthTabs>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.center,
          child: TabBar(
            tabAlignment: TabAlignment.center,
            controller: tabController,
            isScrollable: true,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).colorScheme.secondary,
            labelPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            labelStyle: _textStyle(context, isSelected: true),
            unselectedLabelStyle: _textStyle(context, isSelected: false),
            indicatorColor: Theme.of(context).colorScheme.primary,
            indicatorWeight: 4,
            tabs: [
              Tab(text: FFLocalizations.of(context).getText('signIn')),
              Tab(text: FFLocalizations.of(context).getText('signUp')),
            ],
          ),
        ),

        SizedBox(
          height: 700,
          child: TabBarView(
            controller: tabController,
            children: [_SignInForm(), _SignUpForm()],
          ),
        ),
      ],
    );
  }

  TextStyle _textStyle(BuildContext context, {required bool isSelected}) {
    return Theme.of(context).textTheme.displaySmall!.copyWith(
      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      letterSpacing: 0.0,
    );
  }
}

class _SignInForm extends StatefulWidget {
  @override
  State<_SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<_SignInForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();

  final TextEditingController passwordController = TextEditingController();
  final FocusNode passwordFocusNode = FocusNode();

  bool passwordVisible = false;

  @override
  void dispose() {
    emailController.dispose();
    emailFocusNode.dispose();
    passwordController.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return FFLocalizations.of(context).getText("emailRequired");
    }
    if (!value.contains('@')) {
      return FFLocalizations.of(context).getText("emailRequired");
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.length < 6) {
      return FFLocalizations.of(context).getText("passwordTooShort");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SignInProvider>(
      builder: (context, authprovider, child) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //  const SizedBox(height: 15),
                const SizedBox(height: 20),
                //  const SizedBox(height: 15),
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
                FormFieldCustom(
                  controller: passwordController,
                  focusNode: passwordFocusNode,
                  label: FFLocalizations.of(
                    context,
                  ).getText('password') /* Password */,
                  autofillHints: const [AutofillHints.password],
                  obscureText: !passwordVisible,
                  suffixIcon: VisibilityToggle(
                    isVisible: passwordVisible,
                    onToggle: () =>
                        setState(() => passwordVisible = !passwordVisible),
                  ),
                  validator: validatePassword,
                ),
                AuthButton(
                  isLoading: authprovider.loading,
                  text: FFLocalizations.of(
                    context,
                  ).getText('signIn') /* Sign In */,
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      authprovider.signIn(
                        context,
                        emailController.text,
                        passwordController.text,
                      );
                    }
                  },
                ),
                TextButtonCustom(
                  text: FFLocalizations.of(
                    context,
                  ).getText('forgotPassword') /* Forgot Password */,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                ),
                const SocialLoginSection(isSignIn: true),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SignUpForm extends StatefulWidget {
  @override
  State<_SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<_SignUpForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();

  final TextEditingController passwordController = TextEditingController();
  final FocusNode passwordFocusNode = FocusNode();
  bool passwordVisible = false;

  final TextEditingController confirmPasswordController =
      TextEditingController();
  final FocusNode confirmPasswordFocusNode = FocusNode();
  bool confirmPasswordVisible = false;

  @override
  void dispose() {
    emailController.dispose();
    emailFocusNode.dispose();
    passwordController.dispose();
    passwordFocusNode.dispose();
    confirmPasswordController.dispose();
    confirmPasswordFocusNode.dispose();
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

  String? validatePassword(String? value) {
    if (value == null || value.length < 6) {
      return FFLocalizations.of(context).getText('passwordTooShort');
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value != passwordController.text) {
      return FFLocalizations.of(context).getText("passwordsDoNotMatch");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SignInProvider>(
      builder: (context, siginprovider, child) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
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
                FormFieldCustom(
                  controller: passwordController,
                  focusNode: passwordFocusNode,
                  label: FFLocalizations.of(
                    context,
                  ).getText('password') /* Password */,
                  autofillHints: const [AutofillHints.password],
                  obscureText: !passwordVisible,
                  suffixIcon: VisibilityToggle(
                    isVisible: passwordVisible,
                    onToggle: () =>
                        setState(() => passwordVisible = !passwordVisible),
                  ),
                  validator: validatePassword,
                ),
                FormFieldCustom(
                  controller: confirmPasswordController,
                  focusNode: confirmPasswordFocusNode,
                  label: FFLocalizations.of(
                    context,
                  ).getText('confirmPassword') /* Confirm Password */,
                  autofillHints: const [AutofillHints.password],
                  obscureText: !confirmPasswordVisible,
                  suffixIcon: VisibilityToggle(
                    isVisible: confirmPasswordVisible,
                    onToggle: () => setState(
                      () => confirmPasswordVisible = !confirmPasswordVisible,
                    ),
                  ),
                  validator: validateConfirmPassword,
                ),
                AuthButton(
                  isLoading: siginprovider.loading,
                  text: FFLocalizations.of(
                    context,
                  ).getText('createAccount') /* Create Account */,
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final success = await siginprovider.signUp(
                        context,
                        emailController.text,
                        passwordController.text,
                      );

                      if (!mounted) return;

                      if (success) {
                        emailController.clear();
                        passwordController.clear();
                        confirmPasswordController.clear();
                        if (context.mounted) {
                          showCustomSnackbar(
                            context: context,
                            type: SnackbarType.success,
                            message: FFLocalizations.of(
                              context,
                            ).getText("accountCreated"),
                          );
                        }
                      }
                    }
                  },
                ),
                const SocialLoginSection(isSignIn: false),
              ],
            ),
          ),
        );
      },
    );
  }
}
