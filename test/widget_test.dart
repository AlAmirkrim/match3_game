import 'package:flutter_test/flutter_test.dart';
import 'package:match3_game/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RoyalMatchApp());
    expect(find.byType(RoyalMatchApp), findsOneWidget);
  });
}
