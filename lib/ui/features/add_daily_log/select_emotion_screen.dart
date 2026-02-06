import 'package:flutter/material.dart';
import './add_daily_log_screen.dart';

class SelectEmotionScreen extends StatelessWidget {
  final DateTime selectedDate;

  const SelectEmotionScreen({super.key, required this.selectedDate});

  // Emotion data based on the screenshot provided earlier
  static const List<Map<String, String>> emotions = [
    {'emoji': '😁', 'label': '정말 좋음'},
    {'emoji': '🙂', 'label': '좋음'},
    {'emoji': '😐', 'label': '보통'},
    {'emoji': '😟', 'label': '나쁨'},
    {'emoji': '😠', 'label': '끔찍함'},
  ];

  void _onEmotionSelected(BuildContext context, String emotion) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddDailyLogScreen(
          selectedDate: selectedDate,
          emotion: emotion,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('기분이 어때요?'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 16.0),
        child: Column(
          children: [
            // Header with date and time (placeholders for now)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 8),
                Text('오늘, ${selectedDate.month}월 ${selectedDate.day}일', style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 24),
                const Icon(Icons.access_time, size: 18),
                const SizedBox(width: 8),
                const Text('오후 10:46', style: const TextStyle(fontSize: 16)), // Placeholder time
              ],
            ),
            const Spacer(),
            // Emotion selection row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: emotions.map((emotion) {
                  return InkWell(
                    onTap: () => _onEmotionSelected(context, emotion['label']!),
                    borderRadius: BorderRadius.circular(50),
                    child: Column(
                      children: [
                        Text(emotion['emoji']!, style: const TextStyle(fontSize: 40)),
                        const SizedBox(height: 8),
                        Text(emotion['label']!),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const Spacer(),
            // The theme card has been removed.
          ],
        ),
      ),
    );
  }
}
