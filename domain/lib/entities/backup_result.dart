import 'dart:typed_data';

class BackupResult {
  final int successCount;
  final int failCount;
  final List<String>? lines;
  final String? fileName;
  final Uint8List? zipBytes;

  const BackupResult({
    required this.successCount,
    required this.failCount,
    this.lines,
    this.fileName,
    this.zipBytes,
  });
}
