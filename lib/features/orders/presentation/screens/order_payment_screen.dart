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
import '../../data/models/checkout_result_model.dart';

// ── Allowed Paystack domains ──────────────────────────────────────────────────
// Only these hosts may load in the WebView without being blocked.
// This prevents open-redirect attacks where a compromised Paystack page tries
// to redirect the WebView to a phishing site.
const _kAllowedHosts = {
  'checkout.paystack.com',
  'paystack.com',
  'standard.paystack.com',
  'api.paystack.co',
  // bank / wallet pages Paystack redirects through
  'hostedpay.gtbank.com',
  'pay.opay.ng',
  'netpay.firstbanknigeria.com',
};

// Paystack redirects back to THIS host+path after the customer completes payment.
// Must match the callback_url configured in the Paystack dashboard.
const _kCallbackHost = 'cometake.net';
const _kCallbackPaths = ['/checkout/callback', '/checkout/verify', '/api/v1/payments/verify'];

// Retry ceiling for verify polling (pending → success can take several seconds
// for bank transfers). 8 attempts × exponential backoff ≈ ~30s total wait.
const _kMaxVerifyRetries = 8;

class OrderPaymentScreen extends ConsumerStatefulWidget {
  final CheckoutResultModel result;

  const OrderPaymentScreen({super.key, required this.result});

  @override
  ConsumerState<OrderPaymentScreen> createState() => _OrderPaymentScreenState();
}

class _OrderPaymentScreenState extends ConsumerState<OrderPaymentScreen>
    with WidgetsBindingObserver {
  late final CheckoutResultModel _result = widget.result;

  // Loading state for the initial page render
  bool _webLoading = true;

  // Whether the user was sent to an external app (bank/wallet deep link)
  bool _externalLaunched = false;

  // After WebView closes, transitions to verify → success/failure
  _PaymentPhase _phase = _PaymentPhase.webview;

  // Error message shown in the failure state
  String? _errorMessage;

  // Guards double-pop / double-navigation
  bool _navigated = false;

  // thirdPartyCookiesEnabled: required by Paystack's cookie-support test page.
  // useShouldOverrideUrlLoading: must be true to receive the callback in shouldOverrideUrlLoading.
  static final _webSettings = InAppWebViewSettings(
    thirdPartyCookiesEnabled:    true,
    useShouldOverrideUrlLoading: true,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    debugPrint('[OrderPayment] init | paymentId=${_result.paymentId} '
        'ref=${_result.reference}');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('[OrderPayment] lifecycle=$state');
  }

  // ── URL interception ────────────────────────────────────────────────────────

  bool _isCallbackUrl(WebUri? uri) {
    if (uri == null) return false;
    if (uri.host != _kCallbackHost) return false;
    return _kCallbackPaths.any((p) => uri.path.startsWith(p));
  }

  bool _isAllowedHost(WebUri? uri) {
    if (uri == null) return true; // null = no navigation
    final scheme = uri.scheme;
    if (scheme != 'http' && scheme != 'https') return false; // handled below
    return _kAllowedHosts.contains(uri.host) || uri.host == _kCallbackHost;
  }

  // Called when Paystack redirects to our callback URL or user confirms manual pay.
  void _onPaymentAttemptComplete() {
    if (_navigated) return;
    setState(() => _phase = _PaymentPhase.verifying);
    _verifyPayment();
  }

  // ── Verify via Next.js backend ──────────────────────────────────────────────

  Future<void> _verifyPayment() async {
    final reference = _result.reference;
    if (reference == null) {
      _onVerifyFailed('Payment reference missing — cron will complete your order shortly.');
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
          _onVerifySuccess(body['orderId'] as String? ?? _result.orderId);
          return;
        }

        if (status == 'pending') {
          debugPrint('[OrderPayment] verify pending (attempt $attempt) — '
              'retry in ${delayMs}ms');
          await Future<void>.delayed(Duration(milliseconds: delayMs));
          delayMs = (delayMs * 1.5).round().clamp(0, 8000);
          attempt++;
          continue;
        }

        // status == 'failed' or unknown
        _onVerifyFailed(body['message'] as String? ?? 'Payment was not successful.');
        return;
      } on DioException catch (e) {
        final status = e.response?.statusCode ?? 0;
        if (status == 503 && attempt < _kMaxVerifyRetries - 1) {
          // Gateway temporarily unavailable — retry
          await Future<void>.delayed(Duration(milliseconds: delayMs));
          delayMs = (delayMs * 1.5).round().clamp(0, 8000);
          attempt++;
          continue;
        }
        _onVerifyFailed('Could not confirm payment. Your order is safe — '
            'we will complete it automatically.');
        return;
      } catch (_) {
        _onVerifyFailed('Could not confirm payment. Your order is safe — '
            'we will complete it automatically.');
        return;
      }
    }

    // Exhausted retries — cron will pick this up
    _onVerifyFailed('Payment is still processing. We will notify you when it completes.');
  }

  void _onVerifySuccess(String orderId) {
    if (_navigated || !mounted) return;
    _navigated = true;
    setState(() => _phase = _PaymentPhase.success);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment successful! Your order is confirmed.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
      ),
    );

    // Small delay so the user sees the success indicator before navigating away.
    // Intentionally not awaited — this is a fire-and-forget UI transition.
    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        context.go(AppRoutes.orderDetailPath(orderId));
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

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        leading: _phase == _PaymentPhase.webview
            ? IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Cancel payment',
                onPressed: () {
                  debugPrint('[OrderPayment] user cancelled | ref=${_result.reference}');
                  context.go(AppRoutes.orderDetailPath(_result.orderId));
                },
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
          onWebViewCreated: (_) {
            debugPrint('[OrderPayment] WebView created');
          },
          onLoadStart: (_, url) {
            debugPrint('[OrderPayment] load start: $url');
            if (mounted) setState(() => _webLoading = true);
          },
          onLoadStop: (_, url) {
            debugPrint('[OrderPayment] load stop: $url');
            if (mounted) setState(() => _webLoading = false);
          },
          onProgressChanged: (_, progress) {
            if (progress == 100 && mounted) setState(() => _webLoading = false);
          },
          onReceivedError: (_, request, error) {
            debugPrint('[OrderPayment] error: ${error.description} '
                'url=${request.url}');
          },
          shouldOverrideUrlLoading: (controller, action) async {
            final uri    = action.request.url;
            final scheme = uri?.scheme ?? '';
            debugPrint('[OrderPayment] nav: $uri (scheme=$scheme)');

            // ── Callback URL: payment complete ─────────────────────────────
            if (_isCallbackUrl(uri)) {
              debugPrint('[OrderPayment] callback URL detected → verifying');
              _onPaymentAttemptComplete();
              return NavigationActionPolicy.CANCEL;
            }

            // ── Non-HTTP scheme: external app (bank, OPay, etc.) ───────────
            if (scheme != 'http' && scheme != 'https') {
              debugPrint('[OrderPayment] deep link → external: $uri');
              launchUrl(
                Uri.parse(uri.toString()),
                mode: LaunchMode.externalApplication,
              ).catchError((_) => false);
              if (mounted) setState(() => _externalLaunched = true);
              return NavigationActionPolicy.CANCEL;
            }

            // ── Unknown host: block (security) ─────────────────────────────
            if (!_isAllowedHost(uri)) {
              debugPrint('[OrderPayment] BLOCKED unknown host: ${uri?.host}');
              return NavigationActionPolicy.CANCEL;
            }

            return NavigationActionPolicy.ALLOW;
          },
        ),

        // Initial page load spinner
        if (_webLoading && !_externalLaunched)
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),

        // External app launched overlay — user pays in bank app, taps confirm here
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
                label: const Text("I've Paid — Confirm Order"),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go(AppRoutes.orderDetailPath(_result.orderId)),
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
          Text(
            'Please do not close this screen.',
            style: TextStyle(color: Colors.grey),
          ),
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
                  _phase       = _PaymentPhase.verifying;
                  _errorMessage = null;
                });
                _verifyPayment();
              },
              child: const Text('Retry Verification'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go(AppRoutes.orders),
              child: const Text('View My Orders'),
            ),
          ],
        ),
      ),
    );
  }
}

enum _PaymentPhase { webview, verifying, success, failed }
