import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/features/calendar/calendar_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memo Calendar by dienos',
      theme: ThemeData(
        // 앱의 전체 테마 색상을 분홍색 톤으로 변경합니다.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('ko', ''), // Korean
      ],
      home: const CalendarScreen(),
    );
  }
}
