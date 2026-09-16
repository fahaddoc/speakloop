import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speakloop/data/practice_repository.dart';
import 'package:speakloop/features/progress/practice_entry.dart';

void main() {
  test('shared preferences repository replays saved progress', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesPracticeRepository(preferences);
    final entry = PracticeEntry(
      id: 'entry-1',
      lessonId: 'introductions',
      promptText: 'Me llamo Sam.',
      rating: SelfRating.feltNatural,
      practicedAt: DateTime.utc(2026, 9, 16, 10),
      note: 'Clear and steady',
    );

    await repository.saveEntries([entry]);
    final replayed = await SharedPreferencesPracticeRepository(preferences)
        .loadEntries();

    expect(replayed, [entry]);
  });

  test('repository ignores malformed persisted data', () async {
    SharedPreferences.setMockInitialValues({
      'practice_entries_v1': '{bad json',
    });
    final preferences = await SharedPreferences.getInstance();

    final entries = await SharedPreferencesPracticeRepository(preferences)
        .loadEntries();

    expect(entries, isEmpty);
  });
}
