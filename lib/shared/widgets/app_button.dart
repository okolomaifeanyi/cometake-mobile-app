import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';

enum _Variant { primary, secondary, outlined, text, destructive }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final _Variant _variant;
  final bool isLoading;
  final bool expand;
  final Widget? icon;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.expand = true,
    this.icon,
    this.height = AppDimensions.buttonHeight,
  }) : _variant = _Variant.primary;

  const AppButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.expand = true,
    this.icon,
    this.height = AppDimensions.buttonHeight,
  }) : _variant = _Variant.secondary;

  const AppButton.outlined({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.expand = true,
    this.icon,
    this.height = AppDimensions.buttonHeight,
  }) : _variant = _Variant.outlined;

  const AppButton.text({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.expand = false,
    this.icon,
    this.height = AppDimensions.buttonHeightSm,
  }) : _variant = _Variant.text;

  const AppButton.destructive({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.expand = true,
    this.icon,
    this.height = AppDimensions.buttonHeight,
  }) : _variant = _Variant.destructive;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final content = isLoading
        ? SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _fgColor(cs),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: AppDimensions.spacingSm)],
              Text(
                label,
                style: AppTextStyles.labelLarge.copyWith(color: _fgColor(cs)),
              ),
            ],
          );

    final minSize = Size(0, height);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
    );

    return switch (_variant) {
      _Variant.outlined => OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: expand ? Size.fromHeight(height) : minSize,
            side: BorderSide(color: cs.primary),
            shape: shape,
          ),
          child: content,
        ),
      _Variant.text => TextButton(
          onPressed: isLoading ? null : onPressed,
          child: content,
        ),
      _ => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _bgColor(cs),
            foregroundColor: _fgColor(cs),
            minimumSize: expand ? Size.fromHeight(height) : minSize,
            shape: shape,
            elevation: 0,
          ),
          child: content,
        ),
    };
  }

  Color _bgColor(ColorScheme cs) => switch (_variant) {
        _Variant.secondary => AppColors.secondary,
        _Variant.destructive => AppColors.error,
        _ => cs.primary,
      };

  Color _fgColor(ColorScheme cs) => switch (_variant) {
        _Variant.outlined => cs.primary,
        _Variant.text => cs.primary,
        _ => cs.onPrimary,
      };
}
