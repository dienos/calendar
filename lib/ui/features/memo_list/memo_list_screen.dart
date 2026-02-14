import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:dienos_calendar/ui/common/gradient_background.dart';
import 'package:dienos_calendar/ui/common/glassy_expansion_tile.dart';
import 'package:dienos_calendar/ui/common/month_selector.dart';
import 'package:dienos_calendar/ui/features/memo_list/memo_list_view_model.dart';
import 'package:domain/entities/daily_log_record.dart';

class MemoListScreen extends ConsumerStatefulWidget {
  final DateTime? focusedMonth;

  const MemoListScreen({super.key, this.focusedMonth});

  @override
  ConsumerState<MemoListScreen> createState() => _MemoListScreenState();
}

class _MemoListScreenState extends ConsumerState<MemoListScreen> {
  late List<DateTime> _months;
  final DateTime _now = DateTime.now();
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Generate last 12 months
    _months = List.generate(12, (index) {
      return DateTime(_now.year, _now.month - index, 1);
    });

    // Find initial index based on focusedMonth
    final initialMonth = widget.focusedMonth ?? _now;
    int initialIndex = _months.indexWhere((m) => m.year == initialMonth.year && m.month == initialMonth.month);
    if (initialIndex == -1) initialIndex = 0;

    _currentIndex = initialIndex;
    _pageController = PageController(initialPage: initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onMonthSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "작성한 메모 모아보기",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.search, color: theme.colorScheme.onSurface),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('검색 기능은 준비 중입니다.')));
              },
            ),
          ],
        ),
        body: Column(
          children: [
            MonthSelector(months: _months, selectedIndex: _currentIndex, onMonthSelected: _onMonthSelected),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _months.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _MemoListPage(month: _months[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemoListPage extends ConsumerWidget {
  final DateTime month;

  const _MemoListPage({required this.month});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(memoListViewModelProvider(month));
    final theme = Theme.of(context);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.logs.isEmpty) {
      return Center(
        child: Text(
          "작성된 메모가 없습니다.",
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5)),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.logs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _MemoItem(log: state.logs[index]);
      },
    );
  }
}

class _MemoItem extends StatelessWidget {
  final DailyLogRecord log;

  const _MemoItem({required this.log});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('yyyy.MM.dd (E)', 'ko_KR').format(log.date ?? DateTime.now());

    return GlassyExpansionTile(
      title: Row(
        children: [
          Icon(Icons.calendar_today_outlined, size: 16, color: theme.colorScheme.primary.withOpacity(0.9)),
          const SizedBox(width: 12),
          Text(
            dateStr,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
      childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        SelectableText(
          log.memo,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.8),
            height: 1.6,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
