import './daily_record.dart';

// 메모 기록을 위한 데이터 모델입니다.
// DailyRecord를 상속받습니다.
class MemoRecord extends DailyRecord {
  final String text;

  MemoRecord(this.text);
}
