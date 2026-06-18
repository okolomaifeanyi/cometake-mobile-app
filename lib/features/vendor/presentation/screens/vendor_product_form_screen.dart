import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/providers/products_provider.dart';
import '../providers/vendor_provider.dart';

class VendorProductFormScreen extends ConsumerStatefulWidget {
  final Product? product; // null = create, non-null = edit

  const VendorProductFormScreen({super.key, this.product});

  @override
  ConsumerState<VendorProductFormScreen> createState() =>
      _VendorProductFormScreenState();
}

class _VendorProductFormScreenState
    extends ConsumerState<VendorProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _comparePriceCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();

  File? _pickedImage;
  String? _selectedCategoryId;
  bool _isActive = true;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final p = widget.product!;
      _nameCtrl.text = p.name;
      _descCtrl.text = p.description;
      _priceCtrl.text = p.price.toString();
      _comparePriceCtrl.text = p.comparePrice?.toString() ?? '';
      _selectedCategoryId = p.categoryId;
      _isActive = p.isActive;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _comparePriceCtrl.dispose();
    _quantityCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    final notifier = ref.read(productMutationProvider.notifier);

    bool success;
    if (_isEdit) {
      success = await notifier.update(
        productId: widget.product!.id,
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        price: double.parse(_priceCtrl.text),
        comparePrice: _comparePriceCtrl.text.isNotEmpty
            ? double.tryParse(_comparePriceCtrl.text)
            : null,
        quantity: int.tryParse(_quantityCtrl.text) ?? 1,
        categoryId: _selectedCategoryId,
        imageFile: _pickedImage,
        isActive: _isActive,
      );
    } else {
      success = await notifier.create(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        price: double.parse(_priceCtrl.text),
        comparePrice: _comparePriceCtrl.text.isNotEmpty
            ? double.tryParse(_comparePriceCtrl.text)
            : null,
        quantity: int.tryParse(_quantityCtrl.text) ?? 1,
        categoryId: _selectedCategoryId!,
        imageFile: _pickedImage,
      );
    }

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(_isEdit ? 'Product updated!' : 'Product created!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mutationState = ref.watch(productMutationProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
          title: Text(_isEdit ? 'Edit Product' : 'Add Product')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Image picker ────────────────────────────────────
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMd),
                    border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .outlineVariant),
                  ),
                  child: _pickedImage != null
                      ? ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusMd),
                          child: Image.file(_pickedImage!,
                              fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                size: 40,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant),
                            const SizedBox(
                                height: AppDimensions.spacingSm),
                            Text(
                              _isEdit
                                  ? 'Tap to change image'
                                  : 'Tap to add image',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingLg),

              // ─── Name ────────────────────────────────────────────
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMd)),
                ),
                validator: (v) => Validators.required(v, label: 'Name'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppDimensions.spacingMd),

              // ─── Description ──────────────────────────────────────
              TextFormField(
                controller: _descCtrl,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMd)),
                ),
                minLines: 3,
                maxLines: 6,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppDimensions.spacingMd),

              // ─── Price row ────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceCtrl,
                      decoration: InputDecoration(
                        labelText: 'Price (₦)',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMd)),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9.]'))
                      ],
                      validator: (v) {
                        final n = double.tryParse(v ?? '');
                        if (n == null || n <= 0)
                          return 'Enter a valid price';
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingMd),
                  Expanded(
                    child: TextFormField(
                      controller: _comparePriceCtrl,
                      decoration: InputDecoration(
                        labelText: 'Compare Price (₦)',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMd)),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9.]'))
                      ],
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingMd),

              // ─── Quantity ─────────────────────────────────────────
              TextFormField(
                controller: _quantityCtrl,
                decoration: InputDecoration(
                  labelText: 'Quantity in Stock',
                  border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMd)),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppDimensions.spacingMd),

              // ─── Category ─────────────────────────────────────────
              categoriesAsync.when(
                loading: () => const SizedBox(
                    height: 56,
                    child: Center(
                        child:
                            CircularProgressIndicator(strokeWidth: 2))),
                error: (_, __) => const SizedBox.shrink(),
                data: (categories) => DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMd)),
                  ),
                  items: categories
                      .map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _selectedCategoryId = v),
                  validator: (v) =>
                      v == null ? 'Select a category' : null,
                ),
              ),

              if (_isEdit) ...[
                const SizedBox(height: AppDimensions.spacingMd),
                SwitchListTile(
                  title: const Text('Listed (visible to buyers)'),
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                  contentPadding: EdgeInsets.zero,
                ),
              ],

              const SizedBox(height: AppDimensions.spacingXl),

              if (mutationState.error != null)
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: AppDimensions.spacingMd),
                  child: Text(
                    mutationState.error!,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.error),
                  ),
                ),

              AppButton(
                label: _isEdit ? 'Update Product' : 'Create Product',
                onPressed: mutationState.isLoading ? null : _submit,
                isLoading: mutationState.isLoading,
                icon: const Icon(Icons.check),
              ),

              const SizedBox(height: AppDimensions.spacingMd),
            ],
          ),
        ),
      ),
    );
  }
}
