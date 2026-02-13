import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:domain/entities/daily_log_record.dart';
import 'package:dienos_calendar/providers.dart';
import 'package:dienos_calendar/ui/common/gradient_background.dart';
import 'package:dienos_calendar/ui/common/glassy_container.dart';

class EmotionListScreen extends ConsumerStatefulWidget {
  final DateTime focusedMonth;

  const EmotionListScreen({super.key, required this.focusedMonth});

  @override
  ConsumerState<EmotionListScreen> createState() => _EmotionListScreenState();
}

class _EmotionListScreenState extends ConsumerState<EmotionListScreen> {
  late PageController _pageController;
  late int _currentIndex;
  final DateTime _now = DateTime.now();
  late List<DateTime> _months;

  final Map<String, String> _emotionIcons = {
    '매우 좋음': 'assets/svgs/emotion_very_good.svg',
    '좋음': 'assets/svgs/emotion_good.svg',
    '보통': 'assets/svgs/emotion_soso.svg',
    '나쁨': 'assets/svgs/emotion_bad.svg',
    '매우 나쁨': 'assets/svgs/emotion_very_bad.svg',
  };

  final Map<String, Color> _emotionColors = {
    '매우 좋음': const Color(0xFF00C896),
    '좋음': const Color(0xFF00C896),
    '보통': Colors.grey,
    '나쁨': Colors.orangeAccent,
    '매우 나쁨': Colors.redAccent,
  };

  final Map<String, String> _emotionTitles = {
    '매우 좋음': '최고의 하루!',
    '좋음': '기분 좋은 하루',
    '보통': '평온한 하루',
    '나쁨': '조금 힘든 하루',
    '매우 나쁨': '지친 하루',
  };

  @override
  void initState() {
    super.initState();
    // 현재 월부터 과거 12개월 생성
    _months = List.generate(12, (index) {
      return DateTime(_now.year, _now.month - index, 1);
    });

    // focusedMonth에 해당하는 인덱스 찾기
    int initialIndex = _months.indexWhere(
      (m) => m.year == widget.focusedMonth.year && m.month == widget.focusedMonth.month,
    );

    if (initialIndex == -1) initialIndex = 0; // 못 찾으면 현재 월

    _currentIndex = initialIndex;
    _pageController = PageController(initialPage: initialIndex, viewportFraction: 1.0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onMonthSelected(int index) {
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // GradientBackground 적용하여 배경색 문제 해결
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
            "기분 기록 리스트",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          // Actions 제거 (타이틀 ... 제거)
        ),
        body: Column(
          children: [
            _buildMonthSelector(theme),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _months.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                  // MonthSelector 스크롤 동기화가 필요할 수 있음
                },
                itemBuilder: (context, index) {
                  return _TimelinePage(
                    month: _months[index],
                    emotionIcons: _emotionIcons,
                    emotionColors: _emotionColors,
                    emotionTitles: _emotionTitles,
                  );
                },
              ),
            ),
          ],
        ),
        // FloatingActionButton 제거
      ),
    );
  }

  Widget _buildMonthSelector(ThemeData theme) {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        scrollDirection: Axis.horizontal,
        itemCount: _months.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final month = _months[index];
          final isSelected = index == _currentIndex;

          return GestureDetector(
            onTap: () => _onMonthSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? theme.colorScheme.primary.withOpacity(0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: isSelected ? Border.all(color: theme.colorScheme.primary.withOpacity(0.5)) : null,
              ),
              child: Center(
                child: Text(
                  "${month.month}월",
                  style: TextStyle(
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.5),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TimelinePage extends ConsumerWidget {
  final DateTime month;
  final Map<String, String> emotionIcons;
  final Map<String, Color> emotionColors;
  final Map<String, String> emotionTitles;

  const _TimelinePage({
    required this.month,
    required this.emotionIcons,
    required this.emotionColors,
    required this.emotionTitles,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final logsAsync = ref.watch(emotionListViewModelProvider(month));

    return logsAsync.when(
      data: (logs) {
        if (logs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 48, color: theme.colorScheme.onSurface.withOpacity(0.2)),
                const SizedBox(height: 16),
                Text(
                  "기록된 기분이 없습니다.",
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            final isLast = index == logs.length - 1;
            final iconPath = emotionIcons[log.emotion] ?? 'assets/svgs/emotion_soso.svg';
            final accentColor = emotionColors[log.emotion] ?? theme.colorScheme.primary;
            final title = emotionTitles[log.emotion] ?? log.emotion;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline Column
                  SizedBox(
                    width: 40,
                    child: Column(
                      children: [
                        // Icon Circle
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: accentColor, width: 2),
                            // 배경은 투명하게 하여 그라데이션이 보이게 하거나, 배경색으로 채움
                            color: Colors.transparent,
                          ),
                          // SVG에 배경색이 없다면 뒤에 원을 하나 더 그려야 할 수도 있음
                          // 여기선 단순히 아이콘 표시
                          padding: const EdgeInsets.all(8),
                          child: SvgPicture.asset(iconPath),
                        ),
                        // Line
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: accentColor.withOpacity(0.3),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date Header
                          Row(
                            children: [
                              Text(
                                DateFormat('MM월 dd일 EEEE', 'ko_KR').format(log.date ?? DateTime.now()),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface, // 텍스트 색상 테마 따름
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                DateFormat('a h:mm', 'ko_KR').format(log.date ?? DateTime.now()),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Card with Glassy effect
                          GlassyContainer(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: accentColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  log.memo.isNotEmpty ? log.memo : "작성된 메모가 없습니다.",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                  maxLines: 5,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
