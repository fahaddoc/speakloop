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
}
