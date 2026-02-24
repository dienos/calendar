import 'package:dienos_calendar/ui/features/add_daily_log/add_daily_log_screen.dart';
import 'package:dienos_calendar/ui/features/daily_log_detail/daily_log_detail_screen.dart';
import 'package:dienos_calendar/ui/theme/app_theme.dart';
import 'package:dienos_calendar/ui/theme/theme_controller.dart';
import 'package:dienos_calendar/utils/prefs_utils.dart';
import 'package:dienos_calendar/utils/widget_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'providers.dart';
import 'ui/features/calendar/calendar_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PrefsUtils.init();
  await WidgetService.initialize();

  final themeName = PrefsUtils.getThemeName();
  final savedTheme = AppColorTheme.values.firstWhere((e) => e.name == themeName, orElse: () => AppColorTheme.warmPink);

  final themeModeName = PrefsUtils.getThemeMode();
  final savedThemeMode = AppThemeMode.values.firstWhere(
    (e) => e.name == themeModeName,
    orElse: () => AppThemeMode.system,
  );

  final initialUri = await HomeWidget.initiallyLaunchedFromHomeWidget();

  runApp(
    ProviderScope(
      overrides: [
        initialThemeProvider.overrideWithValue(savedTheme),
        initialThemeModeProvider.overrideWithValue(savedThemeMode),
      ],
      child: MyApp(initialUri: initialUri),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  final Uri? initialUri;

  const MyApp({super.key, this.initialUri});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialUri != null) {
        _handleWidgetUri(widget.initialUri!);
      }
      HomeWidget.widgetClicked.listen((uri) {
        if (uri != null) _handleWidgetUri(uri);
      });
    });
  }

  void _handleWidgetUri(Uri uri) async {
    print('Widget clicked with URI: $uri');
    final dateStr = uri.queryParameters['date'];
    if (dateStr == null) {
      print('Widget URI: dateStr is null');
      return;
    }
    final date = DateTime.tryParse(dateStr);
    if (date == null) {
      print('Widget URI: failed to parse date $dateStr');
      return;
    }
    // DB 조회 시 일관성을 위해 UTC 자정으로 변환
    final utcDate = DateTime.utc(date.year, date.month, date.day);
    print('Widget Date (Local): $date, (UTC): $utcDate');

    // DB가 준비될 때까지 잠시 대기 (FutureProvider가 완료될 시간을 벌어줌)
    // 좀 더 확실한 방법은 ref.read(appDatabaseProvider.future)를 기다리는 것입니다.
    try {
      print('Waiting for database readiness...');
      await ref.read(appDatabaseProvider.future);
      print('Database is ready.');
    } catch (e) {
      print('Error waiting for database: $e');
    }

    final useCase = ref.read(getDailyLogDetailUseCaseProvider);
    final record = await useCase(utcDate);
    print('DailyLogRecord for $utcDate: $record');

    final context = _navigatorKey.currentContext;
    if (context == null || !context.mounted) {
      print('Navigator context is not available or not mounted');
      return;
    }

    // 기존에 열려있는 화면이 있다면 닫고 캘린더 화면(Root)으로 돌아간 뒤 이동
    print('Popping to first route...');
    Navigator.of(context).popUntil((route) => route.isFirst);

    if (record != null) {
      print('Navigating to Detail Screen');
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => DailyLogDetailScreen(date: utcDate)));
    } else {
      print('Navigating to Add Screen');
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddDailyLogScreen(selectedDate: utcDate)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeControllerProvider);

    return MaterialApp(
      navigatorKey: _navigatorKey,
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
