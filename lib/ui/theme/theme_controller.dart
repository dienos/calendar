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
    AppColors.warmPinkCard,
    AppColors.warmPinkCardDark,
    Color(0x20880E4F),
    20.0,
    8.0,
    Color(0x60000000),
    25.0,
    10.0,
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
    AppColors.softLemonCard,
    AppColors.softLemonCardDark,
    Color(0x154E342E),
    18.0,
    6.0,
    Color(0x50000000),
    25.0,
    10.0,
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
    AppColors.skyBlueCard,
    AppColors.skyBlueCardDark,
    Color(0x150D47A1),
    20.0,
    8.0,
    Color(0x50000000),
    25.0,
    10.0,
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
    AppColors.mintGreenCard,
    AppColors.mintGreenCardDark,
    Color(0x151B5E20),
    20.0,
    8.0,
    Color(0x50000000),
    25.0,
    10.0,
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
    AppColors.lavenderCard,
    AppColors.lavenderCardDark,
    Color(0x204A148C),
    20.0,
    8.0,
    Color(0x55000000),
    25.0,
    10.0,
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
    AppColors.creamyWhiteCard,
    AppColors.creamyWhiteCardDark,
    Color(0x15000000),
    25.0,
    10.0,
    Color(0x60000000),
    30.0,
    12.0,
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
  final Color cardColor;
  final Color darkCardColor;

  final Color shadowColor;
  final double shadowBlur;
  final double shadowY;
  final Color darkShadowColor;
  final double darkShadowBlur;
  final double darkShadowY;

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
    this.cardColor,
    this.darkCardColor,
    this.shadowColor,
    this.shadowBlur,
    this.shadowY,
    this.darkShadowColor,
    this.darkShadowBlur,
    this.darkShadowY,
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
