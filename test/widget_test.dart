import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:beipoa_mobile/app.dart';

void main() {
  testWidgets('BeipoaApp loads shell with navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const BeipoaApp());
    await tester.pump(const Duration(milliseconds: 3200));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Computer Beipoa'), findsWidgets);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Shop'), findsOneWidget);
    expect(find.text('Cart'), findsOneWidget);
  });
}
