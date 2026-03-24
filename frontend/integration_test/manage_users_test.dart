import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:frontend/main.dart' as app;

void main() {

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("Admin adds FA", (tester) async {

    app.main();
    await tester.pumpAndSettle();

    // LOGIN
    await tester.enterText(
        find.byKey(const Key("emailField")),
        "admin");

    await tester.enterText(
        find.byKey(const Key("passwordField")),
        "123");

    await tester.tap(find.byKey(const Key("loginButton")));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // OPEN MANAGE USERS
    await tester.tap(find.byKey(const Key("manageUsersButton")));
    await tester.pumpAndSettle();

    // ADD FA
    await tester.tap(find.byKey(const Key("addFaButton")));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key("faNameField")),
        "Test FA");

    await tester.enterText(
        find.byKey(const Key("faEmailField")),
        "testfa@nitc.ac.in");

    await tester.tap(find.byKey(const Key("submitFaButton")));
    await tester.pumpAndSettle();

    // VERIFY
    expect(find.text("Test FA"), findsOneWidget);
  });
}