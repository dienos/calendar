# 달력 파일 백업 / 불러오기 — 상세 구현 계획

---

## 1. 파일 저장 위치

### 전략: 유저가 폴더만 선택 → 파일명은 앱이 자동 생성

> `file_picker`의 `getDirectoryPath()`로 **폴더 선택 다이얼로그**를 띄웁니다.  
> 파일명은 유저가 수정할 수 없고, 명명 규칙에 따라 앱이 자동 생성합니다.

**내보내기 흐름**:
```
유저가 폴더 선택 → 앱이 backup_yyyyMMdd_HHmmss.txt 자동 생성
```

**선택 이유**:
- 앱 삭제 후에도 파일 유지 → 재설치 후 복원 가능
- 파일명 명명 규칙 일관성 보장
- SAF `ACTION_OPEN_DOCUMENT_TREE` 기반 → **추가 권한 불필요**
- Scoped Storage 정책 완전 준수

**불러오기**: `file_picker.pickFiles()`로 유저가 직접 `.txt` 파일 선택

---

## 2. 파일 명명 규칙

| 항목 | 규칙 |
|------|------|
| 기본 제안 파일명 | `backup_yyyyMMdd_HHmmss.txt` |
| 예시 | `backup_20260225_123800.txt` |
| 인코딩 | **UTF-8** |
| 확장자 | `.txt` 고정 |
| 타임스탬프 | 내보내기 실행 시각 기준 (로컬 시간) |

> 파일명은 유저가 변경할 수 없으며, 앱이 명명 규칙에 따라 자동 생성 (`backup_yyyyMMdd_HHmmss.txt`)

---

## 3. 파일 포맷

```
# CALENDAR_BACKUP_V1
2025-11-01|정말 좋음|오늘 기분이 좋았다
2025-11-02|나쁨|비가 와서\n우울했다
```

| 열 | 내용 | 비고 |
|----|------|------|
| 1 | `date` | `yyyy-MM-dd` |
| 2 | `emotion` | **DB에 저장된 값 그대로** 사용 |
| 3 | `memo` | 개행 → `\n`으로 이스케이프 |

**DB emotion 저장값 목록** (이 값 이외는 파싱 실패로 처리):

| DB 저장값 | 의미 |
|-----------|------|
| `정말 좋음` | 매우 좋음 |
| `좋음` | 좋음 |
| `보통` | 보통 |
| `나쁨` | 나쁨 |
| `끔찍함` | 매우 나쁨 |

- **헤더 라인**: `# CALENDAR_BACKUP_V1` — 파일 유효성 검증의 핵심
- 구분자: `|` (파이프)
- 파일 → DB 변환 시 별도 매핑 없이 그대로 INSERT 가능

---

## 4. Android 권한 정책

| 동작 | 필요 권한 (Android < 13) | 필요 권한 (Android 13+) | 처리 방법 |
|------|---|---|---|
| 내보내기 | `READ_EXTERNAL_STORAGE` | (선택한 폴더에 따라 다름) | `PermissionHelper`를 통한 사전 체크 및 요청 |
| 불러오기 | `READ_EXTERNAL_STORAGE` | (SAF 사용 시 불필요) | `PermissionHelper`를 통한 사전 체크 및 요청 |

> [!NOTE]
> SAF(`file_picker`)를 사용하면 이론상 별도 권한이 불필요할 수 있으나, 일부 기기나 버전에 따라 파일 접근 에러가 발생할 수 있으므로 `PermissionHelper`를 통해 기본 읽기 권한을 체크/요청하는 단계를 추가합니다.

---

## 5. 다단계 검증 구조 (불러오기)

> 잘못된 파일을 선택하더라도 DB는 절대 건드리지 않습니다.

```
파일 선택 (file_picker)
   ↓
① 확장자 필터    .txt 파일만 선택 가능하도록 file_picker 설정
   ↓
② 헤더 검증     첫 줄이 정확히 "# CALENDAR_BACKUP_V1" 인지 확인
                → 불일치 시 즉시 중단, DB 접근 없음
   ↓
③ 라인별 파싱   각 줄을 개별적으로 검증
                → 파싱 실패한 줄은 skip + 실패 카운트
   ↓
④ DB upsert    검증 통과한 데이터만 저장
   ↓
⑤ 결과 보고    성공 N건 / 실패 M건 SnackBar 표시
```

---

## 6. 예외 처리 케이스 전체 목록

### 6-1. 내보내기 (Export)

| 상황 | 처리 방법 |
|------|----------|
| DB 데이터 0건 | 파일 저장 다이얼로그 열기 전 차단 → "내보낼 데이터가 없어요" |
| 유저가 저장 다이얼로그 취소 | 아무 동작 없음 (정상 흐름) |
| 파일 쓰기 실패 | `FileSystemException` catch → "파일 저장에 실패했어요" |
| 예상치 못한 예외 | `catch (e)` → "오류가 발생했어요" + `debugPrint` |

### 6-2. 불러오기 (Import)

| 단계 | 상황 | 처리 방법 |
|------|------|----------|
| ① 파일 선택 | 유저가 취소 | 아무 동작 없음 |
| ① 파일 선택 | `.txt` 아닌 파일 | `file_picker` 필터로 선택 자체를 막음 |
| ② 헤더 검증 | 첫 줄 불일치 | 즉시 중단 → "올바른 백업 파일이 아니에요" |
| ② 헤더 검증 | 파일 읽기 실패 | `FileSystemException` catch → "파일을 읽을 수 없어요" |
| ② 헤더 검증 | 인코딩 오류 | `FormatException` catch → "파일 형식이 올바르지 않아요" |
| ③ 라인 파싱 | `|` 구분자 개수 오류 | 해당 줄 skip + 실패 카운트 |
| ③ 라인 파싱 | date 형식 오류 | 해당 줄 skip + 실패 카운트 |
| ③ 라인 파싱 | emotion 빈 값 | 해당 줄 skip + 실패 카운트 |
| ④ DB upsert | upsert 실패 | `DatabaseException` catch → "데이터 저장에 실패했어요" |
| ⑤ 결과 보고 | 성공 0건 | "불러올 수 있는 데이터가 없어요 (파일을 확인해 주세요)" |

### 6-3. 공통

| 상황 | 처리 방법 |
|------|----------|
| 작업 중 화면 이탈 | `StateNotifier.mounted` 체크 후 state 업데이트 |
| 로딩 중 중복 탭 | `loading` 상태에서 버튼 비활성화 |

---

## 7. UX 흐름

### 내보내기
```
탭
 → [권한 체크 및 요청]
    - `PermissionHelper.requestStoragePermission()` 호출
    - 거부 시: "저장소 접근 권한이 필요해요" 안내 후 중단
    - 영구 거부 시: 설정 이동 다이얼로그 표시
 → [최초 1회] 안내 팝업 표시
    - 내용: "폴더를 선택하면 해당 폴더에 백업 파일이 저장됩니다."
    - 체크박스: "다시 보지 않기"
    - [확인] 버튼 클릭 시 → SharedPreferences에 확인 여부 저장
 → 데이터 0건 체크
 → 폴더 선택 다이얼로그
    - 유저가 폴더만 선택 (파일명 자동 결정)
    - backup_yyyyMMdd_HHmmss.txt 자동 생성 → 성공 Toast
```

- `SharedPreferences` 키: `backup_guide_shown`
- `다시 보지 않기` 체크 후 [확인] 시 → `true` 저장, 이후 팝업 미표시
- `다시 보지 않기` 미체크 후 [확인] 시 → 저장하지 않음, 다음 번에도 팝업 다시 표시

### 불러오기
```
탭 → 시스템 파일 선택 다이얼로그 (.txt 필터)
  → 확인 다이얼로그 표시
  → [복원] → 다단계 검증 → DB upsert → 결과 Toast
```

**확인 다이얼로그**:
```
이 파일로 복원할까요?
선택한 파일: backup_20260225_123800.txt

기존 데이터는 유지되고 파일 데이터가 병합됩니다.
같은 날짜는 파일 데이터로 덮어씁니다.

[취소]  [복원]
```

---

## 8. 복원 전략 (Upsert)

- 같은 날짜의 기록 → 파일 데이터로 **덮어씀** (`OnConflictStrategy.replace`)
- 다른 날짜 기존 데이터는 유지
- 이미지 데이터는 백업 대상 제외 (텍스트만)

---

## 9. Proposed Changes

### 의존성

| 패키지 | 위치 | 상태 |
|--------|------|------|
| `file_picker` | 루트 `pubspec.yaml` | **신규 추가** |
| `permission_handler` | 루트 `pubspec.yaml` | 이미 포함 (불필요하지만 유지) |
| `path_provider` | `data/pubspec.yaml` | 이미 포함 |

### Domain 레이어

#### [NEW] [backup_repository.dart](file:///d:/source/calendar_dienos/domain/lib/repositories/backup_repository.dart)

#### [NEW] [backup_result.dart](file:///d:/source/calendar_dienos/domain/lib/entities/backup_result.dart)

#### [MODIFY] [calendar_repository.dart](file:///d:/source/calendar_dienos/domain/lib/repositories/calendar_repository.dart)
- `getAllLogs()` 추가
- `insertOrReplaceLogs(List<DailyLogRecord>)` 추가

#### [NEW] [export_backup_usecase.dart](file:///d:/source/calendar_dienos/domain/lib/usecases/export_backup_usecase.dart)

#### [NEW] [import_backup_usecase.dart](file:///d:/source/calendar_dienos/domain/lib/usecases/import_backup_usecase.dart)

---

### Data 레이어

#### [NEW] [backup_repository_impl.dart](file:///d:/source/calendar_dienos/data/lib/repositories/backup_repository_impl.dart)
- `file_picker` 사용 (내보내기: `saveFile()`, 불러오기: `pickFiles()`)
- 섹션 6-1, 6-2, 6-3 모든 예외처리 구현

#### [MODIFY] [calendar_repository_impl.dart](file:///d:/source/calendar_dienos/data/lib/repositories/calendar_repository_impl.dart)
- `getAllLogs()`, `insertOrReplaceLogs()` 구현

#### [MODIFY] Calendar DAO
- `getAllLogs()` → `SELECT * FROM daily_log_entity`
- `insertOrReplace()` → `@insert(onConflict: OnConflictStrategy.replace)`

---

### App 레이어

#### [MODIFY] [providers.dart](file:///d:/source/calendar_dienos/lib/providers.dart)
- `backupRepositoryProvider`, `exportBackupUseCaseProvider`, `importBackupUseCaseProvider`

#### [NEW] [backup_view_model.dart](file:///d:/source/calendar_dienos/lib/ui/features/more/backup_view_model.dart)
```
BackupState: idle | loading | success(message) | error(message)
- exportBackup(BuildContext): 0건 체크 → 저장 다이얼로그 → 파일 저장 → SnackBar
- importBackup(BuildContext): 파일 선택 → 확인 다이얼로그 → 다단계 검증 → 복원 → SnackBar
```

#### [MODIFY] [more_screen.dart](file:///d:/source/calendar_dienos/lib/ui/features/more/more_screen.dart)
- "데이터 관리" 섹션을 기존 Column 끝에 **추가** (기존 코드 수정 없음)

> [!IMPORTANT]
> `more_screen.dart`의 기존 모아보기/테마/위젯 섹션은 절대 건드리지 않습니다.

---

## 10. SnackBar 메시지 정의

| 상황 | 메시지 |
|------|--------|
| 내보내기 성공 | "백업 완료! ✓" |
| 내보낼 데이터 없음 | "내보낼 데이터가 없어요" |
| 복원 성공 (일부 실패) | "N개의 기록을 불러왔어요 ✓ (실패: M건)" |
| 복원 성공 (전체 성공) | "N개의 기록을 모두 불러왔어요 ✓" |
| 복원 데이터 0건 | "불러올 수 있는 데이터가 없어요 (파일을 확인해 주세요)" |
| 잘못된 파일 형식 | "올바른 백업 파일이 아니에요" |
| 파일 쓰기 실패 | "파일 저장에 실패했어요. 다시 시도해 주세요" |
| 알 수 없는 오류 | "오류가 발생했어요. 다시 시도해 주세요" |

---

## 11. Verification Plan

### Automated
```bash
flutter analyze --project-path d:\source\calendar_dienos
```


### Manual
1. 기록 입력 후 내보내기 → 폴더 선택 다이얼로그 → 저장 → 성공 SnackBar
2. 저장된 파일 열어 헤더 `# CALENDAR_BACKUP_V1`, `date|emotion|memo` 형식 확인
3. 불러오기 → 파일 선택 → 확인 다이얼로그 → 복원 → SnackBar 확인
4. 달력에서 복원된 데이터 정상 표시 확인
5. 임의의 txt 파일 선택 → "올바른 백업 파일이 아니에요" 확인
6. 헤더 변조 파일 선택 → "올바른 백업 파일이 아니에요" 확인
7. 일부 라인 깨진 파일 → "N개 불러왔어요 (실패: M건)" 확인
8. 데이터 0건 상태에서 내보내기 → "내보낼 데이터가 없어요" 확인

---

## 12. UI 개발 계획

### 12-1. more_screen.dart 레이아웃 추가

기존 Column 끝에 "데이터 관리" 섹션 추가. **기존 코드 수정 없음.**

```
더보기 화면 (Column)
├── 모아보기 섹션 (기존 유지)
├── 테마 설정 섹션 (기존 유지)
├── 위젯 설정 섹션 (기존 유지)
└── 데이터 관리 섹션 ← 신규 추가
    ├── SizedBox(height: 24)
    ├── 섹션 레이블 "데이터 관리"
    ├── SizedBox(height: 12)
    ├── MoreSettingsTile (백업 파일로 내보내기)
    ├── SizedBox(height: 12)
    └── MoreSettingsTile (백업 파일 불러오기)
```

### 12-2. 각 타일 스펙

| 타일 | 아이콘 | 제목 | trailing |
|------|--------|------|----------|
| 내보내기 | `Icons.upload_file` | "내 기록 백업하기" | 로딩 시 `SizedBox(16, 16, CircularProgressIndicator)` |
| 불러오기 | `Icons.download` | "백업 파일로 복원하기" | 로딩 시 `SizedBox(16, 16, CircularProgressIndicator)` |

- 로딩 중(`BackupState.loading`)에는 `onTap` 콜백을 막아 중복 실행 방지
- 기존 `MoreSettingsTile` 위젯 그대로 재사용

### 12-3. 확인 다이얼로그 (불러오기)

`showDialog()` → `AlertDialog` 사용. 기존 앱 테마 자동 적용.

```
┌──────────────────────────────────┐
│  백업 파일로 복원하기             │
│                                  │
│  선택한 파일:                     │
│  backup_20260225_123800.txt      │
│                                  │
│  백업 파일의 기록이 현재 앱에     │
│  추가됩니다.                     │
│  같은 날짜의 기록이 있다면        │
│  백업 파일 내용으로 바뀝니다.     │
│                                  │
│         [취소]      [복원]        │
└──────────────────────────────────┘
```

### 12-4. BackupViewModel 상태 → UI 매핑

| BackupState | UI 동작 |
|-------------|---------|
| `idle` | 타일 정상 표시, 탭 가능 |
| `loading` | trailing에 `CircularProgressIndicator` 표시, 탭 막힘 |
| `success(msg)` | `showAppSnackBar(context, msg)` 호출 후 → `idle`로 복귀 |
| `error(msg)` | `showAppSnackBar(context, msg)` 호출 후 → `idle`로 복귀 |

### 12-5. 공통 유틸 활용

- `showAppSnackBar()` — `lib/utils/ui_utils.dart` 기존 함수 재사용
- `GlassyContainer` — `MoreSettingsTile` 내부에서 이미 사용 중
- `GradientBackground` — `more_screen.dart` Scaffold 배경 그대로 유지
