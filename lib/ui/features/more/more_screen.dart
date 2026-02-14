import 'package:dienos_calendar/ui/common/more_settings_tile.dart';
import 'package:dienos_calendar/ui/common/gradient_background.dart';
import 'package:dienos_calendar/ui/features/more/background_setting_screen.dart';
import 'package:dienos_calendar/ui/features/memo_list/memo_list_screen.dart';
import 'package:dienos_calendar/ui/features/emotion_list/emotion_list_screen.dart';
import 'package:dienos_calendar/ui/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeControllerProvider);
    final currentTheme = themeState.colorTheme;

    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            "더보기",
            style: TextStyle(
              color: Theme.of(context).textTheme.titleLarge?.color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "모아보기",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              MoreSettingsTile(
                icon: Icons.emoji_emotions_outlined,
                title: "기분 모아보기",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EmotionListScreen(focusedMonth: DateTime.now())),
                  );
                },
              ),
              const SizedBox(height: 12),
              MoreSettingsTile(
                icon: Icons.note_alt_outlined,
                title: "작성한 메모 모아보기",
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const MemoListScreen()));
                },
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "테마 설정",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              MoreSettingsTile(
                icon: Icons.palette,
                title: "배경색 설정",
                trailing: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: Theme.of(context).brightness == Brightness.dark
                          ? currentTheme.darkGradientColors
                          : currentTheme.gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? currentTheme.darkTextColor
                          : Colors.white,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (Theme.of(context).brightness == Brightness.dark
                                    ? currentTheme.darkActiveColor
                                    : currentTheme.primaryColor)
                                .withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const BackgroundSettingScreen()));
                },
              ),
              const SizedBox(height: 12),
              MoreSettingsTile(
                icon: Icons.brightness_4,
                title: "컬러 모드 설정",
                trailing: Text(
                  themeState.themeMode.label,
                  style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.5)),
                ),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context) => _buildThemeModePicker(context, ref, themeState),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeModePicker(BuildContext context, WidgetRef ref, ThemeState themeState) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("컬러 모드 선택", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ...AppThemeMode.values.map((mode) {
            final isSelected = themeState.themeMode == mode;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                mode == AppThemeMode.dark
                    ? Icons.dark_mode
                    : (mode == AppThemeMode.light ? Icons.light_mode : Icons.brightness_auto),
                color: isSelected ? Theme.of(context).colorScheme.primary : null,
              ),
              title: Text(
                mode.label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Theme.of(context).colorScheme.primary : null,
                ),
              ),
              trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
              onTap: () {
                ref.read(themeControllerProvider.notifier).changeThemeMode(mode);
                Navigator.pop(context);
              },
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
