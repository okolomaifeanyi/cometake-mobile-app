import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';
import '../../../cart/domain/entities/cart.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../domain/entities/order.dart';
import '../providers/orders_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  Address? _selectedAddress;
  bool _showAddressForm = false;

  @override
  void initState() {
    super.initState();
    // Auto-select default address when addresses load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final addresses = ref.read(addressesProvider).valueOrNull ?? [];
      if (addresses.isNotEmpty) {
        setState(() {
          _selectedAddress =
              addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first);
        });
      } else {
        setState(() => _showAddressForm = true);
      }
    });
  }

  Future<void> _placeOrder() async {
    if (_selectedAddress == null) return;

    final notifier = ref.read(checkoutProvider.notifier);
    final order = await notifier.placeOrder(addressId: _selectedAddress!.id);

    if (!mounted) return;
    if (order != null) {
      context.go(AppRoutes.orderDetailPath(order.id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order placed successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartNotifierProvider);
    final addressesAsync = ref.watch(addressesProvider);
    final checkoutAsync = ref.watch(checkoutProvider);
    final isPlacing = checkoutAsync.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Order summary ─────────────────────────────────────
            Text('Order Summary',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),),
            const SizedBox(height: AppDimensions.spacingSm),
            cartAsync.whenOrNull(
              data: (cart) => _OrderSummaryCard(cart: cart),
            ) ?? const SizedBox.shrink(),

            const SizedBox(height: AppDimensions.spacingLg),

            // ─── Delivery address ──────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Delivery Address',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),),
                TextButton(
                  onPressed: () =>
                      setState(() => _showAddressForm = !_showAddressForm),
                  child: Text(_showAddressForm ? 'Cancel' : '+ New'),
                ),
              ],
            ),

            if (_showAddressForm)
              _AddressForm(
                onSaved: (address) {
                  setState(() {
                    _selectedAddress = address;
                    _showAddressForm = false;
                  });
                },
              )
            else
              addressesAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(AppDimensions.spacingMd),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (_, __) => const Text('Failed to load addresses'),
                data: (addresses) => addresses.isEmpty
                    ? const Text('No addresses saved. Add one above.')
                    : _AddressPicker(
                        addresses: addresses,
                        selected: _selectedAddress,
                        onChanged: (a) => setState(() => _selectedAddress = a),
                      ),
              ),

            const SizedBox(height: AppDimensions.spacingXl),

            if (checkoutAsync.hasError)
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.spacingMd),
                child: Text(
                  checkoutAsync.error.toString(),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),

            AppButton(
              label: 'Place Order',
              onPressed:
                  _selectedAddress != null && !isPlacing ? _placeOrder : null,
              isLoading: isPlacing,
              icon: const Icon(Icons.check_circle_outline),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Order summary card ────────────────────────────────────────────────────────

class _OrderSummaryCard extends StatelessWidget {
  final Cart cart;
  const _OrderSummaryCard({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${cart.totalItems} ${cart.totalItems == 1 ? 'item' : 'items'}',
              style: Theme.of(context).textTheme.bodyMedium,),
          Text(
            Formatters.currency(cart.subtotal),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

// ─── Address picker ────────────────────────────────────────────────────────────

class _AddressPicker extends StatelessWidget {
  final List<Address> addresses;
  final Address? selected;
  final ValueChanged<Address> onChanged;

  const _AddressPicker({
    required this.addresses,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: addresses.map((a) {
        final isSelected = selected?.id == a.id;
        return GestureDetector(
          onTap: () => onChanged(a),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
            padding: const EdgeInsets.all(AppDimensions.spacingMd),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : Theme.of(context).colorScheme.outlineVariant,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isSelected
                      ? AppColors.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppDimensions.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.fullName,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),),
                      Text(a.summary,
                          style: Theme.of(context).textTheme.bodySmall,),
                      Text(a.phone,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),),
                    ],
                  ),
                ),
                if (a.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                    child: const Text('Default',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,),),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Address form ─────────────────────────────────────────────────────────────

class _AddressForm extends ConsumerStatefulWidget {
  final ValueChanged<Address> onSaved;
  const _AddressForm({required this.onSaved});

  @override
  ConsumerState<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends ConsumerState<_AddressForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  bool _isDefault = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final address = await ref.read(addressesProvider.notifier).createAddress(
          fullName: _nameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          street: _streetCtrl.text.trim(),
          city: _cityCtrl.text.trim(),
          state: _stateCtrl.text.trim(),
          isDefault: _isDefault,
        );
    setState(() => _saving = false);
    if (address != null && mounted) widget.onSaved(address);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: AppDimensions.spacingSm),
          AuthTextField(
            label: 'Full name',
            hint: 'Recipient name',
            controller: _nameCtrl,
            validator: (v) => Validators.required(v, label: 'Full name'),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          AuthPhoneField(
            controller: _phoneCtrl,
            validator: (v) => Validators.phone(v ?? ''),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          AuthTextField(
            label: 'Street address',
            hint: '12 Broad Street',
            controller: _streetCtrl,
            validator: (v) => Validators.required(v, label: 'Street'),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Row(
            children: [
              Expanded(
                child: AuthTextField(
                  label: 'City',
                  hint: 'Lagos',
                  controller: _cityCtrl,
                  validator: (v) => Validators.required(v, label: 'City'),
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: AuthTextField(
                  label: 'State',
                  hint: 'Lagos',
                  controller: _stateCtrl,
                  validator: (v) => Validators.required(v, label: 'State'),
                  textInputAction: TextInputAction.done,
                ),
              ),
            ],
          ),
          SwitchListTile(
            title: const Text('Set as default'),
            value: _isDefault,
            onChanged: (v) => setState(() => _isDefault = v),
            contentPadding: EdgeInsets.zero,
          ),
          AppButton(
            label: 'Save Address',
            onPressed: _saving ? null : _save,
            isLoading: _saving,
          ),
          const SizedBox(height: AppDimensions.spacingMd),
        ],
      ),
    );
  }
}
