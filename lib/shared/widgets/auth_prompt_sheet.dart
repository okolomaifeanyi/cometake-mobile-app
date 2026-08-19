import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/app_dimensions.dart';

/// Non-blocking "sign in required" prompt for an account-gated action
/// (add to cart, save to wishlist) taken while browsing as a guest.
/// Pushes the login screen — since this is a push, not a go, the caller's
/// current screen stays on the navigation stack underneath, so popping
/// back after sign-in returns to exactly where the user was.
Future<void> showAuthPromptSheet(
  BuildContext context, {
  required String message,
}) {
  return showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      final colorScheme = Theme.of(ctx).colorScheme;
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.lock_outline_rounded, size: 32, color: colorScheme.primary),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              'Sign in required',
              textAlign: TextAlign.center,
              semanticsLabel: 'Sign in required',
              style: Theme.of(ctx)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(ctx)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ctx.push(AppRoutes.login);
                },
                child: const Text('Sign In'),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Not now'),
            ),
          ],
        ),
      );
    },
  );
}
