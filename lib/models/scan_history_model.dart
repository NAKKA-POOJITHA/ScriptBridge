import 'package:hive/hive.dart';

/// Model representing a saved transliteration scan in the history cache.
class ScanHistoryModel {
  final String originalText;
  final String sourceScript;
  final String targetScript;
  final String transliteratedText;
  final DateTime timestamp;

  ScanHistoryModel({
    required this.originalText,
    required this.sourceScript,
    required this.targetScript,
    required this.transliteratedText,
    required this.timestamp,
  });

  /// Convert to JSON-like map for debugging or utility.
  Map<String, dynamic> toMap() {
    return {
      'originalText': originalText,
      'sourceScript': sourceScript,
      'targetScript': targetScript,
      'transliteratedText': transliteratedText,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScanHistoryModel &&
          runtimeType == other.runtimeType &&
          originalText == other.originalText &&
          sourceScript == other.sourceScript &&
          targetScript == other.targetScript &&
          transliteratedText == other.transliteratedText;

  @override
  int get hashCode =>
      originalText.hashCode ^
      sourceScript.hashCode ^
      targetScript.hashCode ^
      transliteratedText.hashCode;
}

/// Custom Hive TypeAdapter for ScanHistoryModel to avoid reliance on build_runner.
class ScanHistoryModelAdapter extends TypeAdapter<ScanHistoryModel> {
  @override
  final int typeId = 0;

  @override
  ScanHistoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScanHistoryModel(
      originalText: fields[0] as String,
      sourceScript: fields[1] as String,
      targetScript: fields[2] as String,
      transliteratedText: fields[3] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(fields[4] as int),
    );
  }

  @override
  void write(BinaryWriter writer, ScanHistoryModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.originalText)
      ..writeByte(1)
      ..write(obj.sourceScript)
      ..writeByte(2)
      ..write(obj.targetScript)
      ..writeByte(3)
      ..write(obj.transliteratedText)
      ..writeByte(4)
      ..write(obj.timestamp.millisecondsSinceEpoch);
  }
}
