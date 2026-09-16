class LessonPrompt {
  const LessonPrompt({
    required this.english,
    required this.spanish,
    required this.tip,
  });

  final String english;
  final String spanish;
  final String tip;
}

class Lesson {
  const Lesson({
    required this.id,
    required this.number,
    required this.title,
    required this.focus,
    required this.accent,
    required this.prompts,
  });

  final String id;
  final String number;
  final String title;
  final String focus;
  final int accent;
  final List<LessonPrompt> prompts;
}

const lessonCatalog = <Lesson>[
  Lesson(
    id: 'introductions',
    number: '01',
    title: 'Meet & greet',
    focus: 'Names, origins, and a warm hello',
    accent: 0xFFE96452,
    prompts: [
      LessonPrompt(
        english: 'Hi, my name is Alex.',
        spanish: 'Hola, me llamo Alex.',
        tip: 'Keep “me llamo” flowing as one phrase.',
      ),
      LessonPrompt(
        english: 'I am from Mexico.',
        spanish: 'Soy de México.',
        tip: 'Soy sounds like “soy” in English.',
      ),
      LessonPrompt(
        english: 'Nice to meet you.',
        spanish: 'Mucho gusto.',
        tip: 'Use an open “u” sound in gusto.',
      ),
    ],
  ),
  Lesson(
    id: 'cafe',
    number: '02',
    title: 'At the café',
    focus: 'Ordering with ease and courtesy',
    accent: 0xFF158A86,
    prompts: [
      LessonPrompt(
        english: 'A coffee, please.',
        spanish: 'Un café, por favor.',
        tip: 'Stress the final é in café.',
      ),
      LessonPrompt(
        english: 'Could I have the check?',
        spanish: '¿Me trae la cuenta?',
        tip: 'Let “cuenta” begin with a quick kw sound.',
      ),
      LessonPrompt(
        english: 'Thank you very much.',
        spanish: 'Muchas gracias.',
        tip: 'The c in gracias is soft in Latin America.',
      ),
    ],
  ),
  Lesson(
    id: 'directions',
    number: '03',
    title: 'Find your way',
    focus: 'Directions and nearby places',
    accent: 0xFFF2B84B,
    prompts: [
      LessonPrompt(
        english: 'Where is the station?',
        spanish: '¿Dónde está la estación?',
        tip: 'Stress dónde and the final syllable of estación.',
      ),
      LessonPrompt(
        english: 'Turn to the left.',
        spanish: 'Gire a la izquierda.',
        tip: 'Keep izquierda slow: iz-quier-da.',
      ),
      LessonPrompt(
        english: 'It is very close.',
        spanish: 'Está muy cerca.',
        tip: 'Cerca ends with a light “ka”.',
      ),
    ],
  ),
];
