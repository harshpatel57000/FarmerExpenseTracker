import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';
import 'package:frontend/pages/login_page.dart';

void main() {
  testWidgets('FarmExpenseApp opens on the login screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FarmExpenseApp());

    expect(find.byType(FarmExpenseApp), findsOneWidget);
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
