import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/theme/app_colors.dart';

/// Opens Paystack's authorization URL in an in-app WebView.
///
/// Completion paths:
///   A. Paystack redirects to cometake.net/vtu/verify → auto-detected,
///      pop(true) fires immediately.
///   B. Paystack redirects to a bank/wallet deep link (btravel://, opay://, etc.)
///      → launched externally + manual "I've Paid" overlay shown.
///      When the user returns to this app, verification is auto-triggered after
///      a 1.5s settle window so the webhook has time to complete first.
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
  late final WebViewController _controller;
  bool _loading = true;
  bool _externalLaunched = false;
  bool _autoVerifyScheduled = false;

  static const _callbackHosts = ['cometake.net'];
  static const _callbackPaths = ['/vtu/verify', '/checkout/verify'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _loading = true),
          onPageFinished: (_) => setState(() => _loading = false),
          onNavigationRequest: (req) {
            final uri = Uri.tryParse(req.url);
            if (uri == null) return NavigationDecision.prevent;

            // ── Path A: our callback URL — payment confirmed automatically ──
            if (_isCallbackUrl(uri)) {
              Navigator.pop(context, true);
              return NavigationDecision.prevent;
            }

            // ── Path B: bank/wallet deep link (btravel://, opay://, etc.) ───
            if (uri.scheme != 'http' && uri.scheme != 'https') {
              launchUrl(uri, mode: LaunchMode.externalApplication)
                  .catchError((_) => false);
              if (mounted) setState(() => _externalLaunched = true);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onWebResourceError: (err) {
            if (err.isForMainFrame == false) return;
            if (err.errorCode == -1) return;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authorizationUrl));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (!_externalLaunched || _autoVerifyScheduled || !mounted) return;

    // User returned from external payment app. Wait 1.5s to give the Paystack
    // webhook time to arrive and complete before our manual verify fires.
    // If webhook already ran, fulfillVtuDirectPurchase returns early (idempotent).
    setState(() => _autoVerifyScheduled = true);
    Future<void>.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) Navigator.pop(context, true);
    });
  }

  bool _isCallbackUrl(Uri uri) {
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
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),

          if (_loading && !_externalLaunched)
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),

          // ── Manual confirm overlay (Path B) ─────────────────────────────
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
                    Icon(
                      _autoVerifyScheduled
                          ? Icons.hourglass_bottom_rounded
                          : Icons.check_circle_outline,
                      color: AppColors.success,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _autoVerifyScheduled
                          ? 'Verifying your payment…'
                          : 'Complete your payment in the app that just opened.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    if (!_autoVerifyScheduled) ...[
                      const SizedBox(height: 4),
                      Text(
                        'When done, tap the button below.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => Navigator.pop(context, true),
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
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                    ] else ...[
                      const SizedBox(height: 16),
                      const LinearProgressIndicator(),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
