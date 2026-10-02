import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_management_system/main.dart';

void main() {
  testWidgets(
    'Hospital Management System loads',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const HospitalManagementApp(),
      );

      await tester.pump();
    },
  );
}