import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../domain/entities/vtu.dart';
import '../providers/vtu_provider.dart';

class VtuPurchaseScreen extends ConsumerStatefulWidget {
  final VtuServiceType serviceType;

  const VtuPurchaseScreen({super.key, required this.serviceType});

  @override
  ConsumerState<VtuPurchaseScreen> createState() => _VtuPurchaseScreenState();
}

class _VtuPurchaseScreenState extends ConsumerState<VtuPurchaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _meterCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();

  VtuServiceType get _type => widget.serviceType;

  String? _selectedServiceId;
  VtuVariation? _selectedVariation;
  bool _meterVerified = false;
  bool _verifying = false;
  String? _meterType; // prepaid / postpaid for electricity

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _meterCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _verifyMerchant() async {
    final code = _meterCtrl.text.trim();
    if (code.isEmpty || _selectedServiceId == null) return;
    setState(() => _verifying = true);
    await ref.read(vtuMerchantVerifyProvider.notifier).verify(
          serviceId: _selectedServiceId!,
          billersCode: code,
          type: _meterType,
        );
    setState(() {
      _verifying = false;
      final state = ref.read(vtuMerchantVerifyProvider);
      _meterVerified = state.valueOrNull != null;
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final amount = _type.amountFromVariation
        ? _selectedVariation!.amount
        : double.tryParse(_amountCtrl.text) ?? 0;

    final success = await ref.read(vtuPurchaseProvider.notifier).purchase(
          serviceType: _type.name,
          provider: _selectedServiceId!,
          amount: amount,
          recipient: _type.needsMerchantVerify
              ? _meterCtrl.text.trim()
              : _phoneCtrl.text.trim(),
          variationCode: _selectedVariation?.variationCode,
          billersCode: _type.needsMerchantVerify ? _meterCtrl.text.trim() : null,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.read(vtuPurchaseProvider).message ?? 'Success!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(vtuServicesProvider(_type.category));
    final purchaseState = ref.watch(vtuPurchaseProvider);
    final merchantState = ref.watch(vtuMerchantVerifyProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_type.displayName)),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Provider picker ───────────────────────────────────
              _SectionLabel(text: 'Select ${_type == VtuServiceType.electricity ? 'DISCO' : 'Provider'}'),
              const SizedBox(height: AppDimensions.spacingSm),
              servicesAsync.when(
                loading: () => const Center(
                    child: Padding(
                  padding: EdgeInsets.all(AppDimensions.spacingMd),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),),
                error: (e, _) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      e is Exception
                          ? e.toString().replaceFirst(RegExp(r'^.*Exception:\s*'), '')
                          : e.toString(),
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                data: (services) => _ProviderGrid(
                  services: services,
                  selected: _selectedServiceId,
                  onSelected: (id) => setState(() {
                    _selectedServiceId = id;
                    _selectedVariation = null;
                    _meterVerified = false;
                    ref.read(vtuMerchantVerifyProvider.notifier).reset();
                  }),
                ),
              ),

              if (_selectedServiceId != null) ...[
                const SizedBox(height: AppDimensions.spacingLg),

                // ─── Variations (data / cable) ─────────────────────
                if (_type.hasVariations) ...[
                  _SectionLabel(
                      text: _type == VtuServiceType.data ? 'Select Bundle' : 'Select Plan',),
                  const SizedBox(height: AppDimensions.spacingSm),
                  _VariationPicker(
                    serviceId: _selectedServiceId!,
                    selected: _selectedVariation,
                    onSelected: (v) =>
                        setState(() => _selectedVariation = v),
                  ),
                ],

                // ─── Meter/SmartCard + verify (electricity / cable) ─
                if (_type.needsMerchantVerify) ...[
                  const SizedBox(height: AppDimensions.spacingLg),
                  _SectionLabel(
                      text: _type == VtuServiceType.electricity
                          ? 'Meter Number'
                          : 'SmartCard / Decoder Number',),
                  const SizedBox(height: AppDimensions.spacingSm),
                  if (_type == VtuServiceType.electricity) ...[
                    Row(
                      children: ['prepaid', 'postpaid'].map((t) {
                        return Expanded(
                          child: RadioListTile<String>(
                            title: Text(t[0].toUpperCase() + t.substring(1),
                                style: const TextStyle(fontSize: 13),),
                            value: t,
                            groupValue: _meterType,
                            onChanged: (v) => setState(() {
                              _meterType = v;
                              _meterVerified = false;
                            }),
                            contentPadding: EdgeInsets.zero,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppDimensions.spacingSm),
                  ],
                  TextFormField(
                    controller: _meterCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: _type == VtuServiceType.electricity
                          ? 'Enter meter number'
                          : 'Enter smartcard number',
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusMd),),
                      suffixIcon: TextButton(
                        onPressed: _verifying ? null : _verifyMerchant,
                        child: _verifying
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,),)
                            : const Text('Verify'),
                      ),
                    ),
                    validator: (v) => Validators.required(v,
                        label: _type == VtuServiceType.electricity
                            ? 'Meter number'
                            : 'Smartcard number',),
                    onChanged: (_) => setState(() => _meterVerified = false),
                  ),
                  if (merchantState.valueOrNull != null) ...[
                    const SizedBox(height: AppDimensions.spacingSm),
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.spacingMd),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.08),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMd),
                        border: Border.all(
                            color: AppColors.success.withOpacity(0.3),),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: AppColors.success, size: 18,),
                          const SizedBox(width: AppDimensions.spacingSm),
                          Expanded(
                            child: Text(
                              merchantState.valueOrNull!.customerName,
                              style: const TextStyle(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (merchantState.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: AppDimensions.spacingSm),
                      child: Text(
                        merchantState.error.toString(),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,),
                      ),
                    ),
                ],

                // ─── Phone field (airtime / data) ──────────────────
                if (!_type.needsMerchantVerify) ...[
                  const SizedBox(height: AppDimensions.spacingLg),
                  const _SectionLabel(text: 'Phone Number'),
                  const SizedBox(height: AppDimensions.spacingSm),
                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: '08012345678',
                      prefixText: '+234  ',
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusMd),),
                    ),
                    validator: (v) => Validators.phone(v ?? ''),
                  ),
                ],

                // ─── Amount (airtime / electricity) ────────────────
                if (!_type.amountFromVariation) ...[
                  const SizedBox(height: AppDimensions.spacingLg),
                  const _SectionLabel(text: 'Amount'),
                  const SizedBox(height: AppDimensions.spacingSm),
                  TextFormField(
                    controller: _amountCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      prefixText: '₦  ',
                      hintText: '500',
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusMd),),
                    ),
                    validator: (v) {
                      final n = double.tryParse(v ?? '');
                      if (n == null || n < 50) return 'Enter a valid amount';
                      return null;
                    },
                  ),
                ],

                // ─── Selected variation display ────────────────────
                if (_selectedVariation != null) ...[
                  const SizedBox(height: AppDimensions.spacingMd),
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.spacingMd),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMd),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _selectedVariation!.name,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          Formatters.currency(_selectedVariation!.amount),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppDimensions.spacingXl),

                // ─── Error display ─────────────────────────────────
                if (purchaseState.error != null)
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppDimensions.spacingMd,),
                    child: Text(
                      purchaseState.error!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error,),
                    ),
                  ),

                // ─── Submit ────────────────────────────────────────
                AppButton(
                  label: 'Proceed',
                  onPressed: _canSubmit ? _submit : null,
                  isLoading: purchaseState.isLoading,
                  icon: const Icon(Icons.check_circle_outline),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool get _canSubmit {
    if (_selectedServiceId == null) return false;
    if (_type.needsMerchantVerify && !_meterVerified) return false;
    if (_type.hasVariations && _selectedVariation == null) return false;
    if (_type == VtuServiceType.electricity && _meterType == null) return false;
    return true;
  }
}

// ─── Provider grid ────────────────────────────────────────────────────────────

class _ProviderGrid extends StatelessWidget {
  final List<VtuService> services;
  final String? selected;
  final ValueChanged<String> onSelected;

  const _ProviderGrid({
    required this.services,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.spacingSm,
      runSpacing: AppDimensions.spacingSm,
      children: services.map((s) {
        final isSelected = selected == s.serviceId;
        return ChoiceChip(
          label: Text(s.name),
          selected: isSelected,
          onSelected: (_) => onSelected(s.serviceId),
          selectedColor: AppColors.primary.withOpacity(0.12),
          labelStyle: TextStyle(
            color: isSelected ? AppColors.primary : null,
            fontWeight: isSelected ? FontWeight.w600 : null,
          ),
        );
      }).toList(),
    );
  }
}

// ─── Variation picker ─────────────────────────────────────────────────────────

class _VariationPicker extends ConsumerWidget {
  final String serviceId;
  final VtuVariation? selected;
  final ValueChanged<VtuVariation> onSelected;

  const _VariationPicker({
    required this.serviceId,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final variationsAsync = ref.watch(vtuVariationsProvider(serviceId));

    return variationsAsync.when(
      loading: () => const Center(
          child: Padding(
        padding: EdgeInsets.all(AppDimensions.spacingMd),
        child: CircularProgressIndicator(strokeWidth: 2),
      ),),
      error: (e, _) => Text(e.toString(),
          style:
              TextStyle(color: Theme.of(context).colorScheme.error),),
      data: (variations) => Column(
        children: variations.map((v) {
          final isSelected = selected?.variationCode == v.variationCode;
          return GestureDetector(
            onTap: () => onSelected(v),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              margin: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMd,
                vertical: AppDimensions.spacingSm,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : Theme.of(context).colorScheme.outlineVariant,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(v.name,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.normal,),),
                  ),
                  Text(
                    Formatters.currency(v.amount),
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.primary
                          : Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(fontWeight: FontWeight.w700),
      );
}
