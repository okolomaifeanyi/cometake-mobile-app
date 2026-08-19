import 'package:cometake/shared/widgets/auth_prompt_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  Widget buildHarness() {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: ElevatedButton(
              onPressed: () =>
                  showAuthPromptSheet(context, message: 'Sign in to add items to your cart.'),
              child: const Text('Trigger'),
            ),
          ),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const Scaffold(body: Text('Login Screen')),
        ),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('shows the sign-in message passed by the caller', (tester) async {
    await tester.pumpWidget(buildHarness());
    await tester.tap(find.text('Trigger'));
    await tester.pumpAndSettle();

    expect(find.text('Sign in required'), findsOneWidget);
    expect(find.text('Sign in to add items to your cart.'), findsOneWidget);
  });

  testWidgets('"Not now" dismisses without navigating', (tester) async {
    await tester.pumpWidget(buildHarness());
    await tester.tap(find.text('Trigger'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();

    expect(find.text('Sign in required'), findsNothing);
    expect(find.text('Login Screen'), findsNothing);
  });

  testWidgets('"Sign In" dismisses the sheet and navigates to /login', (tester) async {
    await tester.pumpWidget(buildHarness());
    await tester.tap(find.text('Trigger'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Sign in required'), findsNothing);
    expect(find.text('Login Screen'), findsOneWidget);
  });
}
