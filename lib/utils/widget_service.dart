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
      final weekStart = today.subtract(const Duration(days: 6));

      for (var i = 0; i < 7; i++) {
        final date = weekStart.add(Duration(days: i));
        final dateKey = DateTime.utc(date.year, date.month, date.day);
        final records = allEvents[dateKey] ?? [];
        final log = records.whereType<DailyLogRecord>().firstOrNull;

        final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

        await HomeWidget.saveWidgetData<String>('date_$i', dateStr);
        await HomeWidget.saveWidgetData<String>('emotion_$i', log?.emotion ?? '');
      }

      await HomeWidget.updateWidget(androidName: _androidProviderName);
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
