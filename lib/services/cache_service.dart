import 'package:hive_flutter/hive_flutter.dart';
import '../models/scan_history_model.dart';

/// Local offline cache service using Hive to store scan history and look up existing transliterations.
class CacheService {
  static const String _boxName = 'scan_history_box';
  Box<ScanHistoryModel>? _box;

  /// Initializes Hive and opens the history box.
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ScanHistoryModelAdapter());
    }
    _box = await Hive.openBox<ScanHistoryModel>(_boxName);
  }

  /// Saves a transliteration scan. Prevents duplicate entries of the same (text, source, target).
  /// If a duplicate is found, it is replaced and updated with a fresh timestamp.
  Future<void> saveResult({
    required String originalText,
    required String sourceScript,
    required String targetScript,
    required String transliteratedText,
  }) async {
    if (_box == null) await init();

    final trimmedOriginal = originalText.trim();
    if (trimmedOriginal.isEmpty) return;

    final items = _box!.toMap().entries.toList();
    dynamic duplicateKey;

    for (final entry in items) {
      final value = entry.value;
      if (value.originalText == trimmedOriginal &&
          value.sourceScript == sourceScript &&
          value.targetScript == targetScript) {
        duplicateKey = entry.key;
        break;
      }
    }

    final newRecord = ScanHistoryModel(
      originalText: trimmedOriginal,
      sourceScript: sourceScript,
      targetScript: targetScript,
      transliteratedText: transliteratedText,
      timestamp: DateTime.now(),
    );

    if (duplicateKey != null) {
      // Remove old key so new record resides at the end/newest index
      await _box!.delete(duplicateKey);
    }

    await _box!.add(newRecord);
    await removeOldEntries();
  }

  /// Fast lookup for checking if a phrase is already transliterated.
  ScanHistoryModel? getResult({
    required String originalText,
    required String sourceScript,
    required String targetScript,
  }) {
    if (_box == null) return null;

    final trimmedOriginal = originalText.trim();
    for (final item in _box!.values) {
      if (item.originalText == trimmedOriginal &&
          item.sourceScript == sourceScript &&
          item.targetScript == targetScript) {
        return item;
      }
    }
    return null;
  }

  /// Retrieves list of all scan records, sorted by timestamp (newest first).
  List<ScanHistoryModel> getHistory() {
    if (_box == null) return [];
    final list = _box!.values.toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  /// Completely empties the cache history.
  Future<void> clearCache() async {
    if (_box == null) await init();
    await _box!.clear();
  }

  /// Keeps cache size strictly bounded at 1,000 entries.
  /// Deletes the oldest entries by timestamp order.
  Future<void> removeOldEntries() async {
    if (_box == null) return;
    if (_box!.length <= 1000) return;

    final entries = _box!.toMap().entries.toList();
    // Sort ascending by timestamp (oldest entries first)
    entries.sort((a, b) => a.value.timestamp.compareTo(b.value.timestamp));

    final excessCount = entries.length - 1000;
    for (int i = 0; i < excessCount; i++) {
      await _box!.delete(entries[i].key);
    }
  }

  /// Safely closes the database box.
  Future<void> dispose() async {
    await _box?.close();
  }
}
