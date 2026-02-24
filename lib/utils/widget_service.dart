import 'package:domain/entities/daily_log_record.dart';
import 'package:domain/usecases/get_events_usecase.dart';
import 'package:home_widget/home_widget.dart';

class WidgetService {
  static const _androidProviderName = 'com.dienos.calendar.HomeWidgetProvider';

  static Future<void> initialize() async {
    await HomeWidget.setAppGroupId('group.com.dienos.dienosCalendar');
    await HomeWidget.registerInteractivityCallback(_backgroundCallback);
  }

  static Future<void> update(GetEventsUseCase getEventsUseCase) async {
    try {
      final allEvents = await getEventsUseCase();
      final today = DateTime.now();
      final weekStart = DateTime.utc(today.year, today.month, today.day).subtract(const Duration(days: 6));

      for (var i = 0; i < 7; i++) {
        final dateKey = weekStart.add(Duration(days: i));
        final records = allEvents[dateKey] ?? [];
        final log = records.whereType<DailyLogRecord>().firstOrNull;

        String emotionKey = '';
        if (log != null) {
          switch (log.emotion) {
            case '정말 좋음':
              emotionKey = 'very_good';
              break;
            case '좋음':
              emotionKey = 'good';
              break;
            case '보통':
              emotionKey = 'soso';
              break;
            case '나쁨':
              emotionKey = 'bad';
              break;
            case '끔찍함':
              emotionKey = 'very_bad';
              break;
          }
        }

        await HomeWidget.saveWidgetData<String>('emotion_$i', emotionKey);
      }

      await HomeWidget.updateWidget(androidName: _androidProviderName, qualifiedAndroidName: _androidProviderName);
    } catch (_) {}
  }

  static Future<void> requestWidgetPin() async {
    try {
      final isSupported = await HomeWidget.isRequestPinWidgetSupported();
      print('WidgetService: isRequestPinWidgetSupported: $isSupported');
      print('WidgetService: Requesting widget pin for $_androidProviderName');
      await HomeWidget.requestPinWidget(androidName: _androidProviderName, qualifiedAndroidName: _androidProviderName);
    } catch (e) {
      print('WidgetService: Failed to request widget pin: $e');
    }
  }
}

@pragma('vm:entry-point')
void _backgroundCallback(Uri? uri) {}
