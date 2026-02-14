import 'package:flutter/material.dart';
import 'package:domain/entities/daily_log_record.dart';

class DistributionChart extends StatelessWidget {
  final List<DailyLogRecord> logs;

  const DistributionChart({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final emotionCounts = _calculateDistribution();
    final total = logs.length;

    // Remove the Container with decoration. Just return the Column with padding.
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: emotionCounts.entries.map((entry) {
          final count = entry.value;
          final percentage = total > 0 ? (count / total) : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: _getEmotionColor(entry.key, theme)),
                        ),
                        const SizedBox(width: 8),
                        Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                    Text('${(percentage * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(_getEmotionColor(entry.key, theme)),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Map<String, int> _calculateDistribution() {
    final Map<String, int> counts = {'정말 좋음': 0, '좋음': 0, '보통': 0, '나쁨': 0, '끔찍함': 0};

    for (var log in logs) {
      if (counts.containsKey(log.emotion)) {
        counts[log.emotion] = counts[log.emotion]! + 1;
      }
    }
    return counts;
  }

  Color _getEmotionColor(String emotion, ThemeData theme) {
    switch (emotion) {
      case '정말 좋음':
        return theme.colorScheme.primary;
      case '좋음':
        return theme.colorScheme.primary.withOpacity(0.8);
      case '보통':
        return theme.colorScheme.primary.withOpacity(0.6);
      case '나쁨':
        return theme.colorScheme.primary.withOpacity(0.4);
      case '끔찍함':
        return theme.colorScheme.primary.withOpacity(0.2);
      default:
        return theme.colorScheme.primary;
    }
  }
}
