import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/utils/debouncer.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../domain/entities/product.dart';
import '../providers/products_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/product_grid_shimmer.dart';

const _sortOptions = [
  ('newest', 'Newest first'),
  ('price_asc', 'Price: Low → High'),
  ('price_desc', 'Price: High → Low'),
  ('oldest', 'Oldest first'),
];

class ProductsScreen extends ConsumerStatefulWidget {
  final String? initialCategory;

  const ProductsScreen({super.key, this.initialCategory});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _debouncer = Debouncer(duration: const Duration(milliseconds: 450));

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    final cat = widget.initialCategory;
    if (cat != null && cat.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(productsNotifierProvider.notifier).applyCategory(cat);
      });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      ref.read(productsNotifierProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsNotifierProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(productsNotifierProvider.notifier).refresh(),
        child: CustomScrollView(
          controller: _scrollCtrl,
          slivers: [
            // ─── App bar + search ──────────────────────────────────
            SliverAppBar(
              floating: true,
              snap: true,
              title: const Text('Products'),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.screenPaddingH,
                    0,
                    AppDimensions.screenPaddingH,
                    AppDimensions.spacingSm,
                  ),
                  child: _SearchBar(
                    controller: _searchCtrl,
                    onChanged: (q) => _debouncer.run(
                      () => ref
                          .read(productsNotifierProvider.notifier)
                          .applySearch(q),
                    ),
                    onClear: () {
                      _searchCtrl.clear();
                      ref
                          .read(productsNotifierProvider.notifier)
                          .applySearch(null);
                    },
                  ),
                ),
              ),
            ),

            // ─── Filter row ────────────────────────────────────────
            SliverToBoxAdapter(
              child: _FilterRow(
                categoriesAsync: categoriesAsync,
                productsAsync: productsAsync,
              ),
            ),

            // ─── Product grid / loading / error ───────────────────
            productsAsync.when(
              loading: () => const ProductGridShimmer(),
              error: (e, _) => SliverFillRemaining(
                child: AppErrorWidget(
                  message: e.toString(),
                  onRetry: () =>
                      ref.read(productsNotifierProvider.notifier).refresh(),
                ),
              ),
              data: (state) {
                if (state.products.isEmpty) {
                  return const SliverFillRemaining(
                    child: _EmptyView(),
                  );
                }
                return _ProductGrid(
                  products: state.products,
                  isLoadingMore: state.isLoadingMore,
                );
              },
            ),

            // Bottom safe area
            const SliverPadding(
              padding: EdgeInsets.only(bottom: AppDimensions.spacingXl),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Search bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search products…',
        prefixIcon: const Icon(Icons.search, size: AppDimensions.iconMd),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (_, value, __) => value.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: AppDimensions.iconMd),
                  onPressed: onClear,
                )
              : const SizedBox.shrink(),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: AppDimensions.spacingSm),
        isDense: true,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

// ─── Filter row ───────────────────────────────────────────────────────────────

class _FilterRow extends ConsumerWidget {
  final AsyncValue<List<ProductCategory>> categoriesAsync;
  final AsyncValue<ProductsState> productsAsync;

  const _FilterRow({
    required this.categoriesAsync,
    required this.productsAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCategoryId =
        productsAsync.valueOrNull?.categoryId;
    final activeSort = productsAsync.valueOrNull?.sort;

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.screenPaddingH,
          vertical: AppDimensions.spacingXs,
        ),
        children: [
          // Sort button
          _SortChip(
            activeSort: activeSort,
            onSelected: (sort) =>
                ref.read(productsNotifierProvider.notifier).applySort(sort),
          ),
          const SizedBox(width: AppDimensions.spacingSm),
          // "All" category chip
          _CategoryChip(
            label: 'All',
            isSelected: activeCategoryId == null,
            onTap: () => ref
                .read(productsNotifierProvider.notifier)
                .applyCategory(null),
          ),
          // Per-category chips
          ...categoriesAsync.whenOrNull(
                data: (cats) => cats.map(
                  (c) => Padding(
                    padding:
                        const EdgeInsets.only(left: AppDimensions.spacingSm),
                    child: _CategoryChip(
                      label: c.name,
                      isSelected: activeCategoryId == c.id,
                      onTap: () => ref
                          .read(productsNotifierProvider.notifier)
                          .applyCategory(c.id),
                    ),
                  ),
                ),
              ) ??
              [],
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMd,
          vertical: AppDimensions.spacingXs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String? activeSort;
  final ValueChanged<String?> onSelected;

  const _SortChip({this.activeSort, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final isActive = activeSort != null;
    return PopupMenuButton<String?>(
      onSelected: onSelected,
      itemBuilder: (_) => [
        const PopupMenuItem<String?>(
          child: Text('Default (Newest)'),
        ),
        ..._sortOptions.map(
          (o) => PopupMenuItem(value: o.$1, child: Text(o.$2)),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingSm,
          vertical: AppDimensions.spacingXs,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(
            color: isActive
                ? AppColors.primary
                : Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sort,
              size: 16,
              color: isActive
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              'Sort',
              style: TextStyle(
                fontSize: 12,
                color: isActive
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Product grid ─────────────────────────────────────────────────────────────

class _ProductGrid extends StatelessWidget {
  final List<Product> products;
  final bool isLoadingMore;

  const _ProductGrid({required this.products, required this.isLoadingMore});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingH,
        vertical: AppDimensions.spacingMd,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            // Load-more footer
            if (index == _rowCount(products.length)) {
              return isLoadingMore
                  ? const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: AppDimensions.spacingLg),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : const SizedBox.shrink();
            }

            // Two products per row
            final left = index * 2;
            final right = left + 1;
            return Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.spacingMd),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ProductCard(
                      product: products[left],
                      onTap: () => context.push(
                          AppRoutes.productDetailPath(products[left].id),),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingMd),
                  Expanded(
                    child: right < products.length
                        ? ProductCard(
                            product: products[right],
                            onTap: () => context.push(
                                AppRoutes.productDetailPath(products[right].id),),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            );
          },
          childCount: _rowCount(products.length) + 1, // +1 for footer
        ),
      ),
    );
  }

  int _rowCount(int count) => (count / 2).ceil();
}

// ─── Empty view ───────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              'No products found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            Text(
              'Try adjusting your search or filters',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:
                        Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
}
