import 'package:dienos_calendar/ui/common/glassy_container.dart';
import 'package:flutter/material.dart';

class MoreSettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;

  const MoreSettingsTile({super.key, required this.icon, required this.title, this.trailing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: GlassyContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: theme.colorScheme.surface.withOpacity(0.5), shape: BoxShape.circle),
              child: Icon(icon, color: theme.iconTheme.color, size: 20),
            ),
            const SizedBox(width: 14),
            Text(
              title,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color),
            ),
            const Spacer(),
            if (trailing != null) ...[trailing!, const SizedBox(width: 12)],
            Icon(Icons.arrow_forward_ios, size: 14, color: theme.iconTheme.color?.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}
