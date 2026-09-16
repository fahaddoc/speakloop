import 'package:flutter_test/flutter_test.dart';
import 'package:speakloop/data/practice_repository.dart';
import 'package:speakloop/features/lessons/lesson.dart';
import 'package:speakloop/features/practice/practice_controller.dart';
import 'package:speakloop/features/progress/practice_entry.dart';

void main() {
  group('PracticeController', () {
    test('starts on a valid prompt and advances within a lesson', () async {
      final controller = PracticeController(MemoryPracticeRepository());
      await controller.initialize();

      expect(
        controller.currentLesson.prompts,
        contains(controller.currentPrompt),
      );
      final original = controller.currentPrompt;
      controller.nextPrompt();
      expect(controller.currentPrompt, isNot(original));
    });

    test('requires an honest self-rating before saving', () async {
      final controller = PracticeController(MemoryPracticeRepository());
      await controller.initialize();

      final saved = await controller.completePractice();

      expect(saved, isFalse);
      expect(controller.validationMessage, contains('rating'));
      expect(controller.entries, isEmpty);
    });

    test('saves selected rating and optional note', () async {
      final repository = MemoryPracticeRepository();
      final controller = PracticeController(repository);
      await controller.initialize();
      controller.setRating(SelfRating.gettingThere);
      controller.setNote('  Rolled the r more clearly.  ');

      expect(await controller.completePractice(), isTrue);

      expect(controller.entries, hasLength(1));
      expect(controller.entries.single.rating, SelfRating.gettingThere);
      expect(controller.entries.single.note, 'Rolled the r more clearly.');
      expect(controller.selectedRating, isNull);
      expect(controller.note, isEmpty);
    });

    test('keeps draft and history unchanged when persistence fails', () async {
      final controller = PracticeController(_FailingRepository());
      await controller.initialize();
      controller.setRating(SelfRating.feltNatural);
      controller.setNote('Keep this note');

      expect(await controller.completePractice(), isFalse);

      expect(controller.entries, isEmpty);
      expect(controller.selectedRating, SelfRating.feltNatural);
      expect(controller.note, 'Keep this note');
      expect(controller.validationMessage, contains('save'));
    });
  });

  test('lesson catalog contains three bilingual structured lessons', () {
    expect(lessonCatalog, hasLength(greaterThanOrEqualTo(3)));
    for (final lesson in lessonCatalog) {
      expect(lesson.prompts.length, greaterThanOrEqualTo(3));
      expect(lesson.title, isNotEmpty);
      expect(lesson.focus, isNotEmpty);
      expect(
        lesson.prompts.every(
          (prompt) => prompt.english.isNotEmpty && prompt.spanish.isNotEmpty,
        ),
        isTrue,
      );
    }
  });
}

class _FailingRepository implements PracticeRepository {
  @override
  Future<List<PracticeEntry>> loadEntries() async => [];

  @override
  Future<void> saveEntries(List<PracticeEntry> entries) =>
      Future.error(StateError('disk full'));
}
