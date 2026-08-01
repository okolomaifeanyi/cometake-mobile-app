import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/subscription_checkout_result_model.dart';
import '../providers/vendor_provider.dart';

// ── Allowed Paystack domains ──────────────────────────────────────────────────
const _kAllowedHosts = {
  'checkout.paystack.com',
  'paystack.com',
  'standard.paystack.com',
  'api.paystack.co',
  'hostedpay.gtbank.com',
  'pay.opay.ng',
  'netpay.firstbanknigeria.com',
};

// Subscription checkout's callback_url defaults to this path (Flutter omits
// the optional returnPath param, so the web endpoint uses its default). The
// WebView intercepts navigation to this path before the page ever loads —
// the underlying Next.js page's own content is irrelevant to this flow.
const _kCallbackHost = 'cometake.net';
const _kCallbackPaths = ['/seller-onboarding/subscription/verify'];

const _kMaxVerifyRetries = 8;

class SubscriptionPaymentScreen extends ConsumerStatefulWidget {
  final SubscriptionCheckoutResultModel result;

  const SubscriptionPaymentScreen({super.key, required this.result});

  @override
  ConsumerState<SubscriptionPaymentScreen> createState() =>
      _SubscriptionPaymentScreenState();
}

class _SubscriptionPaymentScreenState
    extends ConsumerState<SubscriptionPaymentScreen> {
  late final SubscriptionCheckoutResultModel _result = widget.result;

  bool _webLoading = true;
  bool _externalLaunched = false;
  _PaymentPhase _phase = _PaymentPhase.webview;
  String? _errorMessage;
  bool _navigated = false;

  static final _webSettings = InAppWebViewSettings(
    useShouldOverrideUrlLoading: true,
  );

  bool _isCallbackUrl(WebUri? uri) {
    if (uri == null) return false;
    if (uri.host != _kCallbackHost) return false;
    return _kCallbackPaths.any((p) => uri.path.startsWith(p));
  }

  bool _isAllowedHost(WebUri? uri) {
    if (uri == null) return true;
    final scheme = uri.scheme;
    if (scheme != 'http' && scheme != 'https') return false;
    return _kAllowedHosts.contains(uri.host) || uri.host == _kCallbackHost;
  }

  void _onPaymentAttemptComplete() {
    if (_navigated) return;
    setState(() => _phase = _PaymentPhase.verifying);
    _verifyPayment();
  }

  Future<void> _verifyPayment() async {
    final reference = _result.reference;
    if (reference == null) {
      _onVerifyFailed('Payment reference missing — please contact support.');
      return;
    }

    final dio = ref.read(dioProvider);
    int attempt = 0;
    int delayMs = 2000;

    while (attempt < _kMaxVerifyRetries) {
      try {
        final response = await dio.post<Map<String, dynamic>>(
          '/api/v1/payments/verify',
          data: {'reference': reference, 'source': 'FLUTTER'},
        );

        final body   = response.data ?? {};
        final status = body['status'] as String? ?? '';

        if (status == 'success') {
          _onVerifySuccess();
          return;
        }

        if (status == 'pending') {
          await Future<void>.delayed(Duration(milliseconds: delayMs));
          delayMs = (delayMs * 1.5).round().clamp(0, 8000);
          attempt++;
          continue;
        }

        _onVerifyFailed(body['message'] as String? ?? 'Payment was not successful.');
        return;
      } on DioException catch (e) {
        final status = e.response?.statusCode ?? 0;
        if (status == 503 && attempt < _kMaxVerifyRetries - 1) {
          await Future<void>.delayed(Duration(milliseconds: delayMs));
          delayMs = (delayMs * 1.5).round().clamp(0, 8000);
          attempt++;
          continue;
        }
        _onVerifyFailed('Could not confirm payment. Please check My Store shortly.');
        return;
      } catch (_) {
        _onVerifyFailed('Could not confirm payment. Please check My Store shortly.');
        return;
      }
    }

    _onVerifyFailed('Payment is still processing. Please check back shortly.');
  }

  void _onVerifySuccess() {
    if (_navigated || !mounted) return;
    _navigated = true;
    setState(() => _phase = _PaymentPhase.success);

    ref.invalidate(myVendorSubscriptionProvider);
    ref.invalidate(subscriptionPlansProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 Welcome! Your store is now active.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
      ),
    );

    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        context.go(AppRoutes.vendor);
      }),
    );
  }

  void _onVerifyFailed(String message) {
    if (!mounted) return;
    setState(() {
      _phase        = _PaymentPhase.failed;
      _errorMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        leading: _phase == _PaymentPhase.webview
            ? IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Cancel payment',
                onPressed: () => context.go(AppRoutes.vendor),
              )
            : null,
        automaticallyImplyLeading: false,
      ),
      body: switch (_phase) {
        _PaymentPhase.webview  => _buildWebView(),
        _PaymentPhase.verifying => _buildVerifying(),
        _PaymentPhase.success  => _buildSuccess(),
        _PaymentPhase.failed   => _buildFailed(),
      },
    );
  }

  Widget _buildWebView() {
    return Stack(
      children: [
        InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri(_result.authorizationUrl!),
          ),
          initialSettings: _webSettings,
          onLoadStart: (_, __) {
            if (mounted) setState(() => _webLoading = true);
          },
          onLoadStop: (_, __) {
            if (mounted) setState(() => _webLoading = false);
          },
          onProgressChanged: (_, progress) {
            if (progress == 100 && mounted) setState(() => _webLoading = false);
          },
          shouldOverrideUrlLoading: (controller, action) async {
            final uri    = action.request.url;
            final scheme = uri?.scheme ?? '';

            if (_isCallbackUrl(uri)) {
              _onPaymentAttemptComplete();
              return NavigationActionPolicy.CANCEL;
            }

            if (scheme != 'http' && scheme != 'https') {
              unawaited(
                launchUrl(
                  Uri.parse(uri.toString()),
                  mode: LaunchMode.externalApplication,
                ).catchError((_) => false),
              );
              if (mounted) setState(() => _externalLaunched = true);
              return NavigationActionPolicy.CANCEL;
            }

            if (!_isAllowedHost(uri)) {
              return NavigationActionPolicy.CANCEL;
            }

            return NavigationActionPolicy.ALLOW;
          },
        ),
        if (_webLoading && !_externalLaunched)
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        if (_externalLaunched) _buildExternalOverlay(),
      ],
    );
  }

  Widget _buildExternalOverlay() {
    return Positioned(
      left: 0, right: 0, bottom: 0,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.smartphone_outlined, size: 40, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(
              'Complete your payment in the app that opened,\n'
              'then tap below to confirm.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _onPaymentAttemptComplete,
                icon: const Icon(Icons.verified_outlined),
                label: const Text("I've Paid — Confirm"),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go(AppRoutes.vendor),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerifying() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(strokeWidth: 2),
          SizedBox(height: 20),
          Text('Confirming your payment…', style: TextStyle(fontSize: 16)),
          SizedBox(height: 8),
          Text('Please do not close this screen.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, color: AppColors.success, size: 64),
          SizedBox(height: 16),
          Text('Payment confirmed!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildFailed() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 56),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Payment could not be confirmed.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                setState(() {
                  _phase        = _PaymentPhase.verifying;
                  _errorMessage = null;
                });
                _verifyPayment();
              },
              child: const Text('Retry Verification'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go(AppRoutes.vendor),
              child: const Text('Back to My Store'),
            ),
          ],
        ),
      ),
    );
  }
}

enum _PaymentPhase { webview, verifying, success, failed }
