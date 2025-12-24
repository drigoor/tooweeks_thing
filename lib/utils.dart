// Generate timestamped filename: classifications_2025-12-24_01-25.yaml
String timestampForFilename() {
  final now = DateTime.now();
  final year = now.toIso8601String().split('T')[0];
  final hour = now.hour.toString().padLeft(2, '0');
  final minutes = now.minute.toString().padLeft(2, '0');
  final second = now.second.toString().padLeft(2, '0');
  return '${year}_$hour-$minutes-$second';
}
