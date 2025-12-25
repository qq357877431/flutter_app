import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTheme {
  // iOS 系统颜色
  static const primary = Color(0xFF007AFF);
  static const secondary = Color(0xFF5856D6);
  static const accent = Color(0xFF34C759);
  static const warning = Color(0xFFFF9500);
  static const error = Color(0xFFFF3B30);
  
  // iOS 风格字体 - 使用系统字体
  static const String? _fontFamily = '.SF Pro Text'; // iOS SF Pro

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      fontFamily: _fontFamily,
      scaffoldBackgroundColor: const Color(0xFFF2F2F7),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          color: Colors.black,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
      ),
      listTileTheme: const ListTileThemeData(
        tileColor: Colors.white,
        textColor: Colors.black,
        iconColor: Colors.black54,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(fontFamily: _fontFamily),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(fontFamily: _fontFamily, color: Colors.black, fontWeight: FontWeight.w700),
        displayMedium: TextStyle(fontFamily: _fontFamily, color: Colors.black, fontWeight: FontWeight.w700),
        displaySmall: TextStyle(fontFamily: _fontFamily, color: Colors.black, fontWeight: FontWeight.w600),
        headlineLarge: TextStyle(fontFamily: _fontFamily, color: Colors.black, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(fontFamily: _fontFamily, color: Colors.black, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(fontFamily: _fontFamily, color: Colors.black, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontFamily: _fontFamily, color: Colors.black, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontFamily: _fontFamily, color: Colors.black, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(fontFamily: _fontFamily, color: Colors.black, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontFamily: _fontFamily, color: Colors.black, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(fontFamily: _fontFamily, color: Colors.black, fontWeight: FontWeight.w400),
        bodySmall: TextStyle(fontFamily: _fontFamily, color: Colors.black54, fontWeight: FontWeight.w400),
        labelLarge: TextStyle(fontFamily: _fontFamily, color: Colors.black, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(fontFamily: _fontFamily, color: Colors.black, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(fontFamily: _fontFamily, color: Colors.black54, fontWeight: FontWeight.w500),
      ),
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        error: error,
        surface: Colors.white,
        onSurface: Colors.black,
      ),
    );
  }

  static ThemeData get darkTheme {
    const darkBg = Color(0xFF1C1C1E);
    const darkCard = Color(0xFF2C2C2E);
    const darkText = Colors.white;
    const darkTextSecondary = Color(0xFF8E8E93);
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primary,
      fontFamily: _fontFamily,
      scaffoldBackgroundColor: darkBg,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: darkText,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          color: darkText,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: darkText),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: darkCard,
      ),
      listTileTheme: const ListTileThemeData(
        tileColor: darkCard,
        textColor: darkText,
        iconColor: darkTextSecondary,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: const TextStyle(color: darkTextSecondary),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(fontFamily: _fontFamily),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(fontFamily: _fontFamily, color: darkText, fontWeight: FontWeight.w700),
        displayMedium: TextStyle(fontFamily: _fontFamily, color: darkText, fontWeight: FontWeight.w700),
        displaySmall: TextStyle(fontFamily: _fontFamily, color: darkText, fontWeight: FontWeight.w600),
        headlineLarge: TextStyle(fontFamily: _fontFamily, color: darkText, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(fontFamily: _fontFamily, color: darkText, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(fontFamily: _fontFamily, color: darkText, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontFamily: _fontFamily, color: darkText, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontFamily: _fontFamily, color: darkText, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(fontFamily: _fontFamily, color: darkText, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontFamily: _fontFamily, color: darkText, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(fontFamily: _fontFamily, color: darkText, fontWeight: FontWeight.w400),
        bodySmall: TextStyle(fontFamily: _fontFamily, color: darkTextSecondary, fontWeight: FontWeight.w400),
        labelLarge: TextStyle(fontFamily: _fontFamily, color: darkText, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(fontFamily: _fontFamily, color: darkText, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(fontFamily: _fontFamily, color: darkTextSecondary, fontWeight: FontWeight.w500),
      ),
      dividerColor: const Color(0xFF38383A),
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        error: error,
        surface: darkCard,
        onSurface: darkText,
      ),
    );
  }

  static ScrollBehavior get scrollBehavior => const CupertinoScrollBehavior();
}

class CupertinoScrollBehavior extends ScrollBehavior {
  const CupertinoScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) => const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) => child;
}
