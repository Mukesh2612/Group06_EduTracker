import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:frontend/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("Login Test", (WidgetTester tester) async {

    app.main();
    await tester.pumpAndSettle();

    // enter email
    await tester.enterText(
        find.byKey(const Key("emailField")),
        "stud");

    // enter password
    await tester.enterText(
        find.byKey(const Key("passwordField")),
        "1234");

    // press login
    await tester.tap(find.byKey(const Key("loginButton")));

    await tester.pumpAndSettle(const Duration(seconds: 3));

    // check if any dashboard opened
    final student = find.byKey(const Key("studentDashboard"));
    final admin = find.byKey(const Key("adminDashboard"));
    final fa = find.byKey(const Key("faDashboard"));

    expect(
      student.evaluate().isNotEmpty ||
          admin.evaluate().isNotEmpty ||
          fa.evaluate().isNotEmpty,
      true,
    );

  });
}