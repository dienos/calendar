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
  late PageController _pageController;
  late AppColorTheme _selectedTheme;

  @override
  void initState() {
    super.initState();
    final currentTheme = ref.read(themeControllerProvider);
    _selectedTheme = currentTheme;
    final initialIndex = AppColorTheme.values.indexOf(currentTheme);
    _pageController = PageController(viewportFraction: 0.3, initialPage: initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 화면 전체적인 스타일은 현재 선택 중인 테마(_selectedTheme)를 따라가야 미리보기가 됨
    // 즉, Scaffold 배경이나 글자 색상도 _selectedTheme 기준.
    final now = DateTime.now();

    // 다크 모드 감지 및 색상 변수 설정 (_selectedTheme 기준)
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final activeColor = isDarkMode ? _selectedTheme.darkActiveColor : _selectedTheme.activeColor;
    final textColor = isDarkMode ? _selectedTheme.darkTextColor : _selectedTheme.textColor;
    final gradientColors = isDarkMode ? _selectedTheme.darkGradientColors : _selectedTheme.gradientColors;
    final navUnselectedColor = isDarkMode ? Colors.white54 : _selectedTheme.navUnselectedColor;

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

            // 시스템 테마 상태 표시
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    isDarkMode ? "다크 모드 적용 중" : "라이트 모드 적용 중",
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            // 프리뷰 영역
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GlassyContainer(
                height: 340,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 상단 캘린더 헤더 스타일
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${now.month}월",
                                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textColor),
                              ),
                              Text(
                                "${now.year}년",
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: activeColor),
                              ),
                            ],
                          ),
                          // 좌우 화살표 버튼 모방
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: navUnselectedColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.chevron_left, size: 20, color: textColor.withOpacity(0.5)),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(color: activeColor.withOpacity(0.1), shape: BoxShape.circle),
                                child: Icon(Icons.chevron_right, size: 20, color: activeColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(color: textColor.withOpacity(0.1), height: 1),
                      const SizedBox(height: 24),

                      // 오늘의 하이라이트 스타일 박스
                      Text(
                        "오늘의 하이라이트",
                        style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.7), fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: activeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Text('🥰', style: TextStyle(fontSize: 32)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${now.month}월 ${now.day}일 오늘",
                                    style: TextStyle(color: activeColor, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "오늘은 정말 기분 좋은 하루였어요! 배경색도 바꾸고 기분 전환 제대로 했네요.",
                                    style: TextStyle(color: textColor, fontSize: 15),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // 캘린더 날짜 셀 예시
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(7, (index) {
                          final day = now.day + index;
                          final isToday = index == 0;
                          return Container(
                            width: 30,
                            height: 30,
                            alignment: Alignment.center,
                            decoration: isToday
                                ? BoxDecoration(color: activeColor.withOpacity(0.2), shape: BoxShape.circle)
                                : null,
                            child: Text(
                              "$day",
                              style: TextStyle(
                                color: isToday ? activeColor : textColor.withOpacity(0.7),
                                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            // 색상 팔레트 (Pager)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 16),
                  child: Text("색상 팔레트", style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 13)),
                ),
                SizedBox(
                  height: 120,
                  child: PageView.builder(
                    controller: _pageController,
                    padEnds: true, // 선택된 아이템이 중앙에 오도록 설정
                    itemCount: AppColorTheme.values.length,
                    onPageChanged: (index) {
                      setState(() {
                        _selectedTheme = AppColorTheme.values[index];
                      });
                    },
                    itemBuilder: (context, index) {
                      final theme = AppColorTheme.values[index];
                      final isSelected = theme == _selectedTheme;

                      final thumbGradient = isDarkMode ? theme.darkGradientColors : theme.gradientColors;
                      final thumbPrimary = isDarkMode ? theme.darkActiveColor : theme.primaryColor;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTheme = theme;
                          });
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: isSelected ? 80 : 60,
                              height: isSelected ? 80 : 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: thumbGradient,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(color: Colors.white, width: 4)
                                    : Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: thumbPrimary.withOpacity(isSelected ? 0.4 : 0.15),
                                    blurRadius: isSelected ? 12 : 6,
                                    spreadRadius: isSelected ? 2 : 0,
                                  ),
                                ],
                              ),
                              child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 32) : null,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              theme.label,
                              style: TextStyle(
                                fontSize: isSelected ? 14 : 12,
                                color: isSelected ? textColor : textColor.withOpacity(0.7),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const Spacer(),
            // 공통 버튼 적용
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
