import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../features/progress/practice_entry.dart';

abstract interface class PracticeRepository {
  Future<List<PracticeEntry>> loadEntries();
  Future<void> saveEntries(List<PracticeEntry> entries);
}

class SharedPreferencesPracticeRepository implements PracticeRepository {
  SharedPreferencesPracticeRepository(this._preferences);
  static const _key = 'practice_entries_v1';
  final SharedPreferences _preferences;

  @override
  Future<List<PracticeEntry>> loadEntries() async {
    final value = _preferences.getString(_key);
    if (value == null) return [];
    try {
      final values = jsonDecode(value) as List<dynamic>;
      return values
          .map(
            (item) =>
                PracticeEntry.fromJson(Map<String, Object?>.from(item as Map)),
          )
          .toList();
    } on Object {
      return [];
    }
  }

  @override
  Future<void> saveEntries(List<PracticeEntry> entries) async {
    await _preferences.setString(
      _key,
      jsonEncode(entries.map((entry) => entry.toJson()).toList()),
    );
  }
}

class MemoryPracticeRepository implements PracticeRepository {
  List<PracticeEntry> _entries = [];
  @override
  Future<List<PracticeEntry>> loadEntries() async => List.of(_entries);
  @override
  Future<void> saveEntries(List<PracticeEntry> entries) async =>
      _entries = List.of(entries);
}
