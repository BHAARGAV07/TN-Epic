import 'package:client/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows TN-Epic login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const TNEpicApp());

    expect(find.text('TN-EPIC'), findsOneWidget);
    expect(find.text('Your Quest Awaits'), findsOneWidget);
    expect(find.text('Begin Quest \u2192'), findsOneWidget);

    await tester.tap(find.text('Begin Quest \u2192'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to TN-Epic'), findsOneWidget);
    expect(find.text('Next \u2192'), findsOneWidget);
  });
}
