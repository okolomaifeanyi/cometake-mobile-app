import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/app_text_field.dart';

/// Thin wrapper over [AppTextField] with auth-screen–specific defaults:
/// larger vertical padding, no floating label, autofill support.
class AuthTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final Widget? prefixIcon;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool autofocus;
  final AutovalidateMode? autovalidateMode;
  final List<String>? autofillHints;

  const AuthTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.prefixIcon,
    this.onChanged,
    this.inputFormatters,
    this.textInputAction,
    this.focusNode,
    this.autofocus = false,
    this.autovalidateMode,
    this.autofillHints,
  });

  @override
  Widget build(BuildContext context) {
    final field = AppTextField(
      label: label,
      hint: hint,
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      prefixIcon: prefixIcon,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
      textInputAction: textInputAction,
      focusNode: focusNode,
      autofocus: autofocus,
      autovalidateMode: autovalidateMode,
    );

    if (autofillHints != null) {
      return AutofillGroup(child: field);
    }
    return field;
  }
}

// ─── Pre-built auth field factories ──────────────────────────────────────────

class AuthEmailField extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final AutovalidateMode? autovalidateMode;

  const AuthEmailField({
    super.key,
    this.controller,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.autovalidateMode,
  });

  @override
  Widget build(BuildContext context) => AuthTextField(
        label: 'Email address',
        hint: 'you@example.com',
        controller: controller,
        validator: validator,
        keyboardType: TextInputType.emailAddress,
        prefixIcon: const Icon(Icons.email_outlined),
        textInputAction: textInputAction,
        focusNode: focusNode,
        autovalidateMode: autovalidateMode,
        autofillHints: const [AutofillHints.email],
      );
}

class AuthPasswordField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final AutovalidateMode? autovalidateMode;

  const AuthPasswordField({
    super.key,
    this.label = 'Password',
    this.controller,
    this.validator,
    this.textInputAction = TextInputAction.done,
    this.focusNode,
    this.autovalidateMode,
  });

  @override
  Widget build(BuildContext context) => AuthTextField(
        label: label,
        hint: '••••••••',
        controller: controller,
        validator: validator,
        obscureText: true,
        prefixIcon: const Icon(Icons.lock_outline),
        textInputAction: textInputAction,
        focusNode: focusNode,
        autovalidateMode: autovalidateMode,
        autofillHints: const [AutofillHints.password],
      );
}

class AuthPhoneField extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final AutovalidateMode? autovalidateMode;

  const AuthPhoneField({
    super.key,
    this.controller,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.autovalidateMode,
  });

  @override
  Widget build(BuildContext context) => AuthTextField(
        label: 'Phone number',
        hint: '8012345678',
        controller: controller,
        validator: validator,
        keyboardType: TextInputType.phone,
        prefixIcon: const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd,
            vertical: AppDimensions.spacingSm,
          ),
          child: Text(
            '+234',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        textInputAction: textInputAction,
        focusNode: focusNode,
        autovalidateMode: autovalidateMode,
        autofillHints: const [AutofillHints.telephoneNumber],
      );
}
