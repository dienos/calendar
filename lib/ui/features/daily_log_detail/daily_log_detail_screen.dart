import 'package:dienos_calendar/providers.dart';
import 'package:dienos_calendar/ui/common/gradient_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienos_calendar/utils/permission_helper.dart';
import 'package:intl/intl.dart';

import 'widgets/emotion_section.dart';
import 'widgets/memo_section.dart';
import 'widgets/photo_section.dart';
import '../add_daily_log/add_daily_log_screen.dart';

class DailyLogDetailScreen extends ConsumerWidget {
  final DateTime date;

  const DailyLogDetailScreen({super.key, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyLogAsync = ref.watch(dailyLogDetailProvider(date));

    // 화면 진입 시 사진 권한 체크 (복원 후 이미지 로드를 보장하기 위함)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final log = dailyLogAsync.value;
      if (log != null && log.images.isNotEmpty) {
        final result = await PermissionHelper.requestPhotoPermission();
        if (result == PermissionResult.granted) {
          // 권한이 허용되면 데이터를 다시 불러와 이미지를 로드함
          ref.invalidate(dailyLogDetailProvider(date));
        }
      }
    });

    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(DateFormat('M월 d일 EEEE', 'ko_KR').format(date)),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton(
                onPressed: () {
                  final dailyLog = dailyLogAsync.value;
                  if (dailyLog != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddDailyLogScreen(selectedDate: date, initialRecord: dailyLog),
                      ),
                    );
                  }
                },
                child: const Text('수정하기'),
              ),
            ),
          ],
        ),
        body: dailyLogAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('데이터를 불러올 수 없습니다: $err')),
          data: (dailyLog) {
            if (dailyLog == null) {
              return const Center(child: Text('이 날짜에 저장된 기록이 없습니다.'));
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EmotionSection(emotion: dailyLog.emotion),
                  const SizedBox(height: 32),
                  MemoSection(memo: dailyLog.memo),
                  const SizedBox(height: 32),
                  PhotoSection(images: dailyLog.images),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
