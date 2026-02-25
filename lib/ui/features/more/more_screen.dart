import 'package:dienos_calendar/ui/common/more_settings_tile.dart';
import 'package:dienos_calendar/ui/common/gradient_background.dart';
import 'package:dienos_calendar/ui/features/more/background_setting_screen.dart';
import 'package:dienos_calendar/ui/features/more/backup_view_model.dart';
import 'package:dienos_calendar/ui/features/memo_list/memo_list_screen.dart';
import 'package:dienos_calendar/ui/features/emotion_list/emotion_list_screen.dart';
import 'package:dienos_calendar/ui/theme/theme_controller.dart';
import 'package:dienos_calendar/utils/ui_utils.dart';
import 'package:dienos_calendar/utils/permission_helper.dart';
import 'package:dienos_calendar/utils/widget_service.dart';
import 'package:dienos_calendar/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        body: SingleChildScrollView(
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
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.5),
                  ),
                ),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context) => _buildThemeModePicker(context, ref, themeState),
                  );
                },
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "위젯 설정",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              MoreSettingsTile(
                icon: Icons.widgets_outlined,
                title: "홈 화면에 위젯 추가",
                onTap: () async {
                  await WidgetService.requestWidgetPin();
                },
              ),
              const SizedBox(height: 12),
              MoreSettingsTile(
                icon: Icons.refresh,
                title: "위젯 새로 고침",
                onTap: () async {
                  await WidgetService.update(ref.read(getEventsUseCaseProvider));
                  if (context.mounted) showAppSnackBar(context, '위젯이 새로 고쳐졌어요 ✓');
                },
              ),
              const SizedBox(height: 24),
              _BackupSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeModePicker(BuildContext context, WidgetRef ref, ThemeState themeState) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
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

class _BackupSection extends ConsumerStatefulWidget {
  @override
  ConsumerState<_BackupSection> createState() => _BackupSectionState();
}

class _BackupSectionState extends ConsumerState<_BackupSection> {
  @override
  Widget build(BuildContext context) {
    final backupState = ref.watch(backupViewModelProvider);
    final vm = ref.read(backupViewModelProvider.notifier);
    final isLoading = backupState is BackupLoading;

    ref.listen(backupViewModelProvider, (_, next) {
      if (next is BackupSuccess) {
        showAppSnackBar(context, next.message);
        vm.reset();
      } else if (next is BackupError) {
        if (next.message.contains('영구적으로 거부')) {
          _showPermissionSettingsDialog(context);
        } else {
          showAppSnackBar(context, next.message);
        }
        vm.reset();
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "데이터 관리",
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
        const SizedBox(height: 12),
        MoreSettingsTile(
          icon: Icons.upload_file,
          title: "내 기록 백업하기",
          trailing: isLoading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : null,
          onTap: isLoading ? () {} : () => _onExportTap(context, vm),
        ),
        const SizedBox(height: 12),
        MoreSettingsTile(
          icon: Icons.download,
          title: "백업 파일로 복원하기",
          trailing: isLoading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : null,
          onTap: isLoading ? () {} : () => _onImportTap(context, vm),
        ),
      ],
    );
  }

  void _showPermissionSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('권한 설정 안내'),
          content: const Text('백업 및 복원 기능을 이용하려면 저장소 접근 권한이 필요합니다. 설정 화면에서 권한을 허용해 주세요.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
            TextButton(
              onPressed: () {
                PermissionHelper.openSettings();
                Navigator.pop(ctx);
              },
              child: const Text('설정으로 이동'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onExportTap(BuildContext context, BackupViewModel vm) async {
    final prefs = await SharedPreferences.getInstance();
    final guideShown = prefs.getBool('backup_guide_shown') ?? false;

    if (!guideShown && context.mounted) {
      final shouldProceed = await showDialog<bool>(context: context, builder: (ctx) => _ExportGuideDialog());
      if (shouldProceed != true) return;
    }

    await vm.exportBackup();
  }

  Future<void> _onImportTap(BuildContext context, BackupViewModel vm) async {
    final result = await vm.prepareImport();
    if (result == null || !context.mounted) return;

    final lines = result.lines;
    final fileName = result.fileName;
    if (lines == null || fileName == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('백업 파일로 복원하기'),
          content: Text('선택한 파일: $fileName\n\n백업 파일의 기록이 현재 앱에 추가됩니다.\n같은 날짜의 기록이 있다면 백업 파일 내용으로 바뀝니다.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('복원')),
          ],
        );
      },
    );

    if (confirmed == true) await vm.doImport(lines);
  }
}

class _ExportGuideDialog extends StatefulWidget {
  @override
  State<_ExportGuideDialog> createState() => _ExportGuideDialogState();
}

class _ExportGuideDialogState extends State<_ExportGuideDialog> {
  bool _doNotShowAgain = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Dialog(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('백업 폴더 선택', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(false),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '다음 화면에서 백업 파일을 저장할 폴더를 선택해 주세요.\n선택한 폴더에 backup_날짜_시간.txt 파일이 저장됩니다.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => setState(() => _doNotShowAgain = !_doNotShowAgain),
              child: Row(
                children: [
                  Checkbox(
                    value: _doNotShowAgain,
                    onChanged: (v) => setState(() => _doNotShowAgain = v ?? false),
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 4),
                  Text('다시 보지 않기', style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_doNotShowAgain) {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('backup_guide_shown', true);
                  }
                  if (context.mounted) Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('확인', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
