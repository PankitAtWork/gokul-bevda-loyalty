import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFFe61b2e); // strong red from screenshot
  static const Color primaryDark = Color(0xFFc61828);
  static const Color accent = Color(0xFFFF5A6E);
  static const Color bg = Colors.white;
  static const Color unselected_tab_color = Color(0xFF6C757D);
  static const Color grayColor = Color(0xFFF5F5F5);
  static const Color inputBorderColor = Color(0xFFE9ECEF);
  static const Color darkRed = Color(0xFFDC202F);
  static const Color lightRed = Color(0xFFFFCCCC);
  static const Color darkGreen = Color(0xFF198754);
  static const Color darkRed2 = Color(0xFFF42828);
  static const Color lightPink = Color(0xFFFFF5F5);
  static const Color darkPink = Color(0xFFFFCCCC);
  static const Color lightGreen = Color(0xFF00C853);
  static const Color semiDarkPink = Color(0xFFFCEDEE);
  static const Color lightGray = Color(0xFFF9F9F9);
  static const Color borderCalendarColor = Color(0xFFE9ECEF);
  static const Color resetButtonColor = Color(0xFFE9ECEF);
  static const Color doubleLightGray = Color(0xFFFAFAFA);
  static const Color doubleLightPink = Color(0xFFF5F5F5);
  static const double cardRadius = 22.0;
  static const Color splashColor = Color(0xFFF4EDDB);

  static ThemeData light() {
    final base = ThemeData.light();
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: primary,
        secondary: accent,
        onPrimary: Colors.white,
      ),
      scaffoldBackgroundColor: bg,
      textTheme: base.textTheme.apply(fontFamily: 'Roboto Flex'),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size.fromHeight(48),
        ),
      ),
    );
  }
}
