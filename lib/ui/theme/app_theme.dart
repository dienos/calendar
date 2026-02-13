import 'package:dienos_calendar/ui/theme/theme_controller.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData getTheme(AppColorTheme colorTheme) {
    final colorScheme = ColorScheme.light(
      primary: colorTheme.activeColor,
      secondary: colorTheme.activeColor.withOpacity(0.7),
      background: colorTheme.gradientColors.last,
      surface: Colors.white,
      onPrimary: colorTheme.navUnselectedColor,
      onSecondary: Colors.white,
      onBackground: colorTheme.textColor,
      onSurface: colorTheme.textColor,
      error: Colors.red.shade400,
      onError: Colors.white,
    );

    return ThemeData.light().copyWith(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,

      textTheme: ThemeData.light().textTheme.apply(bodyColor: colorTheme.textColor, displayColor: colorTheme.textColor),

      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colorTheme.textColor),
        titleTextStyle: TextStyle(color: colorTheme.textColor, fontSize: 24, fontWeight: FontWeight.bold),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: colorTheme.activeColor,
        unselectedItemColor: colorTheme.navUnselectedColor,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(color: colorTheme.activeColor, fontSize: 12, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(color: colorTheme.navUnselectedColor, fontSize: 12),
      ),
    );
  }

  static ThemeData getDarkTheme(AppColorTheme colorTheme) {
    final colorScheme = ColorScheme.dark(
      primary: colorTheme.darkActiveColor,
      secondary: colorTheme.darkActiveColor.withOpacity(0.7),
      background: colorTheme.darkGradientColors.last,
      surface: Colors.grey[900]!, // 다크 모드 카드 배경
      onPrimary: Colors.black, // ActiveColor가 밝은 색일 수 있으므로 검정
      onSecondary: Colors.black,
      onBackground: colorTheme.darkTextColor,
      onSurface: colorTheme.darkTextColor,
      error: Colors.red.shade400,
      onError: Colors.black,
    );

    return ThemeData.dark().copyWith(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,

      textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: colorTheme.darkTextColor,
        displayColor: colorTheme.darkTextColor,
      ),

      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colorTheme.darkTextColor),
        titleTextStyle: TextStyle(color: colorTheme.darkTextColor, fontSize: 24, fontWeight: FontWeight.bold),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: colorTheme.darkActiveColor,
        unselectedItemColor: Colors.white54, // 다크 모드에서는 조금 더 밝은 회색
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(color: colorTheme.darkActiveColor, fontSize: 12, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(color: Colors.white54, fontSize: 12),
      ),
    );
  }
}
