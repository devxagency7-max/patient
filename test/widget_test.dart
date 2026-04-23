import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacare/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const PharmaCareApp());
    expect(find.byType(PharmaCareApp), findsOneWidget);
  });
}
