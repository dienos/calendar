import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:dienos_calendar/ui/common/gradient_background.dart';
import 'package:dienos_calendar/ui/common/glassy_container.dart';
import 'package:dienos_calendar/ui/features/statistics/statistics_view_model.dart';
import 'package:dienos_calendar/ui/features/statistics/widgets/trend_chart.dart';
import 'package:dienos_calendar/ui/features/statistics/widgets/distribution_chart.dart';
import 'package:dienos_calendar/ui/features/statistics/widgets/statistics_range_picker_dialog.dart';
import 'package:table_calendar/table_calendar.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(statisticsViewModelProvider);
    final viewModel = ref.read(statisticsViewModelProvider.notifier);
    final theme = Theme.of(context);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            '통계', // Title changed
            style: TextStyle(color: theme.textTheme.titleLarge?.color, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
        ),
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 24), // Added top padding 10
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '기분 변화 추이',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ), // Adjusted font size
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _showRangePicker(context, viewModel, state),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), // Compact padding
                              decoration: BoxDecoration(
                                color: theme.colorScheme.onSurface.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.1)),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    _getRangeText(state.startDate, state.endDate),
                                    style: TextStyle(
                                      fontSize: 12, // Compact font size
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.keyboard_arrow_down, size: 16, color: theme.colorScheme.primary),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Trend Chart (Expanded to fill available space)
                    Expanded(
                      flex: 3, // Reduced flex from 4 to 3 to decrease height
                      child: TrendChart(logs: state.logs, startDate: state.startDate, endDate: state.endDate),
                    ),
                    const SizedBox(height: 16), // Reduced vertical spacing from 24 to 16
                    const Text(
                      '기분 분포',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ), // Adjusted font size
                    const SizedBox(height: 12),
                    // Distribution Chart (Expanded to fill available space)
                    Expanded(
                      flex: 4, // Reduced flex from 5 to 4 to match proportion
                      child: GlassyContainer(
                        width: double.infinity,
                        padding: EdgeInsets.zero,
                        child: Center(
                          // Center content
                          child: SingleChildScrollView(
                            // Allow internal scrolling if screen is very small
                            physics: const ClampingScrollPhysics(),
                            child: DistributionChart(logs: state.logs),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  String _getRangeText(DateTime start, DateTime end) {
    if (isSameDay(end, DateTime.now())) {
      final diff = end.difference(start).inDays + 1;
      if (diff == 7) return '7일';
      if (diff == 30) return '30일';
    }

    return '${DateFormat('MM.dd').format(start)} - ${DateFormat('MM.dd').format(end)}';
  }

  Future<void> _showRangePicker(BuildContext context, StatisticsViewModel viewModel, StatisticsState state) async {
    final DateTimeRange? picked = await showDialog<DateTimeRange>(
      context: context,
      builder: (context) =>
          StatisticsRangePickerDialog(initialStartDate: state.startDate, initialEndDate: state.endDate),
    );

    if (picked != null) {
      viewModel.updateRange(picked.start, picked.end);
    }
  }
}
