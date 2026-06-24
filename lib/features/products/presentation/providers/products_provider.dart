import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/supabase/supabase_module.dart';
import '../../data/datasources/supabase_products_datasource.dart';
import '../../data/repositories/products_repository_impl.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/products_repository.dart';

part 'products_provider.freezed.dart';

// ─── DI providers ────────────────────────────────────────────────────────────

final productsDatasourceProvider = Provider<SupabaseProductsDatasource>(
  (ref) => SupabaseProductsDatasource(ref.watch(supabaseClientProvider)),
  name: 'productsDatasourceProvider',
);

final productsRepositoryProvider = Provider<ProductsRepository>(
  (ref) =>
      ProductsRepositoryImpl(ref.watch(productsDatasourceProvider)),
  name: 'productsRepositoryProvider',
);

// ─── State ────────────────────────────────────────────────────────────────────

@freezed
class ProductsState with _$ProductsState {
  const factory ProductsState({
    @Default([]) List<Product> products,
    @Default(false) bool hasMore,
    @Default(1) int page,
    @Default(false) bool isLoadingMore,
    String? search,
    String? categoryId,
    String? sort,
  }) = _ProductsState;
}

// ─── Products notifier ────────────────────────────────────────────────────────

final productsNotifierProvider =
    AsyncNotifierProvider<ProductsNotifier, ProductsState>(
  ProductsNotifier.new,
  name: 'productsNotifierProvider',
);

class ProductsNotifier extends AsyncNotifier<ProductsState> {
  static const _limit = 20;

  @override
  Future<ProductsState> build() => _fetch(const ProductsState());

  Future<ProductsState> _fetch(ProductsState filters) async {
    final result = await ref.read(productsRepositoryProvider).getProducts(
          page: filters.page,
          search: filters.search,
          categoryId: filters.categoryId,
          sort: filters.sort,
        );
    return filters.copyWith(
      products: result.products,
      hasMore: result.hasMore,
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final nextPage = current.page + 1;
      final result = await ref.read(productsRepositoryProvider).getProducts(
            page: nextPage,
            search: current.search,
            categoryId: current.categoryId,
            sort: current.sort,
          );
      state = AsyncData(current.copyWith(
        products: [...current.products, ...result.products],
        hasMore: result.hasMore,
        page: nextPage,
        isLoadingMore: false,
      ),);
    } on AppException catch (e) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
      // Surface error without discarding list
      Error.throwWithStackTrace(ErrorHandler.handle(e), StackTrace.current);
    } catch (_) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> refresh() async {
    final current = state.valueOrNull ?? const ProductsState();
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetch(current.copyWith(page: 1, products: [], isLoadingMore: false)),
    );
  }

  Future<void> applySearch(String? query) async {
    final trimmed = (query ?? '').trim();
    final current = state.valueOrNull ?? const ProductsState();
    final newSearch = trimmed.isEmpty ? null : trimmed;
    if (newSearch == current.search) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetch(current.copyWith(
        page: 1,
        products: [],
        search: newSearch,
        isLoadingMore: false,
      ),),
    );
  }

  Future<void> applyCategory(String? categoryId) async {
    final current = state.valueOrNull ?? const ProductsState();
    if (categoryId == current.categoryId) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetch(current.copyWith(
        page: 1,
        products: [],
        categoryId: categoryId,
        isLoadingMore: false,
      ),),
    );
  }

  Future<void> applySort(String? sort) async {
    final current = state.valueOrNull ?? const ProductsState();
    if (sort == current.sort) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetch(current.copyWith(
        page: 1,
        products: [],
        sort: sort,
        isLoadingMore: false,
      ),),
    );
  }
}

// ─── Product detail provider ──────────────────────────────────────────────────

final productDetailProvider =
    AsyncNotifierProvider.autoDispose.family<ProductDetailNotifier, Product, String>(
  ProductDetailNotifier.new,
  name: 'productDetailProvider',
);

class ProductDetailNotifier
    extends AutoDisposeFamilyAsyncNotifier<Product, String> {
  @override
  Future<Product> build(String id) =>
      ref.watch(productsRepositoryProvider).getProductById(id);
}

// ─── Categories provider ──────────────────────────────────────────────────────

final categoriesProvider =
    FutureProvider.autoDispose<List<ProductCategory>>((ref) {
  return ref.watch(productsRepositoryProvider).getCategories();
}, name: 'categoriesProvider',);
