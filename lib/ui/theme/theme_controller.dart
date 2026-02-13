import 'package:dienos_calendar/utils/prefs_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppColorTheme {
  warmPink(
    "웜 핑크",
    Color(0xFFF97A8D),
    [Color(0xFFFDE8EC), Color(0xFFFDF0F2), Color(0xFFFFF6F7), Color(0xFFFFFBFB)],
    Color(0xFFC2185B),
    Color(0xFF880E4F),
    Colors.white70,
    // Dark Mode Colors
    [Color(0xFF2C0E14), Color(0xFF4A192C)],
    Color(0xFFEC407A), // Light Pink for Dark Mode
    Colors.white,
  ),
  softLemon(
    "소프트 레몬",
    Color(0xFFFFF59D),
    [Color(0xFFFFFDE7), Color(0xFFFFF9C4), Color(0xFFFFF59D), Color(0xFFFFF176)],
    Color(0xFF4E342E), // 진한 고동색
    Colors.black87,
    Colors.white70,
    // Dark Mode Colors
    [Color(0xFF3E2723), Color(0xFF5D4037)],
    Color(0xFFFFD54F), // Light Yellow for Dark Mode
    Colors.white,
  ),
  skyBlue(
    "스카이 블루",
    Color(0xFF64B5F6),
    [Color(0xFFE3F2FD), Color(0xFFBBDEFB), Color(0xFF90CAF9), Color(0xFF64B5F6)],
    Color(0xFF1565C0),
    Color(0xFF0D47A1),
    Colors.white70,
    // Dark Mode Colors
    [Color(0xFF0D47A1), Color(0xFF1976D2)], // Deep Blue
    Color(0xFF64B5F6), // Light Blue for Dark Mode
    Colors.white,
  ),
  mintGreen(
    "민트 그린",
    Color(0xFF81C784),
    [Color(0xFFE8F5E9), Color(0xFFC8E6C9), Color(0xFFA5D6A7), Color(0xFF81C784)],
    Color(0xFF2E7D32),
    Color(0xFF1B5E20),
    Colors.white70,
    // Dark Mode Colors
    [Color(0xFF1B5E20), Color(0xFF388E3C)], // Deep Green
    Color(0xFFA5D6A7), // Light Green for Dark Mode
    Colors.white,
  ),
  lavender(
    "라벤더",
    Color(0xFFBA68C8),
    [Color(0xFFF3E5F5), Color(0xFFE1BEE7), Color(0xFFCE93D8), Color(0xFFBA68C8)],
    Color(0xFF7B1FA2),
    Color(0xFF4A148C),
    Colors.white70,
    // Dark Mode Colors
    [Color(0xFF311B92), Color(0xFF512DA8)], // Deep Purple
    Color(0xFFCE93D8), // Light Purple for Dark Mode
    Colors.white,
  ),
  creamyWhite(
    "크리미 화이트",
    Color(0xFFE0E0E0),
    [Color(0xFFFAFAFA), Color(0xFFF5F5F5), Color(0xFFEEEEEE), Color(0xFFE0E0E0)],
    Color(0xFF212121), // 더 진한 검정
    Colors.black87,
    Colors.white70,
    // Dark Mode Colors
    [Color(0xFF121212), Color(0xFF212121)], // Dark Grey
    Color(0xFFE0E0E0), // Light Grey for Dark Mode
    Colors.white,
  );

  final String label;
  final Color primaryColor; // 메인 테마 색상 (라이트 모드 기준)
  final List<Color> gradientColors;
  final Color activeColor;
  final Color textColor;
  final Color navUnselectedColor;

  // Dark Mode Properties
  final List<Color> darkGradientColors;
  final Color darkActiveColor;
  final Color darkTextColor;

  const AppColorTheme(
    this.label,
    this.primaryColor,
    this.gradientColors,
    this.activeColor,
    this.textColor,
    this.navUnselectedColor,
    this.darkGradientColors,
    this.darkActiveColor,
    this.darkTextColor,
  );
}

final initialThemeProvider = Provider<AppColorTheme>((ref) {
  return AppColorTheme.warmPink;
});

class ThemeController extends Notifier<AppColorTheme> {
  @override
  AppColorTheme build() {
    return ref.watch(initialThemeProvider);
  }

  void changeTheme(AppColorTheme theme) {
    state = theme;
    PrefsUtils.setThemeName(theme.name);
  }
}

final themeControllerProvider = NotifierProvider<ThemeController, AppColorTheme>(ThemeController.new);
