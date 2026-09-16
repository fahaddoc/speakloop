import 'package:flutter/foundation.dart';

import '../../data/practice_repository.dart';
import '../lessons/lesson.dart';
import '../progress/practice_entry.dart';

class PracticeController extends ChangeNotifier {
  PracticeController(this._repository);
  final PracticeRepository _repository;
  int _lessonIndex = 0;
  int _promptIndex = 0;
  SelfRating? selectedRating;
  String note = '';
  String? validationMessage;
  List<PracticeEntry> entries = [];

  Lesson get currentLesson => lessonCatalog[_lessonIndex];
  LessonPrompt get currentPrompt => currentLesson.prompts[_promptIndex];
  int get lessonIndex => _lessonIndex;
  int get promptIndex => _promptIndex;

  Future<void> initialize() async {
    entries = await _repository.loadEntries();
    notifyListeners();
  }

  void selectLesson(int index) {
    _lessonIndex = index;
    _promptIndex = 0;
    clearDraft();
  }

  void selectPrompt(int index) {
    _promptIndex = index;
    clearDraft();
  }

  void nextPrompt() =>
      selectPrompt((_promptIndex + 1) % currentLesson.prompts.length);

  void setRating(SelfRating rating) {
    selectedRating = rating;
    validationMessage = null;
    notifyListeners();
  }

  void setNote(String value) {
    note = value;
    notifyListeners();
  }

  void clearDraft() {
    selectedRating = null;
    note = '';
    validationMessage = null;
    notifyListeners();
  }

  Future<bool> completePractice() async {
    if (selectedRating == null) {
      validationMessage =
          'Choose an honest self-rating before saving this practice.';
      notifyListeners();
      return false;
    }
    final entry = PracticeEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      lessonId: currentLesson.id,
      promptText: currentPrompt.spanish,
      rating: selectedRating!,
      practicedAt: DateTime.now(),
      note: note.trim(),
    );
    entries = [entry, ...entries];
    await _repository.saveEntries(entries);
    clearDraft();
    return true;
  }
}
