import 'package:dienos_calendar/ui/theme/app_colors.dart';
import 'package:dienos_calendar/utils/prefs_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppThemeMode {
  system("시스템 설정", ThemeMode.system),
  light("라이트 모드", ThemeMode.light),
  dark("다크 모드", ThemeMode.dark);

  final String label;
  final ThemeMode mode;
  const AppThemeMode(this.label, this.mode);
}

enum AppColorTheme {
  warmPink(
    "웜 핑크",
    AppColors.warmPinkPrimary,
    AppColors.warmPinkGradients,
    AppColors.warmPinkActive,
    AppColors.warmPinkText,
    AppColors.white70,
    AppColors.warmPinkPrimaryDark,
    AppColors.warmPinkGradientsDark,
    AppColors.warmPinkActiveDark,
    AppColors.warmPinkTextDark,
  ),
  softLemon(
    "소프트 레몬",
    AppColors.softLemonPrimary,
    AppColors.softLemonGradients,
    AppColors.softLemonActive,
    AppColors.softLemonText,
    AppColors.white70,
    AppColors.softLemonPrimaryDark,
    AppColors.softLemonGradientsDark,
    AppColors.softLemonActiveDark,
    AppColors.softLemonTextDark,
  ),
  skyBlue(
    "스카이 블루",
    AppColors.skyBluePrimary,
    AppColors.skyBlueGradients,
    AppColors.skyBlueActive,
    AppColors.skyBlueText,
    AppColors.white70,
    AppColors.skyBluePrimaryDark,
    AppColors.skyBlueGradientsDark,
    AppColors.skyBlueActiveDark,
    AppColors.skyBlueTextDark,
  ),
  mintGreen(
    "민트 그린",
    AppColors.mintGreenPrimary,
    AppColors.mintGreenGradients,
    AppColors.mintGreenActive,
    AppColors.mintGreenText,
    AppColors.white70,
    AppColors.mintGreenPrimaryDark,
    AppColors.mintGreenGradientsDark,
    AppColors.mintGreenActiveDark,
    AppColors.mintGreenTextDark,
  ),
  lavender(
    "라벤더",
    AppColors.lavenderPrimary,
    AppColors.lavenderGradients,
    AppColors.lavenderActive,
    AppColors.lavenderText,
    AppColors.white70,
    AppColors.lavenderPrimaryDark,
    AppColors.lavenderGradientsDark,
    AppColors.lavenderActiveDark,
    AppColors.lavenderTextDark,
  ),
  creamyWhite(
    "크리미 화이트",
    AppColors.creamyWhitePrimary,
    AppColors.creamyWhiteGradients,
    AppColors.creamyWhiteActive,
    AppColors.creamyWhiteText,
    AppColors.white70,
    AppColors.creamyWhitePrimaryDark,
    AppColors.creamyWhiteGradientsDark,
    AppColors.creamyWhiteActiveDark,
    AppColors.creamyWhiteTextDark,
  );

  final String label;
  final Color primaryColor;
  final List<Color> gradientColors;
  final Color activeColor;
  final Color textColor;
  final Color navUnselectedColor;

  final Color primaryColorDark;
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
    this.primaryColorDark,
    this.darkGradientColors,
    this.darkActiveColor,
    this.darkTextColor,
  );
}

final initialThemeProvider = Provider<AppColorTheme>((ref) {
  return AppColorTheme.warmPink;
});

final initialThemeModeProvider = Provider<AppThemeMode>((ref) {
  return AppThemeMode.system;
});

class ThemeState {
  final AppColorTheme colorTheme;
  final AppThemeMode themeMode;

  ThemeState({required this.colorTheme, required this.themeMode});

  ThemeState copyWith({AppColorTheme? colorTheme, AppThemeMode? themeMode}) {
    return ThemeState(colorTheme: colorTheme ?? this.colorTheme, themeMode: themeMode ?? this.themeMode);
  }
}

class ThemeController extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    return ThemeState(colorTheme: ref.watch(initialThemeProvider), themeMode: ref.watch(initialThemeModeProvider));
  }

  void changeTheme(AppColorTheme theme) {
    state = state.copyWith(colorTheme: theme);
    PrefsUtils.setThemeName(theme.name);
  }

  void changeThemeMode(AppThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    PrefsUtils.setThemeMode(mode.name);
  }
}

final themeControllerProvider = NotifierProvider<ThemeController, ThemeState>(ThemeController.new);
