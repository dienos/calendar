import 'package:dienos_calendar/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddDailyLogScreen extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  final String emotion;

  const AddDailyLogScreen({
    super.key,
    required this.selectedDate,
    required this.emotion,
  });

  @override
  ConsumerState<AddDailyLogScreen> createState() => _AddDailyLogScreenState();
}

class _AddDailyLogScreenState extends ConsumerState<AddDailyLogScreen> {
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    final note = _noteController.text;
    // For now, we allow saving an empty note. The log will still contain the emotion.
    await ref.read(calendarViewModelProvider.notifier).addDailyLog(widget.selectedDate, widget.emotion, note);

    if (mounted) {
      // Pop back to the calendar screen (pop SelectEmotionScreen and this screen)
      int count = 0;
      Navigator.of(context).popUntil((_) => count++ >= 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('무엇을 하고 있었어요?'),
        actions: [
          TextButton(
            onPressed: _onSave,
            child: const Text('저장'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          children: [
            _buildSection(title: '감정', content: widget.emotion, icon: Icons.sentiment_satisfied),
            _buildSection(title: '취미', content: '추가', icon: Icons.sports_esports, onAdd: () {}),
            _buildSection(title: '수면', content: '추가', icon: Icons.bedtime, onAdd: () {}),
            const Divider(),
            _buildNoteCard(),
            const Divider(),
            _buildPhotoCard(),
            const Divider(),
            _buildVoiceMemoCard(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: _onSave,
        child: const Icon(Icons.check),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required IconData icon,
    VoidCallback? onAdd,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(content),
      trailing: onAdd != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: onAdd),
                IconButton(icon: const Icon(Icons.arrow_drop_down), onPressed: () {}),
              ],
            )
          : null,
      onTap: onAdd,
    );
  }

  Widget _buildNoteCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('퀵 노트', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              hintText: '메모 추가...',
              border: InputBorder.none,
            ),
            maxLines: null, // Expands as user types
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('사진', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.camera_alt), label: const Text("사진 촬영")),
              ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.photo_library), label: const Text("갤러리")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceMemoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('음성 메모', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.mic),
              label: const Text("탭하여 녹음"),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
            ),
          ),
        ],
      ),
    );
  }
}
