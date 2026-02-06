import 'package:flutter/material.dart';
import 'package:domain/entities/daily_log_record.dart';
import 'package:intl/intl.dart';

class DailyLogListScreen extends StatelessWidget {
  final DateTime date;
  final List<DailyLogRecord> logs;

  const DailyLogListScreen({super.key, required this.date, required this.logs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('yyyy년 MM월 dd일').format(date)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          return Card(
            elevation: 2.0,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              leading: Text(log.emotion, style: const TextStyle(fontSize: 24)), // Placeholder for emotion emoji
              title: Text(log.memo),
              subtitle: const Text('활동, 사진, 음성메모 등...'), // Placeholder
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  // TODO: Implement edit/delete functionality
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add another log for this day, possibly SelectEmotionScreen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
