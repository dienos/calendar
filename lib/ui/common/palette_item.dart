import 'package:flutter/material.dart';

class PaletteItem extends StatelessWidget {
  final bool isSelected;
  final String label;
  final Widget child;
  final List<Color> gradientColors;
  final Color activeColor;
  final VoidCallback onTap;

  const PaletteItem({
    super.key,
    required this.isSelected,
    required this.label,
    required this.child,
    required this.gradientColors,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 70 : 60,
              height: isSelected ? 70 : 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: Colors.white, width: 4)
                    : Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: activeColor.withOpacity(isSelected ? 0.4 : 0.15),
                    blurRadius: isSelected ? 12 : 6,
                    spreadRadius: isSelected ? 2 : 0,
                  ),
                ],
              ),
              child: Center(child: child),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: isSelected ? 13 : 12,
                color: isSelected
                    ? Theme.of(context).textTheme.bodyLarge?.color
                    : Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
