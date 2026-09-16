import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speakloop/app.dart';

void main() {
  testWidgets('first screen exposes lesson and practice activity', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const SpeakLoopApp());
    await tester.pumpAndSettle();

    expect(find.text('SpeakLoop'), findsOneWidget);
    expect(find.text('Meet & greet'), findsWidgets);
    expect(find.text('Hola, me llamo Alex.'), findsOneWidget);
    expect(find.text('Record myself'), findsOneWidget);
    expect(find.text('Save practice'), findsOneWidget);
  });

  testWidgets('changing prompts clears the previous private note', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const SpeakLoopApp());
    await tester.pumpAndSettle();
    final noteField = find.byType(TextField);
    await tester.enterText(noteField, 'Only relevant to the first phrase');

    final nextPhrase = find.text('Next phrase  →');
    await tester.ensureVisible(nextPhrase);
    await tester.tap(nextPhrase);
    await tester.pumpAndSettle();

    expect(tester.widget<TextField>(noteField).controller!.text, isEmpty);
    expect(find.text('Un café, por favor.'), findsNothing);
    expect(find.text('Soy de México.'), findsOneWidget);
  });
}
