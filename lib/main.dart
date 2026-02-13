import 'package:dienos_calendar/ui/theme/app_theme.dart';
import 'package:dienos_calendar/ui/theme/theme_controller.dart';
import 'package:dienos_calendar/utils/prefs_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/features/calendar/calendar_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PrefsUtils.init();
  final themeName = PrefsUtils.getThemeName();

  final savedTheme = AppColorTheme.values.firstWhere(
    (e) => e.name == themeName, // name 비교 (enum name은 저장 시 사용된 name)
    orElse: () => AppColorTheme.warmPink,
  );

  runApp(ProviderScope(overrides: [initialThemeProvider.overrideWithValue(savedTheme)], child: const MyApp()));
}

// ConsumerWidget으로 변경하여 테마 변경을 감지해야 함
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 테마 컨트롤러의 상태(현재 선택된 테마)를 구독
    final currentTheme = ref.watch(themeControllerProvider);

    return MaterialApp(
      title: 'Dienos Calendar',
      theme: AppTheme.getTheme(currentTheme), // 동적 테마 적용
      // Dark Theme도 필요하다면 getDarkTheme(currentTheme) 등을 만들어야 함.
      // 일단은 기본 DarkTheme 사용하거나 LightTheme 강제.
      darkTheme: AppTheme.getDarkTheme(currentTheme),
      themeMode: ThemeMode.system, // 시스템 설정 따름

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', ''), Locale('ko', '')],
      home: const CalendarScreen(),
    );
  }
}
