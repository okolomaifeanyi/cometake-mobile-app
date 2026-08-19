import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  static const _confirmWord = 'DELETE';

  final _confirmCtrl = TextEditingController();
  bool _isDeleting = false;
  String? _error;

  bool get _canSubmit => _confirmCtrl.text.trim() == _confirmWord && !_isDeleting;

  @override
  void dispose() {
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() {
      _isDeleting = true;
      _error = null;
    });
    try {
      await ref.read(authNotifierProvider.notifier).deleteAccount();
      if (!mounted) return;
      context.go(AppRoutes.login);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'We could not delete your account. Please check your connection and try again.';
      });
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Delete Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.warning_amber_rounded, color: colorScheme.error, size: 40, semanticLabel: 'Warning'),
              const SizedBox(height: 16),
              Text(
                'This will permanently delete your account',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              const Text(
                'Deleting your account is permanent and cannot be undone. This will:\n\n'
                '• Sign you out of Cometake on all devices\n'
                '• Remove your profile, saved addresses, cart, and wishlist\n'
                '• Remove your login — you will need to create a new account to use Cometake again\n\n'
                'Your past orders and payment records are kept for legal and accounting purposes, '
                'but are no longer linked to your name or contact details.',
              ),
              const SizedBox(height: 24),
              Text('Type $_confirmWord to confirm', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmCtrl,
                onChanged: (_) => setState(() {}),
                textCapitalization: TextCapitalization.characters,
                enabled: !_isDeleting,
                decoration: const InputDecoration(
                  hintText: _confirmWord,
                  border: OutlineInputBorder(),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: colorScheme.error)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _canSubmit ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                  ),
                  child: _isDeleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Permanently Delete My Account'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _isDeleting ? null : () => context.pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
