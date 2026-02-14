import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:domain/entities/daily_log_record.dart';
import 'package:intl/intl.dart';

class TrendChart extends StatelessWidget {
  final List<DailyLogRecord> logs;
  final DateTime startDate;
  final DateTime endDate;

  const TrendChart({super.key, required this.logs, required this.startDate, required this.endDate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    final daysInRange = endDate.difference(startDate).inDays + 1;
    final isWeeklyMode = daysInRange > 35; // Logic for adaptive strategy

    // Prepare spots based on mode
    final spots = isWeeklyMode ? _buildWeeklySpots() : _buildDailySpots(daysInRange);

    // X-axis min/max
    final double minX = 0;
    final double maxX = isWeeklyMode ? (spots.isNotEmpty ? spots.last.x : 0) : (daysInRange - 1).toDouble();

    return Padding(
      padding: const EdgeInsets.only(right: 16.0, top: 16.0), // Padding correction
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return isWeeklyMode
                      ? _getWeeklyBottomTitles(value, meta, theme)
                      : _getDailyBottomTitles(value, meta, theme, daysInRange);
                },
                reservedSize: 24, // Compact reserved size
                interval: 1, // Force check every interval
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (spot) => theme.colorScheme.surfaceContainerHighest,
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  return LineTooltipItem(
                    _getEmotionLabel(barSpot.y),
                    TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
                  );
                }).toList();
              },
            ),
          ),
          minX: minX,
          maxX: maxX,
          minY: 0,
          maxY: 6,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              gradient: LinearGradient(colors: [primaryColor, primaryColor.withValues(alpha: 0.5)]),
              barWidth: 3, // Slightly thinner for compactness
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: isWeeklyMode ? 3 : 3, // Constant reasonable size
                  color: primaryColor,
                  strokeWidth: 1.5,
                  strokeColor: theme.colorScheme.surface,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [primaryColor.withValues(alpha: 0.2), primaryColor.withValues(alpha: 0.0)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Daily Mode: 1 spot per day
  List<FlSpot> _buildDailySpots(int daysInRange) {
    final List<FlSpot> spots = [];
    for (int i = 0; i < daysInRange; i++) {
      final date = startDate.add(Duration(days: i));
      final log = logs
          .where((l) => l.date?.year == date.year && l.date?.month == date.month && l.date?.day == date.day)
          .toList();

      if (log.isNotEmpty) {
        double val = _getEmotionValue(log.first.emotion);
        spots.add(FlSpot(i.toDouble(), val));
      }
    }
    return spots;
  }

  // Weekly Mode: 1 spot per week (Average)
  List<FlSpot> _buildWeeklySpots() {
    final List<FlSpot> spots = [];

    // Determine the start of the week for grouping (e.g., align to Monday or just start from startDate)
    // Here we strictly follow 7-day chunks starting from startDate for simplicity in mapping X-axis
    // X-axis value will represent the "Week Index"

    final daysInRange = endDate.difference(startDate).inDays + 1;
    final totalWeeks = (daysInRange / 7).ceil();

    for (int i = 0; i < totalWeeks; i++) {
      final weekStart = startDate.add(Duration(days: i * 7));
      final weekEnd = weekStart.add(const Duration(days: 6));

      // Filter logs in this week window
      final weeklyLogs = logs.where((l) {
        if (l.date == null) return false;
        return !l.date!.isBefore(weekStart) && !l.date!.isAfter(weekEnd);
        // Note: Comparing dates with time might be tricky. Assume logs have dates.
        // Better safe comparison:
        final logDate = DateTime(l.date!.year, l.date!.month, l.date!.day);
        final s = DateTime(weekStart.year, weekStart.month, weekStart.day);
        final e = DateTime(weekEnd.year, weekEnd.month, weekEnd.day);
        return !logDate.isBefore(s) && !logDate.isAfter(e);
      }).toList();

      if (weeklyLogs.isNotEmpty) {
        final avg = weeklyLogs.map((l) => _getEmotionValue(l.emotion)).reduce((a, b) => a + b) / weeklyLogs.length;
        spots.add(FlSpot(i.toDouble(), avg));
      }
    }
    return spots;
  }

  Widget _getDailyBottomTitles(double value, TitleMeta meta, ThemeData theme, int daysInRange) {
    if (daysInRange <= 7) {
      // Show all (1-day interval)
      final date = startDate.add(Duration(days: value.toInt()));
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          DateFormat('MM.dd').format(date),
          style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 10),
        ),
      );
    } else {
      // For ranges > 7 days (e.g. Last 30 Days), show every 7 days as requested.
      const int interval = 7;

      if (value.toInt() % interval != 0) return const SizedBox.shrink();

      final date = startDate.add(Duration(days: value.toInt()));
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          DateFormat('MM.dd').format(date),
          style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 10),
        ),
      );
    }
  }

  Widget _getWeeklyBottomTitles(double value, TitleMeta meta, ThemeData theme) {
    // value is Week Index
    // Show label every ~4 weeks (roughly monthly)
    if (value.toInt() % 4 != 0) return const SizedBox.shrink();

    final weekStart = startDate.add(Duration(days: value.toInt() * 7));
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        DateFormat('MM.dd').format(weekStart),
        style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 10),
      ),
    );
  }

  double _getEmotionValue(String emotion) {
    switch (emotion) {
      case '정말 좋음':
        return 5;
      case '좋음':
        return 4;
      case '보통':
        return 3;
      case '나쁨':
        return 2;
      case '끔찍함':
        return 1;
      default:
        return 3;
    }
  }

  String _getEmotionLabel(double value) {
    if (value >= 4.5) return '정말 좋음';
    if (value >= 3.5) return '좋음';
    if (value >= 2.5) return '보통';
    if (value >= 1.5) return '나쁨';
    return '끔찍함';
  }
}
