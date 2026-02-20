import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:user/localization/localisation.dart';
import 'package:user/theme/apptheme.dart';

Future<void> showAboutUsDialog(BuildContext context, String version) async {
  final theme = Apptheme.of(context);

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.primaryBackground,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header section with icon and title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  width: 200,
                  height: 100,

                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8), // adjust curve here
                    child: Image.asset("assets/images/mainLogoFull.png"),
                  ),
                ),

                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        FFLocalizations.of(context).getText('aboutUs'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: theme.primaryText,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Text(
                      //   "App Information",
                      //   style: TextStyle(
                      //     fontSize: 14,
                      //     color: theme.primaryText.withValues(alpha: 0.6),
                      //     fontWeight: FontWeight.w400,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Company details section
            Directionality(
              textDirection: TextDirection.ltr,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.primaryText.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.primaryText.withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Company name
                    Text(
                      "dcab® technologies LLC",
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: theme.primaryText,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Version info
                    Row(
                      children: [
                        Icon(
                          Icons.apps,
                          color: theme.primaryText.withValues(alpha: 0.6),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          version,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.primaryText.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Contact Us section
                    InkWell(
                      onTap: () => _launchUrl('mailto:hello@dcab.com'),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: theme.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.primary.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.email_outlined,
                              color: theme.primary,
                              size: 18,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "hello@dcab.com",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: theme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_outward,
                              color: theme.primary,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Website section
                    InkWell(
                      onTap: () => _launchUrl('https://www.dcab.com'),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: theme.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.primary.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.language,
                              color: theme.primary,
                              size: 18,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "www.dcab.com",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: theme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_outward,
                              color: theme.primary,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Social media section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  FFLocalizations.of(context).getText('followUs'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.primaryText,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 16),

                // Social media icons in a professional grid
                Row(
                  children: [
                    Expanded(
                      child: _buildSocialIcon(
                        context,
                        FontAwesomeIcons.facebookF,
                        const Color(0xFF1877F2),
                        "Facebook",
                        () => _launchUrl('https://facebook.com/dcab'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSocialIcon(
                        context,
                        FontAwesomeIcons.xTwitter,
                        const Color(0xFF000000),
                        "X",
                        () => _launchUrl('https://x.com/dcab'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSocialIcon(
                        context,
                        FontAwesomeIcons.instagram,
                        const Color(0xFFE4405F),
                        "Instagram",
                        () => _launchUrl('https://instagram.com/dcab'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSocialIcon(
                        context,
                        FontAwesomeIcons.linkedinIn,
                        const Color(0xFF0A66C2),
                        "LinkedIn",
                        () => _launchUrl('https://linkedin.com/company/dcab'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
            const SizedBox(height: 32),

            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
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
                  FFLocalizations.of(context).getText("close"),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildSocialIcon(
  BuildContext context,
  IconData icon,
  Color color,
  String label,
  VoidCallback onTap,
) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
      ),
      child: Center(child: Icon(icon, color: color, size: 18)),
    ),
  );
}

// Helper function to launch URLs with fallback options
Future<void> _launchUrl(String url) async {
  try {
    final Uri uri = Uri.parse(url);

    // First try to launch with external application (native app)

    await launchUrl(uri, mode: LaunchMode.externalApplication).catchError((
      _,
      // ignore: body_might_complete_normally_catch_error
    ) async {
      // If external app launch fails, try external non-browser
      await launchUrl(
        uri,
        mode: LaunchMode.externalNonBrowserApplication,
        // ignore: body_might_complete_normally_catch_error
      ).catchError((_) async {
        // Final fallback: open in browser
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      });
    });
  } catch (e) {
    log('Could not launch $url: $e');
  }
}
