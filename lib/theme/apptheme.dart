// ignore_for_file: overridden_fields, annotate_overrides

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:shared_preferences/shared_preferences.dart';

const kThemeModeKey = '__theme_mode__';

SharedPreferences? _prefs;

abstract class Apptheme {
  static Future initialize() async =>
      _prefs = await SharedPreferences.getInstance();

  static ThemeMode get themeMode {
    final darkMode = _prefs?.getBool(kThemeModeKey);
    return darkMode == null
        ? ThemeMode.system
        : darkMode
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  static void saveThemeMode(ThemeMode mode) => mode == ThemeMode.system
      ? _prefs?.remove(kThemeModeKey)
      : _prefs?.setBool(kThemeModeKey, mode == ThemeMode.dark);

  static Apptheme of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? DarkModeTheme()
        : LightModeTheme();
  }

  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  late Color primary;
  late Color secondary;
  late Color tertiary;
  late Color alternate;
  late Color primaryText;
  late Color secondaryText;
  late Color primaryBackground;
  late Color secondaryBackground;
  late Color accent1;
  late Color accent2;
  late Color accent3;
  late Color accent4;
  late Color success;
  late Color warning;
  late Color error;
  late Color info;

  @Deprecated('Use displaySmallFamily instead')
  String get title1Family => displaySmallFamily;
  @Deprecated('Use displaySmall instead')
  TextStyle get title1 => typography.displaySmall;
  @Deprecated('Use headlineMediumFamily instead')
  String get title2Family => typography.headlineMediumFamily;
  @Deprecated('Use headlineMedium instead')
  TextStyle get title2 => typography.headlineMedium;
  @Deprecated('Use headlineSmallFamily instead')
  String get title3Family => typography.headlineSmallFamily;
  @Deprecated('Use headlineSmall instead')
  TextStyle get title3 => typography.headlineSmall;
  @Deprecated('Use titleMediumFamily instead')
  String get subtitle1Family => typography.titleMediumFamily;
  @Deprecated('Use titleMedium instead')
  TextStyle get subtitle1 => typography.titleMedium;
  @Deprecated('Use titleSmallFamily instead')
  String get subtitle2Family => typography.titleSmallFamily;
  @Deprecated('Use titleSmall instead')
  TextStyle get subtitle2 => typography.titleSmall;
  @Deprecated('Use bodyMediumFamily instead')
  String get bodyText1Family => typography.bodyMediumFamily;
  @Deprecated('Use bodyMedium instead')
  TextStyle get bodyText1 => typography.bodyMedium;
  @Deprecated('Use bodySmallFamily instead')
  String get bodyText2Family => typography.bodySmallFamily;
  @Deprecated('Use bodySmall instead')
  TextStyle get bodyText2 => typography.bodySmall;

  String get displayLargeFamily => typography.displayLargeFamily;
  TextStyle get displayLarge => typography.displayLarge;
  String get displayMediumFamily => typography.displayMediumFamily;
  TextStyle get displayMedium => typography.displayMedium;
  String get displaySmallFamily => typography.displaySmallFamily;
  TextStyle get displaySmall => typography.displaySmall;
  String get headlineLargeFamily => typography.headlineLargeFamily;
  TextStyle get headlineLarge => typography.headlineLarge;
  String get headlineMediumFamily => typography.headlineMediumFamily;
  TextStyle get headlineMedium => typography.headlineMedium;
  String get headlineSmallFamily => typography.headlineSmallFamily;
  TextStyle get headlineSmall => typography.headlineSmall;
  String get titleLargeFamily => typography.titleLargeFamily;
  TextStyle get titleLarge => typography.titleLarge;
  String get titleMediumFamily => typography.titleMediumFamily;
  TextStyle get titleMedium => typography.titleMedium;
  String get titleSmallFamily => typography.titleSmallFamily;
  TextStyle get titleSmall => typography.titleSmall;
  String get labelLargeFamily => typography.labelLargeFamily;
  TextStyle get labelLarge => typography.labelLarge;
  String get labelMediumFamily => typography.labelMediumFamily;
  TextStyle get labelMedium => typography.labelMedium;
  String get labelSmallFamily => typography.labelSmallFamily;
  TextStyle get labelSmall => typography.labelSmall;
  String get bodyLargeFamily => typography.bodyLargeFamily;
  TextStyle get bodyLarge => typography.bodyLarge;
  String get bodyMediumFamily => typography.bodyMediumFamily;
  TextStyle get bodyMedium => typography.bodyMedium;
  String get bodySmallFamily => typography.bodySmallFamily;
  TextStyle get bodySmall => typography.bodySmall;

  Typography get typography => ThemeTypography(this);
}

class LightModeTheme extends Apptheme {
  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  late Color primary = const Color(0xFF6337ff);
  late Color secondary = const Color(0xFF34E19A);
  late Color tertiary = const Color(0xFFEE8B60);
  late Color alternate = const Color(0xFFE0E3E7);
  late Color primaryText = const Color(0xFF6337ff);
  late Color secondaryText = const Color(0xFF57636C);
  late Color primaryBackground = const Color(0xFFd2ff59);
  late Color secondaryBackground = const Color(0xFFFFFFFF);
  late Color accent1 = const Color(0xFF6337ff);
  late Color accent2 = const Color(0xFF26B67B);
  late Color accent3 = const Color(0x4DEE8B60);
  late Color accent4 = const Color(0xCCFFFFFF);
  late Color success = const Color(0xFF34E19A);
  late Color warning = const Color(0xFFF9CF58);
  late Color error = const Color(0xFFFF5963);
  late Color info = const Color(0xFFFFFFFF);
}

abstract class Typography {
  String get displayLargeFamily;
  TextStyle get displayLarge;
  String get displayMediumFamily;
  TextStyle get displayMedium;
  String get displaySmallFamily;
  TextStyle get displaySmall;
  String get headlineLargeFamily;
  TextStyle get headlineLarge;
  String get headlineMediumFamily;
  TextStyle get headlineMedium;
  String get headlineSmallFamily;
  TextStyle get headlineSmall;
  String get titleLargeFamily;
  TextStyle get titleLarge;
  String get titleMediumFamily;
  TextStyle get titleMedium;
  String get titleSmallFamily;
  TextStyle get titleSmall;
  String get labelLargeFamily;
  TextStyle get labelLarge;
  String get labelMediumFamily;
  TextStyle get labelMedium;
  String get labelSmallFamily;
  TextStyle get labelSmall;
  String get bodyLargeFamily;
  TextStyle get bodyLarge;
  String get bodyMediumFamily;
  TextStyle get bodyMedium;
  String get bodySmallFamily;
  TextStyle get bodySmall;
}

class ThemeTypography extends Typography {
  ThemeTypography(this.theme);

  final Apptheme theme;

  String get displayLargeFamily => 'tajawal';
  TextStyle get displayLarge => GoogleFonts.tajawal(
    color: theme.primaryText,
    fontWeight: FontWeight.w600,
    fontSize: 67.0,
  );
  String get displayMediumFamily => 'tajawal';
  TextStyle get displayMedium => GoogleFonts.tajawal(
    color: theme.primaryText,
    fontWeight: FontWeight.w600,
    fontSize: 46.0,
  );
  String get displaySmallFamily => 'tajawal';
  TextStyle get displaySmall => GoogleFonts.tajawal(
    color: theme.primaryText,
    fontWeight: FontWeight.w600,
    fontSize: 38.0,
  );
  String get headlineLargeFamily => 'tajawal';
  TextStyle get headlineLarge => GoogleFonts.tajawal(
    color: theme.primaryText,
    fontWeight: FontWeight.w600,
    fontSize: 34.0,
  );
  String get headlineMediumFamily => 'tajawal';
  TextStyle get headlineMedium => GoogleFonts.tajawal(
    color: theme.primaryText,
    fontWeight: FontWeight.w600,
    fontSize: 30.0,
  );
  String get headlineSmallFamily => 'tajawal';
  TextStyle get headlineSmall => GoogleFonts.tajawal(
    color: theme.primaryText,
    fontWeight: FontWeight.w600,
    fontSize: 26.0,
  );
  String get titleLargeFamily => 'tajawal';
  TextStyle get titleLarge => GoogleFonts.tajawal(
    color: theme.primaryText,
    fontWeight: FontWeight.w600,
    fontSize: 22.0,
  );
  String get titleMediumFamily => 'tajawal';
  TextStyle get titleMedium => GoogleFonts.tajawal(
    color: theme.primaryText,
    fontWeight: FontWeight.w600,
    fontSize: 20.0,
  );
  String get titleSmallFamily => 'tajawal';
  TextStyle get titleSmall => GoogleFonts.tajawal(
    color: theme.primaryText,
    fontWeight: FontWeight.w600,
    fontSize: 18.0,
  );
  String get labelLargeFamily => 'tajawal';
  TextStyle get labelLarge => GoogleFonts.tajawal(
    color: theme.secondaryText,
    fontWeight: FontWeight.normal,
    fontSize: 18.0,
  );
  String get labelMediumFamily => 'tajawal';
  TextStyle get labelMedium => GoogleFonts.tajawal(
    color: theme.secondaryText,
    fontWeight: FontWeight.normal,
    fontSize: 16.0,
  );
  String get labelSmallFamily => 'tajawal';
  TextStyle get labelSmall => GoogleFonts.tajawal(
    color: theme.secondaryText,
    fontWeight: FontWeight.normal,
    fontSize: 14.0,
  );
  String get bodyLargeFamily => 'tajawal';
  TextStyle get bodyLarge => GoogleFonts.tajawal(
    color: theme.primaryText,
    fontWeight: FontWeight.normal,
    fontSize: 18.0,
  );
  String get bodyMediumFamily => 'tajawal';
  TextStyle get bodyMedium => GoogleFonts.tajawal(
    color: theme.primaryText,
    fontWeight: FontWeight.normal,
    fontSize: 16.0,
  );
  String get bodySmallFamily => 'tajawal';
  TextStyle get bodySmall => GoogleFonts.tajawal(
    color: theme.primaryText,
    fontWeight: FontWeight.normal,
    fontSize: 14.0,
  );
}

class DarkModeTheme extends Apptheme {
  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  late Color primary = const Color(0xFF6337ff);
  late Color secondary = const Color(0xFF34E19A);
  late Color tertiary = const Color(0xFFEE8B60);
  late Color alternate = const Color(0xFF262D34);
  late Color primaryText = const Color(0xFFFFFFFF);
  late Color secondaryText = const Color(0xFF95A1AC);
  late Color primaryBackground = const Color(0xFF1D2428);
  late Color secondaryBackground = const Color(0xFF14181B);
  late Color accent1 = const Color(0xFF6337ff);
  late Color accent2 = const Color(0xFF26B67B);
  late Color accent3 = const Color(0x4DEE8B60);
  late Color accent4 = const Color(0xB2262D34);
  late Color success = const Color(0xFF34E19A);
  late Color warning = const Color(0xFFF9CF58);
  late Color error = const Color(0xFFFF5963);
  late Color info = const Color(0xFFFFFFFF);
}

extension TextStyleHelper on TextStyle {
  TextStyle override({
    TextStyle? font,
    String? fontFamily,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    FontStyle? fontStyle,
    bool useGoogleFonts = false,
    TextDecoration? decoration,
    double? lineHeight,
    List<Shadow>? shadows,
    String? package,
  }) {
    if (useGoogleFonts && fontFamily != null) {
      font = GoogleFonts.getFont(
        fontFamily,
        fontWeight: fontWeight ?? this.fontWeight,
        fontStyle: fontStyle ?? this.fontStyle,
      );
    }

    return font != null
        ? font.copyWith(
            color: color ?? this.color,
            fontSize: fontSize ?? this.fontSize,
            letterSpacing: letterSpacing ?? this.letterSpacing,
            fontWeight: fontWeight ?? this.fontWeight,
            fontStyle: fontStyle ?? this.fontStyle,
            decoration: decoration,
            height: lineHeight,
            shadows: shadows,
          )
        : copyWith(
            fontFamily: fontFamily,
            package: package,
            color: color,
            fontSize: fontSize,
            letterSpacing: letterSpacing,
            fontWeight: fontWeight,
            fontStyle: fontStyle,
            decoration: decoration,
            height: lineHeight,
            shadows: shadows,
          );
  }
}

ThemeData buildAppTheme(Apptheme Apptheme) {
  final textTheme = TextTheme(
    displayLarge: Apptheme.displayLarge,
    displayMedium: Apptheme.displayMedium,
    displaySmall: Apptheme.displaySmall,
    headlineLarge: Apptheme.headlineLarge,
    headlineMedium: Apptheme.headlineMedium,
    headlineSmall: Apptheme.headlineSmall,
    titleLarge: Apptheme.titleLarge,
    titleMedium: Apptheme.titleMedium,
    titleSmall: Apptheme.titleSmall,
    labelLarge: Apptheme.labelLarge,
    labelMedium: Apptheme.labelMedium,
    labelSmall: Apptheme.labelSmall,
    bodyLarge: Apptheme.bodyLarge,
    bodyMedium: Apptheme.bodyMedium,
    bodySmall: Apptheme.bodySmall,
  );

  return ThemeData(
    brightness: Apptheme is DarkModeTheme ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: Apptheme.primaryBackground,
    primaryColor: Apptheme.primary,
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: _createMaterialColor(Apptheme.primary),
      accentColor: Apptheme.secondary,
      brightness: Apptheme is DarkModeTheme
          ? Brightness.dark
          : Brightness.light,
    ),
    textTheme: textTheme,
    fontFamily: Apptheme.displayLargeFamily,
  );
}

MaterialColor _createMaterialColor(Color color) {
  final strengths = <double>[.05];
  final swatch = <int, Color>{};
  final r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) strengths.add(0.1 * i);
  for (var strength in strengths) {
    final ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }

  return MaterialColor(color.value, swatch);
}
