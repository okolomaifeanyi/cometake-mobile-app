import 'package:flutter/material.dart';

import '../../core/theme/app_dimensions.dart';
import 'app_button.dart';

class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;
  final IconData icon;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Try Again',
    this.icon = Icons.error_outline,
  });

  const AppErrorWidget.network({
    super.key,
    this.message = 'No internet connection.\nCheck your connection and try again.',
    this.onRetry,
    this.retryLabel = 'Retry',
    this.icon = Icons.wifi_off_outlined,
  });

  const AppErrorWidget.empty({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Refresh',
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: cs.onSurfaceVariant),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              message,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppDimensions.spacingLg),
              AppButton.outlined(
                label: retryLabel,
                onPressed: onRetry,
                expand: false,
                icon: const Icon(Icons.refresh, size: AppDimensions.iconSm),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
