import 'package:dienos_calendar/providers.dart';
import 'package:dienos_calendar/ui/common/stat_card.dart';
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
      cards.add(
        StatCard(
          icon: Icons.favorite,
          iconColor: Colors.pinkAccent,
          title: "기분 입력",
          count: "${stats.moodEntries}회",
          subtitle: "이번 달 꾸준히 기록하셨네요!",
        ),
      );
    }
    if (stats.memoEntries > 0) {
      cards.add(
        StatCard(
          icon: Icons.drive_file_rename_outline,
          iconColor: Colors.orangeAccent,
          title: "메모 작성",
          count: "${stats.memoEntries}개",
          subtitle: "솔직한 마음들을 많이 담았어요",
        ),
      );
    }
    if (stats.photoEntries > 0) {
      cards.add(
        StatCard(
          icon: Icons.camera_alt,
          iconColor: Colors.redAccent,
          title: "사진 등록",
          count: "${stats.photoEntries}장",
          subtitle: "소중한 순간들을 포착했어요",
        ),
      );
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
            style: theme.textTheme.titleMedium?.copyWith(
              color: const Color(0xFF6B6B6B),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          itemBuilder: (context, index) => cards[index],
          separatorBuilder: (context, index) => const SizedBox(height: 12),
        ),
      ],
    );
  }
}
