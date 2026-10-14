import 'package:flutter_test/flutter_test.dart';
import 'package:cafeku/main.dart';

void main() {
  testWidgets('Cafeku smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CafekuApp());
    expect(find.text('Cafeku'), findsOneWidget);
  });
}
