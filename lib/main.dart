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
  final savedTheme = AppColorTheme.values.firstWhere((e) => e.name == themeName, orElse: () => AppColorTheme.warmPink);

  final themeModeName = PrefsUtils.getThemeMode();
  final savedThemeMode = AppThemeMode.values.firstWhere(
    (e) => e.name == themeModeName,
    orElse: () => AppThemeMode.system,
  );

  runApp(
    ProviderScope(
      overrides: [
        initialThemeProvider.overrideWithValue(savedTheme),
        initialThemeModeProvider.overrideWithValue(savedThemeMode),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeControllerProvider);

    return MaterialApp(
      title: 'Dienos Calendar',
      theme: AppTheme.getTheme(currentTheme.colorTheme),
      darkTheme: AppTheme.getDarkTheme(currentTheme.colorTheme),
      themeMode: currentTheme.themeMode.mode,
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
