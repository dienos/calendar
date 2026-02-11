import 'package:flutter/material.dart';

class AppTheme {
  static final theme = _buildLightTheme();
  static final darkTheme = _buildDarkTheme();

  static ThemeData _buildLightTheme() {
    // A new color scheme inspired by the user provided image
    final colorScheme = ColorScheme.light(
      primary: const Color(0xFFF97A8D),      // A soft, warm pink/coral for primary actions.
      secondary: const Color(0xFFFABEC5),    // A lighter pink for secondary elements.
      background: const Color(0xFFFDF8F5),    // A very light, off-white/cream background.
      surface: Colors.white,                // Cards are pure white for a clean contrast.
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onBackground: const Color(0xFF333333),   // Dark grey for primary text.
      onSurface: const Color(0xFF333333),
      error: Colors.red.shade400,
      onError: Colors.white,
    );

    return ThemeData.light().copyWith(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onBackground),
        titleTextStyle: TextStyle(
            color: colorScheme.onBackground,
            fontSize: 24,
            fontWeight: FontWeight.bold),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: Colors.grey.shade400,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
      ),
    );
  }

  static ThemeData _buildDarkTheme() {
    // Let's also update the dark theme to match the new branding.
    final colorScheme = ColorScheme.dark(
      primary: const Color(0xFFF97A8D),      // The pink remains the primary color.
      secondary: const Color(0xFFFABEC5),
      background: const Color(0xFF1C1C24),
      surface: const Color(0xFF2A2A38),
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onBackground: Colors.white.withOpacity(0.9),
      onSurface: Colors.white.withOpacity(0.9),
      error: Colors.redAccent,
      onError: Colors.white,
    );

    return ThemeData.dark().copyWith(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.background,
        elevation: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: Colors.grey.shade600,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
      ),
    );
  }
}
