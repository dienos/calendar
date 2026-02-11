import 'package:flutter/material.dart';

class MonthlyHighlight extends StatelessWidget {
  const MonthlyHighlight({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
        const _HighlightCard(
          icon: Icons.favorite,
          iconColor: Colors.pinkAccent,
          title: "기분 입력",
          count: "20회",
          subtitle: "이번 달 꾸준히 기록하셨네요!",
        ),
        const SizedBox(height: 8),
        const _HighlightCard(
          icon: Icons.drive_file_rename_outline,
          iconColor: Colors.orangeAccent,
          title: "메모 작성",
          count: "15개",
          subtitle: "솔직한 마음들을 많이 담았어요",
        ),
        const SizedBox(height: 8),
        const _HighlightCard(
          icon: Icons.camera_alt,
          iconColor: Colors.redAccent,
          title: "사진 등록",
          count: "8장",
          subtitle: "소중한 순간들을 포착했어요",
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
