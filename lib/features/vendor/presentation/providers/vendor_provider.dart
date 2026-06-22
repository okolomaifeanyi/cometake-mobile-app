import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/cloudinary_service.dart';
import '../../../home/presentation/providers/home_products_provider.dart';
import '../../../products/data/models/product_model.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/providers/products_provider.dart';
import '../../data/datasources/vendor_datasource.dart';

// ─── Vendor products list ─────────────────────────────────────────────────────

class VendorProductsNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
    final ds = ref.watch(vendorDatasourceProvider);
    final models = await ds.fetchMyProducts();
    return models.map((m) => m.toEntity()).toList();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  void removeLocal(String productId) {
    final current = state.valueOrNull ?? [];
    state = AsyncData(current.where((p) => p.id != productId).toList());
  }
}

final vendorProductsProvider =
    AsyncNotifierProvider<VendorProductsNotifier, List<Product>>(
        () => VendorProductsNotifier(),);

// ─── Product create/update/delete notifier ────────────────────────────────────

class ProductMutationState {
  final bool isLoading;
  final String? error;
  final bool success;

  const ProductMutationState(
      {this.isLoading = false, this.error, this.success = false,});

  ProductMutationState copyWith(
          {bool? isLoading, String? error, bool? success,}) =>
      ProductMutationState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        success: success ?? this.success,
      );
}

class ProductMutationNotifier
    extends AutoDisposeNotifier<ProductMutationState> {
  @override
  ProductMutationState build() => const ProductMutationState();

  Future<String?> _uploadProductImage(File file) async {
    return ref.read(cloudinaryServiceProvider).uploadImage(
      file: file,
      folder: 'product_media',
    );
  }

  Future<bool> create({
    required String name,
    required String description,
    required double price,
    double? comparePrice,
    required int quantity,
    required String categoryId,
    File? imageFile,
  }) async {
    state = const ProductMutationState(isLoading: true);
    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadProductImage(imageFile);
      }

      final ds = ref.read(vendorDatasourceProvider);
      await ds.createProduct({
        'name': name,
        'description': description,
        'price': price,
        if (comparePrice != null) 'comparePrice': comparePrice,
        'quantity': quantity,
        'categoryId': categoryId,
        if (imageUrl != null) 'images': [imageUrl],
        'isActive': true,
      });

      state = const ProductMutationState(success: true);
      ref.read(vendorProductsProvider.notifier).refresh();
      ref.invalidate(homeProductPoolProvider);
      ref.invalidate(productsNotifierProvider);
      return true;
    } catch (e) {
      state = ProductMutationState(error: e.toString());
      return false;
    }
  }

  Future<bool> update({
    required String productId,
    String? name,
    String? description,
    double? price,
    double? comparePrice,
    int? quantity,
    String? categoryId,
    File? imageFile,
    bool? isActive,
  }) async {
    state = const ProductMutationState(isLoading: true);
    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadProductImage(imageFile);
      }

      final dto = <String, dynamic>{
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (price != null) 'price': price,
        if (comparePrice != null) 'comparePrice': comparePrice,
        if (quantity != null) 'quantity': quantity,
        if (categoryId != null) 'categoryId': categoryId,
        if (imageUrl != null) 'images': [imageUrl],
        if (isActive != null) 'isActive': isActive,
      };

      final ds = ref.read(vendorDatasourceProvider);
      await ds.updateProduct(productId, dto);

      state = const ProductMutationState(success: true);
      ref.read(vendorProductsProvider.notifier).refresh();
      ref.invalidate(homeProductPoolProvider);
      ref.invalidate(productsNotifierProvider);
      return true;
    } catch (e) {
      state = ProductMutationState(error: e.toString());
      return false;
    }
  }

  Future<bool> delete(String productId) async {
    state = const ProductMutationState(isLoading: true);
    try {
      final ds = ref.read(vendorDatasourceProvider);
      await ds.deleteProduct(productId);

      ref.read(vendorProductsProvider.notifier).removeLocal(productId);
      state = const ProductMutationState(success: true);
      return true;
    } catch (e) {
      state = ProductMutationState(error: e.toString());
      return false;
    }
  }

  void reset() => state = const ProductMutationState();
}

final productMutationProvider =
    AutoDisposeNotifierProvider<ProductMutationNotifier, ProductMutationState>(
        () => ProductMutationNotifier(),);
