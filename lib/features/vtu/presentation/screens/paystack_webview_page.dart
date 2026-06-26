import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';

/// Opens Paystack's authorization URL in an in-app WebView.
///
/// Why flutter_inappwebview instead of webview_flutter:
///   webview_flutter v4 has no API for thirdPartyCookiesEnabled. Android
///   WebView disables third-party cookies by default, which causes
///   Paystack's cookie-support test (paystack.com/public/test/cookie-support/
///   start.html) to fail with ERR_BLOCK_BY_RESPONSE before the checkout
///   form even loads. flutter_inappwebview exposes this as a first-class
///   setting.
///
/// Completion paths:
///   A. Paystack redirects to cometake.net/vtu/verify → auto-detected,
///      pop(true) fires immediately.
///   B. Paystack redirects to a bank/wallet deep link (btravel://, opay://)
///      → launched externally; overlay shown with manual "I've Paid" button.
///      The user presses "I've Paid" after returning from the payment app.
///      No auto-pop on resume — OPay→Paystack confirmation can take 5–15s,
///      so auto-verifying immediately races the bank's confirmation window.
class PaystackWebViewPage extends StatefulWidget {
  final String authorizationUrl;
  final String reference;

  const PaystackWebViewPage({
    super.key,
    required this.authorizationUrl,
    required this.reference,
  });

  @override
  State<PaystackWebViewPage> createState() => _PaystackWebViewPageState();
}

class _PaystackWebViewPageState extends State<PaystackWebViewPage>
    with WidgetsBindingObserver {
  InAppWebViewController? _controller;
  bool _loading = true;
  bool _externalLaunched = false;
  // Guards all pop paths — prevents double-pop if the manual button and the
  // callback URL intercept somehow race each other.
  bool _popFired = false;

  static const _callbackHosts = ['cometake.net'];
  static const _callbackPaths = ['/vtu/verify', '/checkout/verify'];

  // No userAgent override — use device default so Paystack sees the real
  // browser. No MIXED_CONTENT_ALWAYS_ALLOW — enable only if testing proves
  // it's required.
  static final _settings = InAppWebViewSettings(
    javaScriptEnabled: true,
    domStorageEnabled: true,
    thirdPartyCookiesEnabled: true,
    useShouldOverrideUrlLoading: true,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    debugPrint('[Paystack] WebView init | ref=${widget.reference}');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('[Paystack] Lifecycle: $state '
        '| externalLaunched=$_externalLaunched');
  }

  void _safePopTrue() {
    if (_popFired || !mounted) return;
    _popFired = true;
    Navigator.pop(context, true);
  }

  bool _isCallbackUrl(WebUri? uri) {
    if (uri == null) return false;
    if (!_callbackHosts.contains(uri.host)) return false;
    return _callbackPaths.any((p) => uri.path.startsWith(p));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paystack Payment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            debugPrint('[Paystack] User closed WebView | ref=${widget.reference}');
            Navigator.pop(context, false);
          },
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(widget.authorizationUrl),
            ),
            initialSettings: _settings,
            onWebViewCreated: (controller) {
              _controller = controller;
              debugPrint('[Paystack] WebView created');
            },
            onLoadStart: (controller, url) {
              debugPrint('[Paystack] Load start: $url');
              if (mounted) setState(() => _loading = true);
            },
            onLoadStop: (controller, url) {
              debugPrint('[Paystack] Load complete: $url');
              if (mounted) setState(() => _loading = false);
            },
            onProgressChanged: (controller, progress) {
              if (progress == 100 && mounted) setState(() => _loading = false);
            },
            onReceivedError: (controller, request, error) {
              debugPrint('[Paystack] ERROR: ${error.description} '
                  '(type=${error.type}) url=${request.url}');
            },
            shouldOverrideUrlLoading: (controller, action) async {
              final uri = action.request.url;
              final scheme = uri?.scheme ?? '';
              debugPrint('[Paystack] Navigation: $uri (scheme=$scheme)');

              // ── Path A: our callback URL — payment confirmed automatically ─
              if (_isCallbackUrl(uri)) {
                debugPrint('[Paystack] Callback URL → pop(true)');
                _safePopTrue();
                return NavigationActionPolicy.CANCEL;
              }

              // ── Path B: deep link (btravel://, opay://, etc.) ────────────
              if (scheme != 'http' && scheme != 'https') {
                debugPrint('[Paystack] Deep link → launching externally: $uri');
                launchUrl(
                  Uri.parse(uri.toString()),
                  mode: LaunchMode.externalApplication,
                ).catchError((_) => false);
                if (mounted) setState(() => _externalLaunched = true);
                return NavigationActionPolicy.CANCEL;
              }

              return NavigationActionPolicy.ALLOW;
            },
          ),

          if (_loading && !_externalLaunched)
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),

          // ── Manual confirm overlay (Path B) ───────────────────────────────
          if (_externalLaunched)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.success,
                      size: 40,
                    ),
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
                        onPressed: _popFired ? null : () {
                          debugPrint('[Paystack] Manual verify tapped '
                              '| ref=${widget.reference}');
                          _safePopTrue();
                        },
                        icon: const Icon(Icons.verified_outlined),
                        label: const Text("I've Paid — Verify Purchase"),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.success,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        debugPrint('[Paystack] Cancelled by user '
                            '| ref=${widget.reference}');
                        Navigator.pop(context, false);
                      },
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
