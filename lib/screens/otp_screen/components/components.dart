import 'package:circle_flags/circle_flags.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:user/globalwidgets/textformatters/arabic_to_english.dart';
import 'package:user/providers/init_provider.dart';
import 'package:user/screens/country_pricker/country_picker_screen.dart';
import 'package:user/theme/apptheme.dart';

class OtpFields extends StatelessWidget {
  final String label;
  final bool isPhone;
  final bool isOtp;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const OtpFields({
    super.key,
    required this.label,
    this.isPhone = false,
    this.isOtp = false,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Apptheme.of(context);
    final inputController = controller ?? TextEditingController();
    TextDirection current = TextDirection.ltr;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Directionality(
          textDirection: current,
          child: Consumer<InitilisationProvider>(
            builder: (context, provider, child) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: inputController,
                  builder: (context, value, _) {
                    return TextFormField(
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        if (isOtp) ...[LengthLimitingTextInputFormatter(6)],
                        ArabicToWesternDigitsFormatter(),
                      ],
                      onTapOutside: (event) {
                        FocusScope.of(context).unfocus();
                      },

                      controller: inputController,
                      keyboardType: isPhone
                          ? TextInputType.phone
                          : TextInputType.text,
                      validator: validator,
                      decoration: InputDecoration(
                        hintText: label,
                        hintStyle: theme.labelMedium.copyWith(
                          fontSize: 16,
                          color: theme.primaryText,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: theme.alternate,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: theme.primary,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: theme.error, width: 2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: theme.error, width: 2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        filled: true,
                        fillColor: theme.secondaryBackground,
                        contentPadding: const EdgeInsetsDirectional.fromSTEB(
                          15,
                          20,
                          0,
                          20,
                        ),
                        prefixIcon: isPhone
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Flag + arrow (clickable)
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const CountryListScreen(),
                                          ),
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          CircleFlag(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                4,
                                              ), // slight rounding, or 0 for sharp
                                            ),
                                            provider.selectedCountry!.code,
                                            size: 30,
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Vertical divider
                                    Container(
                                      height: 30,
                                      width: 1,
                                      color: theme.alternate,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                    ),

                                    // Dial code
                                    Text(
                                      provider.selectedCountry!.dialCode,
                                      style: TextStyle(
                                        color: theme.primaryText,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : null,

                        suffixIcon: value.text.isNotEmpty
                            ? Container(
                                width: 24,
                                height: 24,
                                padding: const EdgeInsets.all(13),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      inputController.clear();
                                    },
                                    child: const HugeIcon(
                                      icon: HugeIcons.strokeRoundedCancel01,
                                      size: 15,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              )
                            : null,
                      ),
                      style: TextStyle(color: theme.primaryText, fontSize: 17),
                      cursorColor: theme.primaryText,
                    );
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 5),
      ],
    );
  }
}
