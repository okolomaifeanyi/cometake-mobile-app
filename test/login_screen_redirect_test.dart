import 'package:cometake/core/router/app_routes.dart';
import 'package:cometake/features/auth/domain/entities/auth_user.dart';
import 'package:cometake/features/auth/domain/repositories/auth_repository.dart';
import 'package:cometake/features/auth/presentation/providers/auth_notifier.dart';
import 'package:cometake/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

// Covers RouterGuard's `?redirect=` mechanism end-to-end from the LoginScreen
// side (router_guard_test.dart only unit-tests RouterGuard.redirect() itself,
// not that login_screen.dart actually honors the param it produces).
class MockAuthRepository extends Mock implements AuthRepository {}

const _testUser = AuthUser(
  id: 'user-1',
  email: 'test@example.com',
  fullName: 'Test User',
);

void main() {
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
    when(() => mockRepo.getCurrentUser()).thenAnswer((_) async => null);
  });

  // Same shape as delete_account_screen_test.dart's buildApp(): a real
  // GoRouter is required because login_screen.dart calls context.go(), which
  // throws "No GoRouter found in context" under a plain MaterialApp(home:).
  Widget buildApp({required String initialLocation}) {
    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: AppRoutes.login,
          builder: (_, __) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (_, __) => const Scaffold(body: Text('Home Screen')),
        ),
        GoRoute(
          path: AppRoutes.wallet,
          builder: (_, __) => const Scaffold(body: Text('Wallet Screen')),
        ),
      ],
    );
    return ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  Future<void> signIn(WidgetTester tester) async {
    await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'Password1');
    final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
    // The button sits below the fold in the SingleChildScrollView at the
    // test viewport size — same fix login_screen_apple_button_test.dart
    // needed for the Apple button lower on the same screen.
    await tester.ensureVisible(signInButton);
    await tester.pumpAndSettle();
    await tester.tap(signInButton);
    await tester.pumpAndSettle();
  }

  testWidgets(
      'successful login with a redirect param lands back on the originally '
      'requested destination, not home', (tester) async {
    when(() => mockRepo.signIn(email: any(named: 'email'), password: any(named: 'password')))
        .thenAnswer((_) async => _testUser);

    await tester.pumpWidget(buildApp(
      initialLocation:
          '${AppRoutes.login}?redirect=${Uri.encodeComponent(AppRoutes.wallet)}',
    ));
    await tester.pumpAndSettle();

    await signIn(tester);

    expect(find.text('Wallet Screen'), findsOneWidget);
    expect(find.text('Home Screen'), findsNothing);
  });

  testWidgets('successful login with no redirect param falls back to home',
      (tester) async {
    when(() => mockRepo.signIn(email: any(named: 'email'), password: any(named: 'password')))
        .thenAnswer((_) async => _testUser);

    await tester.pumpWidget(buildApp(initialLocation: AppRoutes.login));
    await tester.pumpAndSettle();

    await signIn(tester);

    expect(find.text('Home Screen'), findsOneWidget);
    expect(find.text('Wallet Screen'), findsNothing);
  });
}
