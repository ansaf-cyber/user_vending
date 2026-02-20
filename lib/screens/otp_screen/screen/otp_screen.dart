import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:user/globalwidgets/custom_components.dart';
import 'package:user/globalwidgets/snackbars/custom_snackbar.dart';
import 'package:user/localization/localisation.dart';
import 'package:user/providers/init_provider.dart';
import 'package:user/providers/user_provider.dart';
import 'package:user/screens/otp_screen/components/components.dart';
import 'package:user/screens/otp_screen/provider/otp_service_provider.dart';
import 'package:user/screens/signin_page/provider/auth_provider.dart';
import 'package:user/screens/signin_page/screen/auth_screen.dart';
import 'package:user/theme/apptheme.dart';

class OTPVerificationScreen extends StatelessWidget {
  final bool changePhone;

  const OTPVerificationScreen({super.key, this.changePhone = false});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OTPVerificationProvider(),
      child: Consumer3<OTPVerificationProvider, InitilisationProvider, SignInProvider>(
        builder: (context, otpProvider, initProvider, signInProvider, child) {
          if (otpProvider.isScreenLoading) {
            return Scaffold(
              backgroundColor: Apptheme.of(context).primaryBackground,

              body: const Center(child: CircularProgressIndicator()),
            );
          } else {
            return Scaffold(
              backgroundColor: Apptheme.of(context).primaryBackground,
              appBar: changePhone
                  ? null
                  : AppBar(
                      backgroundColor: Apptheme.of(context).primaryBackground,
                      elevation: 0,
                      automaticallyImplyLeading: false,
                      actions: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: _buildLogoutButton(context, signInProvider),
                        ),
                      ],
                    ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (changePhone) ...[
                        Row(
                          children: [
                            Expanded(
                              child: HeaderWithIcon(
                                leading: const CustomIcon(),
                                title: FFLocalizations.of(
                                  context,
                                ).getText('enterPhoneNumberTitle'),
                                iconFirst: true,
                                isSub: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (!changePhone) ...[
                        const SizedBox(height: 20),
                        Text(
                          FFLocalizations.of(
                            context,
                          ).getText('enterPhoneNumberTitle'),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        FFLocalizations.of(context).getText('verifyPhoneTitle'),
                        style: TextStyle(fontSize: 16, height: 1.4),
                      ),

                      // Show cooldown message if there's an active cooldown
                      if (!otpProvider.canResend &&
                          otpProvider.resendCountdown > 0 &&
                          !otpProvider.otpSent) ...[
                        // const SizedBox(height: 16),
                        // Container(
                        //   width: double.infinity,
                        //   padding: const EdgeInsets.all(16),
                        //   decoration: BoxDecoration(
                        //     color: Colors.orange.withOpacity(0.1),
                        //     borderRadius: BorderRadius.circular(12),
                        //     border: Border.all(
                        //       color: Colors.orange.withOpacity(0.3),
                        //     ),
                        //   ),
                        //   child: Row(
                        //     children: [
                        //       Icon(
                        //         Icons.info_outline,
                        //         color: Colors.orange[700],
                        //         size: 20,
                        //       ),
                        //       const SizedBox(width: 12),
                        //       Expanded(
                        //         child: Text(
                        //           otpProvider.getCooldownMessage(context),
                        //           style: TextStyle(
                        //             color: Colors.orange[700],
                        //             fontSize: 14,
                        //             fontWeight: FontWeight.w500,
                        //           ),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      ],

                      const SizedBox(height: 40),
                      Row(
                        children: [
                          Expanded(
                            child: OtpFields(
                              controller: otpProvider.phoneController,
                              label: FFLocalizations.of(
                                context,
                              ).getText('phoneNumber'),
                              isPhone: true,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return FFLocalizations.of(
                                    context,
                                  ).getText('phoneNumberRequired');
                                }
                                final cleanedValue = value.replaceAll(
                                  RegExp(r'[^\d]'),
                                  '',
                                );
                                if (!RegExp(
                                  r'^\d{7,}$',
                                ).hasMatch(cleanedValue)) {
                                  return FFLocalizations.of(
                                    context,
                                  ).getText('onlyDigitsAllowed');
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      if (otpProvider.otpSent) ...[
                        const SizedBox(height: 24),
                        Text(
                          FFLocalizations.of(context).getText('enterOtpTitle'),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Apptheme.of(context).primaryText,
                          ),
                        ),
                        const SizedBox(height: 12),
                        OtpFields(
                          controller: otpProvider.otpController,
                          label: FFLocalizations.of(context).getText('otpHint'),
                        ),

                        // Show cooldown message for resend when OTP is sent
                        // if (!otpProvider.canResend &&
                        //     otpProvider.resendCountdown > 0) ...[
                        //   const SizedBox(height: 16),
                        //   Container(
                        //     width: double.infinity,
                        //     padding: const EdgeInsets.all(12),
                        //     decoration: BoxDecoration(
                        //       color: Colors.blue.withOpacity(0.1),
                        //       borderRadius: BorderRadius.circular(8),
                        //       border: Border.all(
                        //         color: Colors.blue.withOpacity(0.3),
                        //       ),
                        //     ),
                        //     child: Text(
                        //       otpProvider.getCooldownMessage(context),
                        //       style: TextStyle(
                        //         color: Colors.blue[700],
                        //         fontSize: 13,
                        //         fontWeight: FontWeight.w500,
                        //       ),
                        //       textAlign: TextAlign.center,
                        //     ),
                        //   ),
                        // ],
                      ],
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.15,
                      ),
                      if (!otpProvider.otpSent ||
                          otpProvider.showMethodSelection) ...[
                        _buildMethodSelectionCard(context, otpProvider),
                        const SizedBox(height: 20),
                      ],
                      if (!otpProvider.otpSent) ...[
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed:
                                (otpProvider.isLoading ||
                                    !otpProvider.canResend)
                                ? null
                                : () => otpProvider.sendOTP(
                                    initProvider.selectedCountry!.dialCode,
                                    initProvider.selectedCountry!.code
                                        .toLowerCase(),
                                    context,
                                  ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  (otpProvider.canResend &&
                                      !otpProvider.isLoading)
                                  ? Apptheme.of(context).primary
                                  : Colors.grey[400],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              elevation: 0,
                            ),
                            child: otpProvider.isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    otpProvider.canResend
                                        ? FFLocalizations.of(
                                            context,
                                          ).getText('sendOtp')
                                        : 'Wait ${otpProvider.formatCountdown(otpProvider.resendCountdown)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ] else ...[
                        if (!otpProvider.showMethodSelection) ...[
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: otpProvider.isLoading
                                  ? null
                                  : () => otpProvider.verifyOTP(
                                      initProvider.selectedCountry!.dialCode,
                                      initProvider.selectedCountry!.code
                                          .toLowerCase(),
                                      context,
                                    ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Apptheme.of(context).primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                elevation: 0,
                              ),
                              child: otpProvider.isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      FFLocalizations.of(
                                        context,
                                      ).getText('verifyOtp'),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton(
                                onPressed: otpProvider.canResend
                                    ? () {
                                        otpProvider.changeMethod(true);
                                      }
                                    : null,
                                child: Text(
                                  FFLocalizations.of(
                                    context,
                                  ).getText('changeMethod'),
                                  style: TextStyle(
                                    color: otpProvider.canResend
                                        ? Apptheme.of(context).primary
                                        : Colors.grey,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: otpProvider.canResend
                                    ? () => otpProvider.sendOTP(
                                        initProvider.selectedCountry!.dialCode,
                                        initProvider.selectedCountry!.code
                                            .toLowerCase(),
                                        context,
                                      )
                                    : null,
                                child: Text(
                                  otpProvider.canResend
                                      ? FFLocalizations.of(
                                          context,
                                        ).getText('resendOtp')
                                      : '${FFLocalizations.of(context).getText("resendIn")} ${otpProvider.formatCountdown(otpProvider.resendCountdown)}',
                                  style: TextStyle(
                                    color: otpProvider.canResend
                                        ? Apptheme.of(context).primary
                                        : Colors.grey,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          Container(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed:
                                  (otpProvider.isLoading ||
                                      !otpProvider.canResend)
                                  ? null
                                  : () => otpProvider.sendOTP(
                                      initProvider.selectedCountry!.dialCode,
                                      initProvider.selectedCountry!.code
                                          .toLowerCase(),
                                      context,
                                    ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    (otpProvider.canResend &&
                                        !otpProvider.isLoading)
                                    ? Apptheme.of(context).primary
                                    : Colors.grey[400],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                elevation: 0,
                              ),
                              child: otpProvider.isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      otpProvider.canResend
                                          ? FFLocalizations.of(
                                              context,
                                            ).getText('resendOtp')
                                          : 'Wait ${otpProvider.formatCountdown(otpProvider.resendCountdown)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                otpProvider.changeMethod(false);
                              },
                              child: Text(
                                FFLocalizations.of(context).getText('cancel'),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildLogoutButton(
    BuildContext context,
    SignInProvider signInProvider,
  ) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final t = FFLocalizations.of(context);
        return PopupMenuButton<String>(
          splashRadius: 13,
          offset: const Offset(-50, 30),
          elevation: 6,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onSelected: (value) async {
            if (value == 'logout') {
              FocusScope.of(context).unfocus();
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(t.getText('logout')),
                  content: Text(t.getText('logoutConfirmation')),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        t.getText('cancel'),
                        style: TextStyle(
                          color: Apptheme.of(context).primaryText,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(
                        t.getText('confirm'),
                        style: TextStyle(
                          color: Apptheme.of(context).primaryBackground,
                        ),
                      ),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true && context.mounted) {
                try {
                  await signInProvider.signOut();

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                    (Route<dynamic> route) => false,
                  );
                } catch (e) {
                  showCustomSnackbar(
                    type: SnackbarType.error,
                    context: context,
                    message: t.getText('logoutError'),
                  );
                }
              }
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'logout',
              padding: const EdgeInsets.all(10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const HugeIcon(
                      icon: HugeIcons.strokeRoundedLogout02,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      t.getText('logout'),
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
          ],
          child: ClipOval(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedMoreVerticalCircle01,
                  color: Apptheme.of(context).primaryText,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMethodSelectionCard(
    BuildContext context,
    OTPVerificationProvider provider,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Apptheme.of(context).primaryText.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              FFLocalizations.of(context).getText('getOtpVia'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          RadioListTile<String>(
            title: Text(
              FFLocalizations.of(context).getText('sms'),
              style: TextStyle(color: Apptheme.of(context).primaryText),
            ),
            value: 'SMS',

            groupValue: provider.selectedMethod,
            onChanged: (value) {
              if (value != null) {
                provider.setMethod(value);
              }
            },
            activeColor: Apptheme.of(context).primary,
          ),
          RadioListTile<String>(
            title: Text(
              FFLocalizations.of(context).getText('whatsapp'),
              style: TextStyle(color: Apptheme.of(context).primaryText),
            ),
            value: 'WhatsApp',
            tileColor: Apptheme.of(context).primaryText,
            groupValue: provider.selectedMethod,
            onChanged: (value) {
              if (value != null) {
                provider.setMethod(value);
              }
            },
            activeColor: Apptheme.of(context).primary,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
