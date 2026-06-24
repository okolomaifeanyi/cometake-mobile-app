import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../providers/auth_notifier.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phone;

  const OtpScreen({super.key, required this.phone});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  static const _resendCooldown = 60;

  final _formKey = GlobalKey<FormState>();
  final _otpCtrl = TextEditingController();

  bool _isVerifying = false;
  bool _isSending = false;
  bool _otpSent = false;
  int _secondsRemaining = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _sendOtp();
  }

  @override
  void dispose() {
    _otpCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsRemaining = _resendCooldown);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsRemaining == 0) {
        t.cancel();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  Future<void> _sendOtp() async {
    if (_isSending) return;
    setState(() => _isSending = true);

    try {
      await ref
          .read(authNotifierProvider.notifier)
          .sendPhoneOtp(phone: widget.phone);
      if (mounted) {
        setState(() {
          _otpSent = true;
          _isSending = false;
        });
        _startCountdown();
      }
    } on AppException catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        _showError(e.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSending = false);
        _showError('Failed to send OTP. Please try again.');
      }
    }
  }

  Future<void> _verify() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    setState(() => _isVerifying = true);

    try {
      await ref
          .read(authNotifierProvider.notifier)
          .verifyPhoneOtp(phone: widget.phone, token: _otpCtrl.text.trim());
      if (mounted) context.go(AppRoutes.home);
    } on AppException catch (e) {
      if (mounted) {
        setState(() => _isVerifying = false);
        _showError(e.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isVerifying = false);
        _showError('Verification failed. Please check the code and try again.');
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final canResend = _secondsRemaining == 0 && !_isSending && _otpSent;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: colorScheme.onSurface),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingH,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppDimensions.spacingXl),

                // ─── Icon ─────────────────────────────────────────────────
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.sms_outlined,
                      size: 36,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingLg),

                // ─── Title ────────────────────────────────────────────────
                Center(
                  child: Text(
                    'Verify your phone',
                    style: textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                Center(
                  child: Text(
                    'Enter the 6-digit code sent to',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Center(
                  child: Text(
                    widget.phone,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.spacingXxl),

                // ─── OTP input ────────────────────────────────────────────
                TextFormField(
                  controller: _otpCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: textTheme.headlineMedium
                      ?.copyWith(letterSpacing: 12),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (v) {
                    if (v == null || v.length != 6) {
                      return 'Enter the 6-digit code';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: '------',
                    hintStyle: textTheme.headlineMedium?.copyWith(
                      letterSpacing: 12,
                      color: colorScheme.onSurface.withOpacity(0.3),
                    ),
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.spacingLg,
                    ),
                  ),
                  onChanged: (v) {
                    if (v.length == 6) _verify();
                  },
                ),

                const SizedBox(height: AppDimensions.spacingXl),

                // ─── Verify button ────────────────────────────────────────
                AppButton(
                  label: 'Verify',
                  onPressed: _isVerifying ? null : _verify,
                  isLoading: _isVerifying,
                ),

                const SizedBox(height: AppDimensions.spacingLg),

                // ─── Resend ───────────────────────────────────────────────
                Center(
                  child: Column(
                    children: [
                      Text(
                        "Didn't receive the code?",
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXs),
                      if (_secondsRemaining > 0)
                        Text(
                          'Resend in ${_secondsRemaining}s',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        )
                      else
                        TextButton(
                          onPressed: canResend ? _sendOtp : null,
                          child: _isSending
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Resend OTP'),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
