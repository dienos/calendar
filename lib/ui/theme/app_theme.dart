import 'package:dienos_calendar/ui/theme/theme_controller.dart';
import 'package:flutter/material.dart';

class AppShadowTheme extends ThemeExtension<AppShadowTheme> {
  final Color color;
  final double blur;
  final double y;

  AppShadowTheme({required this.color, required this.blur, required this.y});

  @override
  ThemeExtension<AppShadowTheme> copyWith({Color? color, double? blur, double? y}) {
    return AppShadowTheme(color: color ?? this.color, blur: blur ?? this.blur, y: y ?? this.y);
  }

  @override
  ThemeExtension<AppShadowTheme> lerp(ThemeExtension<AppShadowTheme>? other, double t) {
    if (other is! AppShadowTheme) return this;
    return AppShadowTheme(
      color: Color.lerp(color, other.color, t)!,
      blur: lerpDouble(blur, other.blur, t)!,
      y: lerpDouble(y, other.y, t)!,
    );
  }

  double? lerpDouble(double? a, double? b, double t) {
    if (a == null && b == null) return null;
    a ??= 0.0;
    b ??= 0.0;
    return a + (b - a) * t;
  }
}

class AppTheme {
  static ThemeData getTheme(AppColorTheme colorTheme) {
    final colorScheme = ColorScheme.light(
      primary: colorTheme.activeColor,
      secondary: colorTheme.primaryColor,
      background: colorTheme.gradientColors.last,
      surface: colorTheme.cardColor,
      onPrimary: Colors.white,
      onSecondary: colorTheme.textColor,
      onBackground: colorTheme.textColor,
      onSurface: colorTheme.textColor,
      error: Colors.red.shade400,
      onError: Colors.white,
    );

    return ThemeData.light().copyWith(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,
      iconTheme: IconThemeData(color: colorTheme.activeColor),
      textTheme: ThemeData.light().textTheme.apply(bodyColor: colorTheme.textColor, displayColor: colorTheme.textColor),
      cardTheme: CardThemeData(
        color: colorTheme.cardColor,
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
      extensions: [AppShadowTheme(color: colorTheme.shadowColor, blur: colorTheme.shadowBlur, y: colorTheme.shadowY)],
    );
  }

  static ThemeData getDarkTheme(AppColorTheme colorTheme) {
    final colorScheme = ColorScheme.dark(
      primary: colorTheme.darkActiveColor,
      secondary: colorTheme.primaryColorDark,
      background: colorTheme.darkGradientColors.first,
      surface: colorTheme.darkCardColor,
      onPrimary: Colors.white,
      onSecondary: colorTheme.darkTextColor,
      onBackground: colorTheme.darkTextColor,
      onSurface: colorTheme.darkTextColor,
      error: Colors.red.shade400,
      onError: Colors.white,
    );

    return ThemeData.dark().copyWith(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,
      iconTheme: IconThemeData(color: colorTheme.darkActiveColor),
      textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: colorTheme.darkTextColor,
        displayColor: colorTheme.darkTextColor,
      ),
      cardTheme: CardThemeData(
        color: colorTheme.darkCardColor,
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
        unselectedItemColor: Colors.white54,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(color: colorTheme.darkActiveColor, fontSize: 12, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(color: Colors.white54, fontSize: 12),
      ),
      extensions: [
        AppShadowTheme(color: colorTheme.darkShadowColor, blur: colorTheme.darkShadowBlur, y: colorTheme.darkShadowY),
      ],
    );
  }
}
