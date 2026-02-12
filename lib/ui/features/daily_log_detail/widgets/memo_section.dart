import 'package:flutter/material.dart';

class MemoSection extends StatelessWidget {
  final String memo;

  const MemoSection({super.key, required this.memo});

  @override
  Widget build(BuildContext context) {
    if (memo.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notes, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text('메모', style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            ),
            child: Text(memo, style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
          ),
        ],
      ),
    );
  }
}
