import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stockpulse/main.dart';

void main() {
  testWidgets('shows login screen with validation fields', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const StockPulseApp());
    await tester.pumpAndSettle();

    expect(find.text('StockPulse'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.byKey(const ValueKey('emailField')), findsOneWidget);
    expect(find.byKey(const ValueKey('passwordField')), findsOneWidget);
  });
}
