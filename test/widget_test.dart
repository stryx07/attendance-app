import 'package:flutter_test/flutter_test.dart';

import 'package:attendance_system/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MainApp());

    // Verify that our welcome message is displayed.
    expect(find.text('Attendance System'), findsWidgets);
  });
}
