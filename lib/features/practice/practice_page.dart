import 'package:flutter/material.dart';

import '../lessons/lesson.dart';
import '../progress/practice_entry.dart';
import '../progress/progress_panel.dart';
import 'practice_controller.dart';
import 'recording_controller.dart';

const _ink = Color(0xFF20322F);
const _teal = Color(0xFF177E79);
const _coral = Color(0xFFE96452);
const _paper = Color(0xFFFFFCF6);

class PracticePage extends StatefulWidget {
  const PracticePage({super.key, required this.controller});
  final PracticeController controller;
  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  late final RecordingController recording = RecordingController();
  final noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
    recording.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    recording.removeListener(_refresh);
    recording.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    widget.controller.setNote(noteController.text);
    if (await widget.controller.completePractice() && mounted) {
      noteController.clear();
      await recording.discard();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Practice saved on this device.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1000;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Header(entries: widget.controller.entries.length),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  wide ? 40 : 18,
                  20,
                  wide ? 40 : 18,
                  48,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1360),
                    child: wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 260,
                                child: _LessonRail(
                                  controller: widget.controller,
                                  vertical: true,
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: _PracticeCard(
                                  controller: widget.controller,
                                  recording: recording,
                                  noteController: noteController,
                                  onSave: _save,
                                ),
                              ),
                              const SizedBox(width: 24),
                              SizedBox(
                                width: 290,
                                child: ProgressPanel(
                                  entries: widget.controller.entries,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _LessonRail(
                                controller: widget.controller,
                                vertical: false,
                              ),
                              const SizedBox(height: 18),
                              _PracticeCard(
                                controller: widget.controller,
                                recording: recording,
                                noteController: noteController,
                                onSave: _save,
                              ),
                              const SizedBox(height: 18),
                              ProgressPanel(entries: widget.controller.entries),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.entries});
  final int entries;
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: _paper,
      border: Border(bottom: BorderSide(color: Color(0xFFE1D9CA))),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
    child: Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: _coral,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.forum_rounded, color: Colors.white, size: 21),
        ),
        const SizedBox(width: 11),
        const Text(
          'SpeakLoop',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 23,
            fontWeight: FontWeight.w700,
            letterSpacing: -.5,
          ),
        ),
        const Spacer(),
        if (MediaQuery.sizeOf(context).width > 560)
          const Text(
            'A little Spanish, often.',
            style: TextStyle(color: Color(0xFF64736F), fontSize: 13),
          ),
        const SizedBox(width: 18),
        Semantics(
          label: '$entries saved practice sessions',
          child: _Pill(text: '$entries sessions'),
        ),
      ],
    ),
  );
}

class _LessonRail extends StatelessWidget {
  const _LessonRail({required this.controller, required this.vertical});
  final PracticeController controller;
  final bool vertical;
  @override
  Widget build(BuildContext context) {
    final cards = List.generate(lessonCatalog.length, (index) {
      final lesson = lessonCatalog[index];
      final selected = controller.lessonIndex == index;
      return Padding(
        padding: EdgeInsets.only(
          bottom: vertical ? 12 : 0,
          right: vertical ? 0 : 10,
        ),
        child: Semantics(
          button: true,
          selected: selected,
          label: 'Lesson ${lesson.number}: ${lesson.title}',
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => controller.selectLesson(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: vertical ? double.infinity : 205,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: selected ? Color(lesson.accent) : _paper,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected
                      ? Color(lesson.accent)
                      : const Color(0xFFE1D9CA),
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: Color(lesson.accent).withValues(alpha: .18),
                          blurRadius: 16,
                          offset: const Offset(0, 7),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LESSON ${lesson.number}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: selected ? Colors.white70 : Color(lesson.accent),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lesson.title,
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : _ink,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    lesson.focus,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: selected
                          ? Colors.white.withValues(alpha: .85)
                          : const Color(0xFF68736F),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'YOUR NOTEBOOK',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
            color: Color(0xFF6C7773),
          ),
        ),
        const SizedBox(height: 10),
        if (vertical)
          ...cards
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: cards),
          ),
      ],
    );
  }
}

class _PracticeCard extends StatelessWidget {
  const _PracticeCard({
    required this.controller,
    required this.recording,
    required this.noteController,
    required this.onSave,
  });
  final PracticeController controller;
  final RecordingController recording;
  final TextEditingController noteController;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final lesson = controller.currentLesson;
    final prompt = controller.currentPrompt;
    return Container(
      decoration: BoxDecoration(
        color: _paper,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE1D9CA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120C332E),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 500 ? 20 : 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _Pill(
                text:
                    '${controller.promptIndex + 1} of ${lesson.prompts.length}',
              ),
              const Spacer(),
              Text(
                lesson.title,
                style: TextStyle(
                  color: Color(lesson.accent),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'SAY IT IN SPANISH',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: _teal,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            prompt.english,
            style: const TextStyle(
              fontFamily: 'Georgia',
              fontSize: 24,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFFF1E9DC),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              prompt.spanish,
              style: const TextStyle(
                fontFamily: 'Georgia',
                fontSize: 30,
                fontWeight: FontWeight.w700,
                height: 1.2,
                color: _coral,
              ),
            ),
          ),
          const SizedBox(height: 13),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.lightbulb_outline_rounded,
                size: 18,
                color: _teal,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  prompt.tip,
                  style: const TextStyle(color: Color(0xFF5C6D68), height: 1.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _PromptDots(controller: controller),
          const SizedBox(height: 28),
          const Divider(color: Color(0xFFE1D9CA)),
          const SizedBox(height: 20),
          const Text(
            '1  PRACTISE ALOUD',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          _RecorderControls(controller: recording),
          const SizedBox(height: 26),
          const Text(
            '2  HOW DID IT FEEL?',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Only you can judge this. There is no automated score.',
            style: TextStyle(fontSize: 13, color: Color(0xFF6A7773)),
          ),
          const SizedBox(height: 12),
          ...SelfRating.values.map(
            (rating) => _RatingChoice(
              rating: rating,
              selected: controller.selectedRating == rating,
              onTap: () => controller.setRating(rating),
            ),
          ),
          if (controller.validationMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                controller.validationMessage!,
                style: const TextStyle(
                  color: Color(0xFFB23B2B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(height: 18),
          TextField(
            controller: noteController,
            maxLength: 140,
            minLines: 2,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'A note for next time (optional)',
              hintText: 'What would you repeat or change?',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFD8D0C2)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: onSave,
            style: FilledButton.styleFrom(
              backgroundColor: _teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 17),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.check_rounded),
            label: const Text(
              'Save practice',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromptDots extends StatelessWidget {
  const _PromptDots({required this.controller});
  final PracticeController controller;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      ...List.generate(
        controller.currentLesson.prompts.length,
        (index) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Semantics(
            label: 'Prompt ${index + 1}',
            button: true,
            selected: index == controller.promptIndex,
            child: InkWell(
              onTap: () => controller.selectPrompt(index),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: index == controller.promptIndex ? 30 : 10,
                height: 10,
                decoration: BoxDecoration(
                  color: index == controller.promptIndex
                      ? _coral
                      : const Color(0xFFD7CFC1),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ),
      ),
      const Spacer(),
      TextButton(
        onPressed: controller.nextPrompt,
        child: const Text('Next phrase  →'),
      ),
    ],
  );
}

class _RecorderControls extends StatelessWidget {
  const _RecorderControls({required this.controller});
  final RecordingController controller;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          OutlinedButton.icon(
            onPressed: controller.state == RecordingState.playing
                ? null
                : controller.toggleRecord,
            icon: Icon(
              controller.state == RecordingState.recording
                  ? Icons.stop_rounded
                  : Icons.mic_none_rounded,
            ),
            label: Text(
              controller.state == RecordingState.recording
                  ? 'Stop recording'
                  : 'Record myself',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: controller.state == RecordingState.recording
                  ? _coral
                  : _teal,
              side: BorderSide(
                color: controller.state == RecordingState.recording
                    ? _coral
                    : _teal,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            ),
          ),
          if (controller.recordingPath != null) ...[
            OutlinedButton.icon(
              onPressed: controller.state == RecordingState.playing
                  ? null
                  : controller.play,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(
                controller.state == RecordingState.playing
                    ? 'Playing…'
                    : 'Play back',
              ),
            ),
            TextButton.icon(
              onPressed: controller.discard,
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Discard'),
            ),
          ],
        ],
      ),
      if (controller.message != null)
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            controller.message!,
            style: const TextStyle(color: Color(0xFF775C28), height: 1.35),
          ),
        ),
      if (controller.state == RecordingState.recording)
        const Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            '● Recording stays on this device until you discard or leave.',
            style: TextStyle(color: _coral, fontSize: 12),
          ),
        ),
    ],
  );
}

class _RatingChoice extends StatelessWidget {
  const _RatingChoice({
    required this.rating,
    required this.selected,
    required this.onTap,
  });
  final SelfRating rating;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Semantics(
      button: true,
      selected: selected,
      label: rating.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE2F0ED) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? _teal : const Color(0xFFD8D0C2),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? _teal : const Color(0xFF89928F),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rating.label,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      rating.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6A7773),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFFE7E1D6),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF54635F),
      ),
    ),
  );
}
