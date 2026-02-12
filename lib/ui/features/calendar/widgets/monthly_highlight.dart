import 'package:dienos_calendar/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MonthlyHighlight extends ConsumerWidget {
  const MonthlyHighlight({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final focusedMonth = ref.watch(calendarViewModelProvider.select((state) => state.focusedDay));
    final stats = ref.watch(monthlyStatsProvider(focusedMonth));

    final List<Widget> cards = [];

    if (stats.moodEntries > 0) {
      cards.add(_HighlightCard(
        icon: Icons.favorite,
        iconColor: Colors.pinkAccent,
        title: "기분 입력",
        count: "${stats.moodEntries}회",
        subtitle: "이번 달 꾸준히 기록하셨네요!",
      ));
    }
    if (stats.memoEntries > 0) {
      cards.add(_HighlightCard(
        icon: Icons.drive_file_rename_outline,
        iconColor: Colors.orangeAccent,
        title: "메모 작성",
        count: "${stats.memoEntries}개",
        subtitle: "솔직한 마음들을 많이 담았어요",
      ));
    }
    if (stats.photoEntries > 0) {
      cards.add(_HighlightCard(
        icon: Icons.camera_alt,
        iconColor: Colors.redAccent,
        title: "사진 등록",
        count: "${stats.photoEntries}장", // Currently 0
        subtitle: "소중한 순간들을 포착했어요",
      ));
    }

    if (cards.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            "이달의 하이라이트",
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          itemBuilder: (context, index) => cards[index],
          separatorBuilder: (context, index) => const SizedBox(height: 8),
        ),
      ],
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.count,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String count;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text(
                      count,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: iconColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
