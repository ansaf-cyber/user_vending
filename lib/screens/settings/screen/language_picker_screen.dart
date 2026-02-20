
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user/globalwidgets/custom_components.dart';
import 'package:user/localization/localisation.dart';
import 'package:user/providers/language_provider.dart';
import 'package:user/theme/apptheme.dart';


class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  // List of supported languages
  final List<Map<String, String>> languages = [
    {'name': 'English', 'code': 'en'},
    {'name': 'عربي', 'code': 'ar'},
  ];

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Apptheme.of(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final t = FFLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            HeaderWithIcon(
              iconFirst: true,
              isSub: true,
              title: t.getText('language'),
              leading: const CustomIcon(),
            ),
            const SizedBox(height: 50),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  final language = languages[index];
                  final isSelected =
                      languageProvider.locale.languageCode == language['code'];
                  return InkWell(
                    onTap: () {
                      languageProvider.setLocale(language['code']!);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: theme.alternate.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              language['name']!,
                              style: TextStyle(
                                color: theme.primaryText,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: theme.primary,
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
