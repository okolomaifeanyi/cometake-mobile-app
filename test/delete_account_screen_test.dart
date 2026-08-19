import 'package:cometake/core/errors/app_exception.dart';
import 'package:cometake/core/router/app_routes.dart';
import 'package:cometake/core/services/secure_storage_service.dart';
import 'package:cometake/features/auth/domain/repositories/auth_repository.dart';
import 'package:cometake/features/auth/presentation/providers/auth_notifier.dart';
import 'package:cometake/features/profile/presentation/screens/delete_account_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late MockAuthRepository mockRepo;
  late MockSecureStorageService mockSecureStorage;

  setUp(() {
    mockRepo = MockAuthRepository();
    mockSecureStorage = MockSecureStorageService();
    when(() => mockRepo.getCurrentUser()).thenAnswer((_) async => null);
    // AuthNotifier.deleteAccount() clears local secure storage before
    // signing out — flutter_secure_storage's real platform channel has no
    // implementation in a widget-test environment and hangs pumpAndSettle
    // indefinitely rather than throwing, confirmed by actually running
    // this test against the real provider. Mocking it here is required,
    // not optional.
    when(() => mockSecureStorage.deleteAll()).thenAnswer((_) async {});
  });

  Widget buildApp() {
    // DeleteAccountScreen calls context.go(AppRoutes.login) on success and
    // context.pop() on Cancel — both go_router BuildContext extensions,
    // which require a GoRouter ancestor to resolve. A plain
    // MaterialApp(home: ...) hangs pumpAndSettle() with an unresolved
    // "No GoRouter found in context" assertion, confirmed by actually
    // running this test.
    final router = GoRouter(
      initialLocation: AppRoutes.deleteAccount,
      routes: [
        GoRoute(
          path: AppRoutes.deleteAccount,
          builder: (context, state) => const DeleteAccountScreen(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const Scaffold(body: Text('Login Screen')),
        ),
      ],
    );
    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockRepo),
        secureStorageServiceProvider.overrideWithValue(mockSecureStorage),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('submit button is disabled until DELETE is typed exactly', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'delete');
    await tester.pump();
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
      reason: 'lowercase should not satisfy the exact-match confirmation',
    );

    await tester.enterText(find.byType(TextField), 'DELETE');
    await tester.pump();
    expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed, isNotNull);
  });

  testWidgets('successful deletion calls deleteAccount() exactly once and shows no error', (tester) async {
    when(() => mockRepo.deleteAccount()).thenAnswer((_) async {});
    when(() => mockRepo.signOut()).thenAnswer((_) async {});

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'DELETE');
    await tester.pump();
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    verify(() => mockRepo.deleteAccount()).called(1);
    expect(find.textContaining('We could not delete'), findsNothing);
  });

  testWidgets('a failed deletion shows an error and does not falsely claim success', (tester) async {
    when(() => mockRepo.deleteAccount())
        .thenThrow(const AuthException('Failed to delete account: network error'));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'DELETE');
    await tester.pump();
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.textContaining('We could not delete'), findsOneWidget);
    // The confirmation field still reads DELETE, so the button is enabled
    // again for an immediate retry rather than forcing re-entry.
    expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed, isNotNull);
  });
}
