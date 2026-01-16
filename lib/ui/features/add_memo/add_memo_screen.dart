import 'package:dienos_calendar/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddMemoScreen extends ConsumerStatefulWidget {
  final DateTime selectedDate;

  const AddMemoScreen({super.key, required this.selectedDate});

  @override
  ConsumerState<AddMemoScreen> createState() => _AddMemoScreenState();
}

class _AddMemoScreenState extends ConsumerState<AddMemoScreen> {
  late final TextEditingController _memoController;

  @override
  void initState() {
    super.initState();
    _memoController = TextEditingController();
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    final text = _memoController.text;
    if (text.isNotEmpty) {
      await ref.read(calendarViewModelProvider.notifier).addMemo(widget.selectedDate, text);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('메모를 입력해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.selectedDate.month}월 ${widget.selectedDate.day}일 기록'),
        actions: [
          TextButton(
            onPressed: _onSave,
            child: Text('저장', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildMemoCard(),
            const SizedBox(height: 20),
            _buildPlaceholderCard('🍽️ 오늘 갔던 식당'),
            const SizedBox(height: 20),
            _buildPlaceholderCard('📺 오늘 본 유튜브'),
          ],
        ),
      ),
    );
  }

  Widget _buildMemoCard() {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('메모', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _memoController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: '오늘 하루는 어땠나요?',
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderCard(String title) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$title 추가 기능은 준비 중입니다.')),
            );
          },
        ),
      ),
    );
  }
}
