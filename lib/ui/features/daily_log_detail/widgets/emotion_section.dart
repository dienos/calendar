import 'package:dienos_calendar/ui/features/add_daily_log/add_daily_log_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EmotionSection extends StatelessWidget {
  final String emotion;

  const EmotionSection({super.key, required this.emotion});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final emotionEntry = emotions.firstWhere(
      (e) => e['label'] == emotion,
      orElse: () => {},
    );
    final svgPath = emotionEntry['svgPath'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7E0),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Column(
            children: [
              if (svgPath != null)
                SvgPicture.asset(svgPath, width: 80, height: 80),
              const SizedBox(height: 16),
              Chip(
                label: Text(emotion, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary)),
                backgroundColor: Colors.white,
                side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.5)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
