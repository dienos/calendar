import 'package:dienos_calendar/ui/common/bottom_action_button.dart';
import 'package:dienos_calendar/ui/common/glassy_container.dart';
import 'package:dienos_calendar/ui/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BackgroundSettingScreen extends ConsumerStatefulWidget {
  const BackgroundSettingScreen({super.key});

  @override
  ConsumerState<BackgroundSettingScreen> createState() => _BackgroundSettingScreenState();
}

class _BackgroundSettingScreenState extends ConsumerState<BackgroundSettingScreen> {
  late AppColorTheme _selectedTheme;

  @override
  void initState() {
    super.initState();
    _selectedTheme = ref.read(themeControllerProvider).colorTheme;
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeControllerProvider);
    final now = DateTime.now();

    // 테마 모드에 따른 다크 모드 판별
    bool isDarkMode;
    if (themeState.themeMode == AppThemeMode.system) {
      isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    } else {
      isDarkMode = themeState.themeMode == AppThemeMode.dark;
    }

    final activeColor = isDarkMode ? _selectedTheme.darkActiveColor : _selectedTheme.activeColor;
    final textColor = isDarkMode ? _selectedTheme.darkTextColor : _selectedTheme.textColor;
    final gradientColors = isDarkMode ? _selectedTheme.darkGradientColors : _selectedTheme.gradientColors;
    final navUnselectedColor = isDarkMode ? Colors.white54 : _selectedTheme.navUnselectedColor;

    final cardColor = isDarkMode ? _selectedTheme.darkCardColor : _selectedTheme.cardColor;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "배경색 설정",
          style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: gradientColors),
        ),
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 10),
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode, color: Colors.white, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    isDarkMode ? "다크 모드 적용 중" : "라이트 모드 적용 중",
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GlassyContainer(
                height: 260,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${now.month}월",
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                              ),
                              Text(
                                "${now.year}년",
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: activeColor),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: navUnselectedColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.chevron_left, size: 18, color: textColor.withOpacity(0.5)),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(color: activeColor.withOpacity(0.1), shape: BoxShape.circle),
                                child: Icon(Icons.chevron_right, size: 18, color: activeColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(color: textColor.withOpacity(0.1), height: 1),
                      const SizedBox(height: 12),
                      Text(
                        "오늘의 하이라이트",
                        style: TextStyle(fontSize: 11, color: textColor.withOpacity(0.7), fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(24)),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: activeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Text('🥰', style: TextStyle(fontSize: 24)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${now.month}월 ${now.day}일 오늘",
                                    style: TextStyle(color: activeColor, fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "배경색을 바꾸고 기분 전환 제대로 했네요!",
                                    style: TextStyle(color: textColor, fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(7, (index) {
                          final day = now.day + index;
                          final isToday = index == 0;
                          return Container(
                            width: 26,
                            height: 26,
                            alignment: Alignment.center,
                            decoration: isToday
                                ? BoxDecoration(color: activeColor.withOpacity(0.2), shape: BoxShape.circle)
                                : null,
                            child: Text(
                              "$day",
                              style: TextStyle(
                                color: isToday ? activeColor : textColor.withOpacity(0.7),
                                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GlassyContainer(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "색상 팔레트",
                          style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _selectedTheme.label,
                          style: TextStyle(color: activeColor, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: AppColorTheme.values.length,
                      itemBuilder: (context, index) {
                        final theme = AppColorTheme.values[index];
                        final isSelected = theme == _selectedTheme;

                        final thumbGradient = isDarkMode ? theme.darkGradientColors : theme.gradientColors;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTheme = theme;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: activeColor, width: 3)
                                  : Border.all(
                                      color: isDarkMode ? textColor.withOpacity(0.1) : textColor.withOpacity(0.2),
                                      width: 1,
                                    ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: activeColor.withOpacity(isDarkMode ? 0.4 : 0.3),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : (isDarkMode
                                        ? null
                                        : [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.05),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]),
                            ),
                            padding: EdgeInsets.all(isSelected ? 3 : 0),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: thumbGradient,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withOpacity(isDarkMode ? 0.05 : 0.8), width: 1),
                              ),
                              child: isSelected ? Icon(Icons.check, color: Colors.white, size: 20) : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
              child: BottomActionButton(
                text: "적용하기",
                icon: Icons.check_circle,
                backgroundColor: activeColor,
                onPressed: () {
                  ref.read(themeControllerProvider.notifier).changeTheme(_selectedTheme);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
