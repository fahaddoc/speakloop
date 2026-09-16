enum SelfRating {
  needsPractice('Needs practice', 'I paused or lost the phrase'),
  gettingThere('Getting there', 'Mostly clear, with a few stumbles'),
  feltNatural('Felt natural', 'Smooth and comfortable');

  const SelfRating(this.label, this.description);
  final String label;
  final String description;
}

class PracticeEntry {
  const PracticeEntry({
    required this.id,
    required this.lessonId,
    required this.promptText,
    required this.rating,
    required this.practicedAt,
    required this.note,
  });

  final String id;
  final String lessonId;
  final String promptText;
  final SelfRating rating;
  final DateTime practicedAt;
  final String note;

  Map<String, Object?> toJson() => {
    'id': id,
    'lessonId': lessonId,
    'promptText': promptText,
    'rating': rating.name,
    'practicedAt': practicedAt.toIso8601String(),
    'note': note,
  };

  factory PracticeEntry.fromJson(Map<String, Object?> json) => PracticeEntry(
    id: json['id']! as String,
    lessonId: json['lessonId']! as String,
    promptText: json['promptText']! as String,
    rating: SelfRating.values.byName(json['rating']! as String),
    practicedAt: DateTime.parse(json['practicedAt']! as String),
    note: (json['note'] as String?) ?? '',
  );

  @override
  bool operator ==(Object other) =>
      other is PracticeEntry &&
      id == other.id &&
      lessonId == other.lessonId &&
      promptText == other.promptText &&
      rating == other.rating &&
      practicedAt == other.practicedAt &&
      note == other.note;

  @override
  int get hashCode =>
      Object.hash(id, lessonId, promptText, rating, practicedAt, note);
}
