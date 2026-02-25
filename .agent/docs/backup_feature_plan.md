# 달력 파일 백업 / 불러오기 — 상세 구현 계획

---

## 변경 배경

기존 `.txt` 백업 방식은 이미지 **경로만 저장**하므로, 앱 삭제 후 재설치하면 해당 경로의 파일이 모두 삭제되어 이미지 복원이 **불가능**하다.

따라서 백업 포맷을 `.zip`으로 전환하여 **텍스트 데이터 + 실제 이미지 파일**을 하나에 묶어 관리한다.

---

## 1. 파일 저장 위치 및 명명 규칙

| 항목 | 기존 | 변경 후 |
|------|------|---------|
| 확장자 | `.txt` | `.zip` |
| 파일명 예시 | `backup_20260225_123800.txt` | `backup_20260225_123800.zip` |
| 인코딩 | UTF-8 | UTF-8 (data.txt 기준) |

---

## 2. ZIP 내부 구조

```
backup_20260225_123800.zip
├── data.txt          ← 기존 텍스트 포맷 그대로 (헤더 + 로그 라인)
└── images/
    ├── 3_1772013155334_0.jpg
    ├── 5_1772013155334_1.jpg
    └── ...
```

### data.txt 포맷 (기존과 동일)

```
# CALENDAR_BACKUP_V1
2025-11-01|정말 좋음|오늘 기분이 좋았다|3_1772013155334_0.jpg,5_1772013155334_1.jpg
2025-11-02|나쁨|비가 와서\n우울했다|
```

> **변경점**: 이미지 경로를 절대 경로 대신 **파일명만** 저장한다.  
> 복원 시 `images/` 폴더에서 파일을 꺼내 앱 경로에 복사하므로 절대 경로 불필요.

---

## 3. 내보내기 (Export) 흐름

```
[기존 ExportBackupUseCase.call() — 변경 없음]
List<String> lines 반환 (헤더 + 로그 라인)
단, 이미지 경로는 절대 경로 대신 파일명만 포함
        ↓
[BackupViewModel.exportBackup() — 변경]
lines → data.txt 콘텐츠 생성
이미지 파일들을 앱 내부 저장소에서 읽어 archive로 ZIP 구성
  ZIP에 data.txt 추가
  ZIP에 images/ 폴더 내 파일들 추가
        ↓
[BackupRepositoryImpl.saveBackupFile() — 변경]
.zip 바이트를 파일로 저장 (파일명: backup_yyyyMMdd_HHmmss.zip)
```

---

## 4. 불러오기 (Import) 흐름

```
[BackupRepositoryImpl.readFromFile() — 변경]
.zip 파일 선택 (file_picker allowedExtensions: ['zip'])
        ↓
[ImportBackupUseCase.pickFile() — 변경]
ZIP 압축 해제
├── data.txt 추출 → lines 파싱 (헤더 검증 포함, 기존 로직 재사용)
└── images/ 폴더 내 파일 → 앱 내부 저장소(/app_flutter/images/)로 복사
복사 후 BackupResult 반환 (lines 포함)
        ↓
[ImportBackupUseCase.doImport(lines) — 변경 없음]
기존 파싱/DB upsert 로직 그대로
단, 이미지는 파일명만 저장하므로 _resolveImagePath()가 올바른 경로로 변환
```

---

## 5. Android 권한 정책

기존과 동일. SAF 기반 `file_picker` 사용이므로 추가 권한 불필요.

---

## 6. 예외 처리

### 6-1. 내보내기

| 상황 | 처리 방법 |
|------|----------|
| DB 데이터 0건 | \"내보낼 데이터가 없어요\" |
| 이미지 파일 없음 | 해당 로그의 이미지 없이 data.txt만 포함하여 백업 |
| ZIP 생성 실패 | \"파일 저장에 실패했어요. 다시 시도해 주세요\" |
| 저장 다이얼로그 취소 | 아무 동작 없음 |

### 6-2. 불러오기

| 단계 | 상황 | 처리 방법 |
|------|------|----------|
| 파일 선택 | .zip 아닌 파일 | file_picker 필터로 차단 |
| ZIP 파싱 | data.txt 없음 | \"올바른 백업 파일이 아니에요\" |
| ZIP 파싱 | 헤더 불일치 | \"올바른 백업 파일이 아니에요\" |
| 이미지 복사 | 개별 파일 실패 | 해당 파일 skip, 나머지 계속 진행 |
| DB upsert | 실패 | \"데이터 저장에 실패했어요\" |

---

## 7. Proposed Changes

### 의존성

| 패키지 | 위치 | 상태 |
|--------|------|------|
| `archive` | 루트 `pubspec.yaml` | **신규 추가** |
| `file_picker` | 루트 `pubspec.yaml` | 기존 유지 |
| `path_provider` | `data/pubspec.yaml` | 기존 유지 |

### 변경 대상 파일

| 파일 | 변경 내용 |
|------|----------|
| `pubspec.yaml` | `archive` 패키지 추가 |
| `export_backup_usecase.dart` | 이미지 경로를 절대 경로 → 파일명만 저장하도록 수정 |
| `backup_repository_impl.dart` | `.zip` 파일 저장/선택으로 변경 |
| `import_backup_usecase.dart` | ZIP 압축 해제, 이미지 복사 로직 추가 |
| `backup_view_model.dart` | exportBackup()에서 ZIP 생성 로직 추가 |

### 변경 없는 파일 (기존 로직 유지)

| 파일 | 이유 |
|------|------|
| `ImportBackupUseCase.doImport()` | 텍스트 파싱/DB upsert 로직 동일 |
| `BackupRepository` (abstract) | 인터페이스 변경 없음 |
| `BackupResult` | 구조 변경 없음 |
| `CalendarRepositoryImpl` | `_resolveImagePath()`로 이미 경로 보정 처리됨 |
| `more_screen.dart` | UI 변경 없음 |

---

## 8. 복원 전략 (Upsert)

- 기존과 동일: 같은 날짜 → 덮어씀, 다른 날짜 기존 데이터 유지
- 이미지: ZIP에서 추출 → 앱 내부 저장소 복사 → DB에 새 경로(파일명 기반) 저장
- `CalendarRepositoryImpl._resolveImagePath()` 가 파일명을 현재 앱 경로로 변환

---

## 9. SnackBar 메시지 정의 (기존과 동일)

| 상황 | 메시지 |
|------|--------|
| 내보내기 성공 | \"백업 완료! ✓\" |
| 내보낼 데이터 없음 | \"내보낼 데이터가 없어요\" |
| 복원 성공 (일부 실패) | \"N개의 기록을 불러왔어요 ✓ (실패: M건)\" |
| 복원 성공 (전체 성공) | \"N개의 기록을 모두 불러왔어요 ✓\" |
| 잘못된 파일 형식 | \"올바른 백업 파일이 아니에요\" |
| 파일 쓰기 실패 | \"파일 저장에 실패했어요. 다시 시도해 주세요\" |
| 알 수 없는 오류 | \"오류가 발생했어요. 다시 시도해 주세요\" |

---

## 10. Verification Plan

### Automated
```bash
flutter analyze --project-path d:\source\calendar_dienos
```

### Manual
1. 이미지 포함된 기록 입력 후 내보내기 → `backup_xxx.zip` 저장 확인
2. ZIP 파일 열어 `data.txt` + `images/` 폴더 구조 확인
3. 앱 삭제 후 재설치 → 백업 파일로 복원 → 이미지 정상 표시 확인
4. 임의의 zip 파일 선택 → \"올바른 백업 파일이 아니에요\" 확인
5. 이미지 없는 기록만 있을 때 내보내기 → data.txt만 포함된 zip 확인
6. 이미지 없는 기록 복원 → 정상 복원 확인
