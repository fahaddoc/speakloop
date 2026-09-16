import 'package:flutter/material.dart';

import 'practice_entry.dart';

class ProgressPanel extends StatelessWidget {
  const ProgressPanel({super.key, required this.entries});
  final List<PracticeEntry> entries;
  @override
  Widget build(BuildContext context) {
    final natural = entries
        .where((entry) => entry.rating == SelfRating.feltNatural)
        .length;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF203B37),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PRACTICE NOTES',
            style: TextStyle(
              color: Color(0xFFAAD2CC),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            entries.isEmpty
                ? 'Start your loop'
                : '${entries.length} loops logged',
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Georgia',
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            entries.isEmpty
                ? 'Pick a phrase, say it aloud, and record how it felt.'
                : '$natural felt natural. Every honest check-in counts.',
            style: const TextStyle(color: Color(0xFFC8D7D4), height: 1.4),
          ),
          const SizedBox(height: 20),
          if (entries.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .07),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.edit_note_rounded,
                color: Color(0xFFF0B449),
                size: 40,
              ),
            )
          else
            ...entries
                .take(4)
                .map(
                  (entry) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.promptText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          entry.rating.label,
                          style: const TextStyle(
                            color: Color(0xFFF0B449),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (entry.note.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              entry.note,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFFC8D7D4),
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
          const SizedBox(height: 18),
          const Text(
            'Progress is based only on your saved self-ratings. SpeakLoop does not analyse pronunciation.',
            style: TextStyle(
              color: Color(0xFF9DB4B0),
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
