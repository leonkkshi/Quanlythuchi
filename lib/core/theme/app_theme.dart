import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const primary = Color(0xFFFCD535);
  static const primaryActive = Color(0xFFF0B90B);
  static const primaryDisabled = Color(0xFF3A3A1F);
  static const canvasDark = Color(0xFF0B0E11);
  static const surfaceCardDark = Color(0xFF1E2329);
  static const surfaceElevatedDark = Color(0xFF2B3139);
  static const canvasLight = Color(0xFFFFFFFF);
  static const surfaceSoftLight = Color(0xFFFAFAFA);
  static const surfaceStrongLight = Color(0xFFF5F5F5);
  static const hairlineOnLight = Color(0xFFEAECED);
  static const hairlineOnDark = Color(0xFF2B3139);
  static const ink = Color(0xFF181A20);
  static const bodyOnDark = Color(0xFFEAECED);
  static const bodyOnLight = Color(0xFF181A20);
  static const muted = Color(0xFF707A8A);
  static const mutedStrong = Color(0xFF929AA5);
  static const onPrimary = Color(0xFF181A20);
  static const onDark = Color(0xFFFFFFFF);
  static const tradingUp = Color(0xFF0ECB81);
  static const tradingDown = Color(0xFFF6465D);
  static const info = Color(0xFF3B82F6);
}

class AppTheme {
  static ThemeData lightTheme() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.canvasLight,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.tradingUp,
        onSecondary: AppColors.onPrimary,
        error: Colors.redAccent,
        onError: Colors.white,
        background: AppColors.canvasLight,
        onBackground: AppColors.ink,
        surface: AppColors.surfaceSoftLight,
        onSurface: AppColors.ink,
      ),
      textTheme: _lightTextTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.ink,
        iconTheme: IconThemeData(color: AppColors.ink),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.canvasLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          side: const BorderSide(color: AppColors.hairlineOnLight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceStrongLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.hairlineOnLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.hairlineOnLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryActive, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.muted),
        hintStyle: const TextStyle(color: AppColors.muted),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceCardDark,
        contentTextStyle: TextStyle(color: AppColors.bodyOnDark),
      ),
      dividerColor: Colors.transparent,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.canvasLight,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.mutedStrong,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
      ),
    );

    return base;
  }

  static ThemeData darkTheme() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.canvasDark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.tradingUp,
        onSecondary: AppColors.onPrimary,
        error: Color(0xFFF6465D),
        onError: Colors.white,
        background: AppColors.canvasDark,
        onBackground: AppColors.bodyOnDark,
        surface: AppColors.surfaceCardDark,
        onSurface: AppColors.bodyOnDark,
      ),
      textTheme: _darkTextTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.onDark,
        iconTheme: IconThemeData(color: AppColors.onDark),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surfaceCardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.onDark,
          side: const BorderSide(color: AppColors.hairlineOnDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceCardDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.hairlineOnDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.hairlineOnDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryActive, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF6465D), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF6465D), width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.mutedStrong),
        hintStyle: const TextStyle(color: AppColors.mutedStrong),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceCardDark,
        contentTextStyle: TextStyle(color: AppColors.bodyOnDark),
      ),
      dividerColor: Colors.transparent,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceCardDark,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.mutedStrong,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
      ),
    );

    return base;
  }

  static const TextTheme _lightTextTheme = TextTheme(
    bodyLarge: TextStyle(color: AppColors.bodyOnLight, fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(color: AppColors.bodyOnLight, fontSize: 14),
    titleLarge: TextStyle(color: AppColors.ink, fontSize: 24, fontWeight: FontWeight.w700),
    titleMedium: TextStyle(color: AppColors.ink, fontSize: 18, fontWeight: FontWeight.w700),
    titleSmall: TextStyle(color: AppColors.ink, fontSize: 14, fontWeight: FontWeight.w600),
    labelLarge: TextStyle(color: AppColors.ink, fontSize: 14, fontWeight: FontWeight.w700),
  );

  static const TextTheme _darkTextTheme = TextTheme(
    bodyLarge: TextStyle(color: AppColors.bodyOnDark, fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(color: AppColors.bodyOnDark, fontSize: 14),
    titleLarge: TextStyle(color: AppColors.onDark, fontSize: 24, fontWeight: FontWeight.w700),
    titleMedium: TextStyle(color: AppColors.onDark, fontSize: 18, fontWeight: FontWeight.w700),
    titleSmall: TextStyle(color: AppColors.onDark, fontSize: 14, fontWeight: FontWeight.w600),
    labelLarge: TextStyle(color: AppColors.onDark, fontSize: 14, fontWeight: FontWeight.w700),
  );
}
