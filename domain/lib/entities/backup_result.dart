class BackupResult {
  final int successCount;
  final int failCount;
  final List<String>? lines;
  final String? fileName;

  const BackupResult({
    required this.successCount,
    required this.failCount,
    this.lines,
    this.fileName,
  });
}
