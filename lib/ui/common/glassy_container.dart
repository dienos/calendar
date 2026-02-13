import 'package:dienos_calendar/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class GlassyContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? color;
  final BorderRadiusGeometry? borderRadius;

  const GlassyContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.color,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final shadowTheme = theme.extension<AppShadowTheme>();

    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color:
            color ?? theme.cardTheme.color ?? (isDark ? Colors.black.withOpacity(0.6) : Colors.white.withOpacity(0.5)),
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        boxShadow: [
          if (shadowTheme != null)
            BoxShadow(
              color: shadowTheme.color,
              blurRadius: shadowTheme.blur,
              offset: Offset(0, shadowTheme.y),
              spreadRadius: 0,
            )
          else
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
        ],
        border: Border.all(
          color: color?.withOpacity(0.25) ?? (isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.6)),
          width: 1.0,
        ),
      ),
      child: child,
    );
  }
}
