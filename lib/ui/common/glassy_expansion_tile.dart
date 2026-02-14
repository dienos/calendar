import 'package:dienos_calendar/ui/common/glassy_container.dart';
import 'package:flutter/material.dart';

class GlassyExpansionTile extends StatefulWidget {
  final Widget title;
  final List<Widget> children;
  final bool initiallyExpanded;
  final EdgeInsetsGeometry? childrenPadding;

  const GlassyExpansionTile({
    super.key,
    required this.title,
    this.children = const [],
    this.initiallyExpanded = true,
    this.childrenPadding,
  });

  @override
  State<GlassyExpansionTile> createState() => _GlassyExpansionTileState();
}

class _GlassyExpansionTileState extends State<GlassyExpansionTile> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassyContainer(
      padding: EdgeInsets.zero,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: widget.initiallyExpanded,
          title: widget.title,
          childrenPadding: widget.childrenPadding ?? const EdgeInsets.all(16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          shape: const Border(), // Remove default border
          collapsedShape: const Border(), // Remove default collapsed border
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          trailing: AnimatedRotation(
            turns: _isExpanded ? 0.5 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              Icons.keyboard_arrow_down_rounded, // More rounded, sophisticated look
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          dense: true,
          children: widget.children,
        ),
      ),
    );
  }
}
