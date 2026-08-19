import 'package:cometake/core/errors/app_exception.dart';
import 'package:cometake/features/auth/domain/repositories/auth_repository.dart';
import 'package:cometake/features/auth/presentation/providers/auth_notifier.dart';
import 'package:cometake/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
    when(() => mockRepo.getCurrentUser()).thenAnswer((_) async => null);
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
      child: const MaterialApp(home: LoginScreen()),
    );
  }

  testWidgets('renders an Apple sign-in button on the login screen',
      (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.byType(SignInWithAppleButton), findsOneWidget);
  });

  testWidgets(
      'tapping the Apple button calls AuthRepository.signInWithApple() once',
      (tester) async {
    when(() => mockRepo.signInWithApple()).thenAnswer((_) async {});

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byType(SignInWithAppleButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SignInWithAppleButton));
    await tester.pumpAndSettle();

    verify(() => mockRepo.signInWithApple()).called(1);
  });

  testWidgets('a failed Apple sign-in shows an error snackbar, not a crash',
      (tester) async {
    when(() => mockRepo.signInWithApple())
        .thenThrow(const AuthException('Apple sign in failed: network error'));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byType(SignInWithAppleButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SignInWithAppleButton));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
  });
}
