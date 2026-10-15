import 'package:flutter_test/flutter_test.dart';
import 'package:coffi/main.dart';

void main() {
  testWidgets('COFFI smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CoffiApp());
    expect(find.text('COFFI'), findsOneWidget);
  });
}
