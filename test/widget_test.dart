// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';

import 'package:siber/main.dart';

void main() {
  testWidgets('SiCakrawalaApp smoke test', (WidgetTester tester) async {
    // Set desktop command center resolution
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Build our app and trigger a frame.
    await tester.pumpWidget(const SiCakrawalaApp());
    await tester.pump(const Duration(milliseconds: 500));

    // Verify app starts and finds title
    expect(find.textContaining('SI-CAKRAWALA'), findsWidgets);
  });
}
