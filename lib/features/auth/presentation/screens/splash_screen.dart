import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // GoRouter's refreshListenable handles the redirect after auth resolves.
    // This screen is only shown briefly during startup.
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusXl),
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingMd),
              Text(
                'Cometake',
                style: AppTextStyles.displayLarge
                    .copyWith(color: Colors.white),
              ),
              const SizedBox(height: AppDimensions.spacingXs),
              Text(
                'Your marketplace',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white.withOpacity(0.75),
                ),
              ),
              const Spacer(),
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
              const SizedBox(height: AppDimensions.spacingXxl),
            ],
          ),
        ),
      ),
    );
  }
}
