import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF4A6CF7);
  static const Color primaryLight = Color(0xFFDCE3FF);
  static const Color background = Color(0xFFF8F9FD);
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF1E2A4A);
  static const Color textColorSecondary = Color(0xFF8E92A4);
  static const Color errorColor = Color(0xFFEF5B5B);
  static const Color successColor = Color(0xFF48BB78);
  static const Color fieldBackground = Color(0xFFF0F2F8);

  // Keep old names as aliases for backward-compatibility with screens not yet updated
  static const Color primaryColor = primaryBlue;
  static const Color baseColor = background;
  static const Color darkShadow = Color(0xFFCDD0DB);
  static const Color lightShadow = Colors.white;
  static const Color secondaryColor = Color(0xFF7B8CFF);

  static const double minTouchTarget = 48.0;

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF4A6CF7).withValues(alpha: 0.08),
          offset: const Offset(0, 4),
          blurRadius: 20,
        ),
      ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
        surface: background,
        primary: primaryBlue,
      ),
      scaffoldBackgroundColor: background,
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textColor),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
        headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: textColor),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textColor),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: textColor),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: textColor),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: textColorSecondary),
        labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
        labelMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
        labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textColorSecondary),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        iconTheme: IconThemeData(size: 24, color: Colors.white),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(minTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        labelStyle: const TextStyle(fontSize: 14, color: textColorSecondary),
        hintStyle: const TextStyle(fontSize: 14, color: textColorSecondary),
        prefixIconColor: textColorSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(minTouchTarget, minTouchTarget),
          iconSize: 24,
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minLeadingWidth: 40,
        titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
        subtitleTextStyle: TextStyle(fontSize: 14, color: textColorSecondary),
      ),
      dialogTheme: DialogThemeData(
        titleTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
        contentTextStyle: const TextStyle(fontSize: 16, color: textColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      chipTheme: ChipThemeData(
        selectedColor: primaryBlue,
        backgroundColor: Colors.white,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: primaryBlue.withValues(alpha: 0.3)),
        ),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFE8EAF0), thickness: 1),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      ),
    );
  }
}
