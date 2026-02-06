import 'package:domain/entities/daily_log_record.dart';
import 'package:flutter/material.dart';

class MemoListScreen extends StatelessWidget {
  final DateTime date;
  final List<DailyLogRecord> memos;

  const MemoListScreen({super.key, required this.date, required this.memos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${date.month}월 ${date.day}일 메모 목록'),
      ),
      body: ListView.separated(
        // 1. 좌우 여백은 유지하고, 위아래 여백만 리스트뷰에 적용합니다.
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        itemCount: memos.length,
        itemBuilder: (context, index) {
          final memo = memos[index];
          return Dismissible(
            key: ValueKey(memo),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${memo.memo}' '메모가 삭제되었습니다.')),
              );
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20.0),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete, color: Colors.white),
                  SizedBox(width: 8),
                  Text('삭제', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            child: Card(
              // 2. 카드의 기본 마진을 제거하여 좌우로 꽉 차게 만듭니다.
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(memo.memo, style: const TextStyle(fontSize: 16, height: 1.5)),
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 12),
      ),
    );
  }
}
