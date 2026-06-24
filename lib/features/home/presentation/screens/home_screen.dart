import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/utils/formatters.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/providers/products_provider.dart';
import '../../../products/presentation/widgets/product_card.dart';
import '../../../wallet/presentation/providers/wallet_provider.dart';
import '../providers/home_products_provider.dart';

// ─── Cloudinary hero image URLs ───────────────────────────────────────────────
const _cdnBase =
    'https://res.cloudinary.com/dxi9khzro/image/upload/f_auto,q_auto,w_800/';

String _heroUrl(String name, bool isDark) =>
    '$_cdnBase$name-${isDark ? 'dark' : 'light'}.png';

// ─── Screen ──────────────────────────────────────────────────────────────────

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeModeProvider);
    final brightness = MediaQuery.platformBrightnessOf(context);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);

    return Scaffold(
      backgroundColor: context.bg,
      body: RefreshIndicator(
        color: AppColors.figmaGreen,
        onRefresh: () async {
          ref.invalidate(homeProductPoolProvider);
          ref.invalidate(walletNotifierProvider);
          ref.invalidate(categoriesProvider);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _HomeAppBar(user: user)),
            SliverToBoxAdapter(child: _SearchBar()),
            SliverToBoxAdapter(child: _HeroSlider(isDark: isDark)),
            SliverToBoxAdapter(child: _QuickAccess(ref: ref)),
            SliverToBoxAdapter(child: _FlashSales(ref: ref)),
            SliverToBoxAdapter(child: _TopCategories(ref: ref)),
            SliverToBoxAdapter(child: _FeaturedStores()),
            SliverToBoxAdapter(
                child: _ProductSection(
              title: '🔥 Trending',
              viewAllRoute: AppRoutes.products,
              providerValue: ref.watch(trendingProductsProvider),
            )),
            SliverToBoxAdapter(
                child: _ProductSection(
              title: '✨ New Arrivals',
              viewAllRoute: '${AppRoutes.products}?sort=newest',
              providerValue: ref.watch(newArrivalsProvider),
            )),
            SliverToBoxAdapter(
                child: _ProductSection(
              title: '🏆 Best Selling',
              viewAllRoute: AppRoutes.products,
              providerValue: ref.watch(bestSellingProvider),
            )),
            SliverToBoxAdapter(child: _RecommendedSection(ref: ref)),
            SliverToBoxAdapter(child: _SellBanner()),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppDimensions.spacingXxl),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── App Bar ─────────────────────────────────────────────────────────────────

class _HomeAppBar extends ConsumerWidget {
  final dynamic user;
  const _HomeAppBar({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartItemCountProvider);

    return Container(
      color: context.bg,
      padding: EdgeInsets.fromLTRB(16, MediaQuery.viewPaddingOf(context).top + 8, 16, 12),
      child: Row(
        children: [
          Image.asset(
            'assets/images/cometake.jpg',
            height: 34,
            fit: BoxFit.contain,
          ),
          const Spacer(),
          _IconBadge(
            icon: Icons.notifications_outlined,
            badgeColor: Colors.red,
            onTap: () => context.push(AppRoutes.notifications),
          ),
          const SizedBox(width: 8),
          _IconBadge(
            icon: Icons.shopping_cart_outlined,
            badge: cartCount > 0 ? '$cartCount' : null,
            badgeColor: AppColors.figmaGreen,
            onTap: () => context.go(AppRoutes.cart),
          ),
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final String? badge;
  final Color badgeColor;
  final VoidCallback onTap;

  const _IconBadge({
    required this.icon,
    required this.badgeColor,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Icon(icon, color: context.t3, size: 24),
          if (badge != null)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Search Bar ──────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: GestureDetector(
        onTap: () => context.go(AppRoutes.products),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: context.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.border),
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: context.t2, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Search products, vendors...',
                  style: TextStyle(color: context.t2, fontSize: 14),
                ),
              ),
              Icon(Icons.tune_rounded, color: context.t4, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Hero Slider ─────────────────────────────────────────────────────────────

class _HeroSlider extends StatefulWidget {
  final bool isDark;
  const _HeroSlider({required this.isDark});

  @override
  State<_HeroSlider> createState() => _HeroSliderState();
}

class _HeroSliderState extends State<_HeroSlider> {
  final _controller = PageController();
  int _current = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      final next = (_current + 1) % 2;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = [
      _SlideData(
        imageKey: 'tech',
        label: 'NEW ARRIVALS',
        title: 'Latest Tech.\nTop Deals.',
        subtitle: 'Discover the best gadgets\nat unbeatable prices.',
        route: AppRoutes.products,
        isDark: widget.isDark,
      ),
      _SlideData(
        imageKey: 'fashion',
        label: 'FASHION PICKS',
        title: 'Style Meets\nAffordability.',
        subtitle: 'Shop the latest trends\nfrom top vendors.',
        route: AppRoutes.products,
        isDark: widget.isDark,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            children: [
              PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _current = i),
                itemCount: slides.length,
                itemBuilder: (_, i) => _HeroSlide(data: slides[i]),
              ),
              // Prev button
              Positioned(
                left: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      _controller.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.chevron_left,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ),
              // Next button
              Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.chevron_right,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ),
              // Dot indicators
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(slides.length, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _current == i ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _current == i
                            ? AppColors.figmaGreen
                            : Colors.white38,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideData {
  final String imageKey;
  final String label;
  final String title;
  final String subtitle;
  final String route;
  final bool isDark;

  const _SlideData({
    required this.imageKey,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.isDark,
  });
}

class _HeroSlide extends StatelessWidget {
  final _SlideData data;
  const _HeroSlide({required this.data});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: _heroUrl(data.imageKey, data.isDark),
          fit: BoxFit.contain,

          errorWidget: (_, __, ___) => Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.figmaTeal, AppColors.figmaTealEnd],
              ),
            ),
          ),
        ),
        // Shop Now button only — images already have text baked in
        Positioned(
          left: 20,
          bottom: 28,
          child: GestureDetector(
            onTap: () => context.go(data.route),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.figmaGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Shop Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.chevron_right, color: Colors.white, size: 16),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}


// ─── Quick Access ─────────────────────────────────────────────────────────────

class _QuickAccess extends ConsumerWidget {
  final WidgetRef ref;
  const _QuickAccess({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(walletNotifierProvider);
    final walletLabel = walletAsync.when(
      data: (w) => Formatters.currencyCompact(w.balance),
      loading: () => '...',
      error: (_, __) => '₦0',
    );

    final items = [
      _QItem(
        icon: Icons.account_balance_wallet,
        label: 'Wallet',
        sub: walletLabel,
        start: AppColors.qGreenStart,
        end: AppColors.qGreenEnd,
        route: AppRoutes.wallet,
      ),
      _QItem(
        icon: Icons.smartphone,
        label: 'VTU',
        sub: 'Airtime & Data',
        start: AppColors.qBlueStart,
        end: AppColors.qBlueEnd,
        route: AppRoutes.vtu,
      ),
      _QItem(
        icon: Icons.chat_bubble_rounded,
        label: 'Chat',
        sub: 'Messages',
        start: AppColors.qPurpleStart,
        end: AppColors.qPurpleEnd,
        route: AppRoutes.chat,
      ),
      _QItem(
        icon: Icons.store,
        label: 'Own a Store',
        sub: 'Start selling',
        start: AppColors.qOrangeStart,
        end: AppColors.qOrangeEnd,
        route: AppRoutes.vendor,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Row(
        children: items
            .map((item) => Expanded(child: _QCard(item: item)))
            .expand((w) => [w, const SizedBox(width: 10)])
            .toList()
          ..removeLast(),
      ),
    );
  }
}

class _QItem {
  final IconData icon;
  final String label;
  final String sub;
  final Color start;
  final Color end;
  final String route;

  const _QItem({
    required this.icon,
    required this.label,
    required this.sub,
    required this.start,
    required this.end,
    required this.route,
  });
}

class _QCard extends StatelessWidget {
  final _QItem item;
  const _QCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(item.route),
      child: Column(
        children: [
          Container(
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [item.start, item.end],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(item.icon, color: Colors.white, size: 28),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            item.sub,
            style: TextStyle(color: context.t4, fontSize: 10),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Flash Sales ─────────────────────────────────────────────────────────────

class _FlashSales extends ConsumerStatefulWidget {
  final WidgetRef ref;
  const _FlashSales({required this.ref});

  @override
  ConsumerState<_FlashSales> createState() => _FlashSalesState();
}

class _FlashSalesState extends ConsumerState<_FlashSales> {
  late DateTime _target;
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // Count down to midnight of the current day
    _target = DateTime(now.year, now.month, now.day, 23, 59, 59);
    if (_target.isBefore(now)) {
      _target = _target.add(const Duration(days: 1));
    }
    _remaining = _target.difference(now);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final diff = _target.difference(DateTime.now());
      setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _pad(int v) => v.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(trendingProductsProvider);

    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (products) {
        if (products.isEmpty) return const SizedBox.shrink();
        final items = products.take(6).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: Row(
                children: [
                  const Icon(Icons.bolt, color: Color(0xFFFACC15), size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'Flash Sales',
                    style: TextStyle(
                      color: context.t1,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.products),
                    child: const Row(
                      children: [
                        Text('View All',
                            style: TextStyle(
                                color: AppColors.figmaGreen,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                        Icon(Icons.chevron_right,
                            color: AppColors.figmaGreen, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Live countdown to midnight
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  _CountdownBox(_pad(_remaining.inHours)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text(':',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                  _CountdownBox(_pad(_remaining.inMinutes.remainder(60))),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text(':',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                  _CountdownBox(_pad(_remaining.inSeconds.remainder(60))),
                  const SizedBox(width: 8),
                  Text(
                    'hrs  mins  secs',
                    style: TextStyle(color: context.t2, fontSize: 11),
                  ),
                ],
              ),
            ),
            // Horizontal product scroll
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) => _FlashSaleCard(
                  product: items[i],
                  onTap: () =>
                      context.go(AppRoutes.productDetailPath(items[i].id)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

class _CountdownBox extends StatelessWidget {
  final String value;
  const _CountdownBox(this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.shade700,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FlashSaleCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  const _FlashSaleCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(11)),
                  child: SizedBox(
                    height: 130,
                    width: double.infinity,
                    child: product.thumbnailUrl != null
                        ? CachedNetworkImage(
                            imageUrl: product.thumbnailUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) =>
                                const _PlaceholderImage(),
                          )
                        : const _PlaceholderImage(),
                  ),
                ),
                if (product.hasDiscount)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '-${product.discountPercent}%',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(color: context.t3, fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Formatters.currency(product.price),
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (product.hasDiscount)
                    Text(
                      Formatters.currency(product.comparePrice!),
                      style: TextStyle(
                        color: context.t4,
                        fontSize: 11,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  const _PlaceholderImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.bg,
      child: Center(
        child: Icon(Icons.image_outlined, color: context.border, size: 36),
      ),
    );
  }
}

// ─── Top Categories ───────────────────────────────────────────────────────────

class _TopCategories extends ConsumerWidget {
  final WidgetRef ref;
  const _TopCategories({required this.ref});

  static const _catColors = {
    'phone': [Color(0xFF3B82F6), Color(0xFF0891B2)],
    'mobile': [Color(0xFF3B82F6), Color(0xFF0891B2)],
    'gadget': [Color(0xFF3B82F6), Color(0xFF6366F1)],
    'electronic': [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    'laptop': [Color(0xFF8B5CF6), Color(0xFF6366F1)],
    'computer': [Color(0xFF6366F1), Color(0xFF4F46E5)],
    'tv': [Color(0xFF06B6D4), Color(0xFF3B82F6)],
    'television': [Color(0xFF06B6D4), Color(0xFF3B82F6)],
    'fashion': [Color(0xFFEC4899), Color(0xFFF43F5E)],
    'cloth': [Color(0xFFEC4899), Color(0xFFF43F5E)],
    'wear': [Color(0xFFEC4899), Color(0xFFF43F5E)],
    'shoe': [Color(0xFFF97316), Color(0xFFEC4899)],
    'bag': [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    'watch': [Color(0xFF0891B2), Color(0xFF3B82F6)],
    'jewel': [Color(0xFFEAB308), Color(0xFFF97316)],
    'appliance': [Color(0xFF06B6D4), Color(0xFF3B82F6)],
    'kitchen': [Color(0xFFF97316), Color(0xFFD97706)],
    'home': [Color(0xFFF97316), Color(0xFFD97706)],
    'furniture': [Color(0xFF22C55E), Color(0xFF059669)],
    'office': [Color(0xFF6366F1), Color(0xFF4F46E5)],
    'car': [Color(0xFFEF4444), Color(0xFFF97316)],
    'vehicle': [Color(0xFFEF4444), Color(0xFFF97316)],
    'motor': [Color(0xFFEF4444), Color(0xFFF97316)],
    'bike': [Color(0xFF22C55E), Color(0xFF0891B2)],
    'real estate': [Color(0xFF6366F1), Color(0xFF4F46E5)],
    'property': [Color(0xFF6366F1), Color(0xFF4F46E5)],
    'beauty': [Color(0xFFEC4899), Color(0xFF9333EA)],
    'health': [Color(0xFF22C55E), Color(0xFF059669)],
    'medical': [Color(0xFF22C55E), Color(0xFF06B6D4)],
    'food': [Color(0xFFF97316), Color(0xFFEAB308)],
    'drink': [Color(0xFF06B6D4), Color(0xFF3B82F6)],
    'sport': [Color(0xFF22C55E), Color(0xFF16A34A)],
    'fitness': [Color(0xFF22C55E), Color(0xFF16A34A)],
    'game': [Color(0xFF8B5CF6), Color(0xFF6366F1)],
    'toy': [Color(0xFFF97316), Color(0xFFEAB308)],
    'baby': [Color(0xFF06B6D4), Color(0xFF8B5CF6)],
    'book': [Color(0xFF6366F1), Color(0xFF4F46E5)],
    'art': [Color(0xFFEC4899), Color(0xFF8B5CF6)],
    'music': [Color(0xFF8B5CF6), Color(0xFF6366F1)],
    'pet': [Color(0xFFF97316), Color(0xFF22C55E)],
    'travel': [Color(0xFF06B6D4), Color(0xFF3B82F6)],
    'garden': [Color(0xFF22C55E), Color(0xFF059669)],
  };

  static const _catEmojis = {
    'phone': '📱',
    'mobile': '📱',
    'gadget': '🔌',
    'electronic': '💻',
    'laptop': '💻',
    'computer': '🖥️',
    'tv': '📺',
    'television': '📺',
    'fashion': '👗',
    'cloth': '👗',
    'wear': '👕',
    'shoe': '👟',
    'bag': '👜',
    'watch': '⌚',
    'jewel': '💎',
    'appliance': '🔌',
    'kitchen': '🍳',
    'home': '🏠',
    'furniture': '🪑',
    'office': '🖊️',
    'car': '🚗',
    'vehicle': '🚙',
    'motor': '🏍️',
    'bike': '🚲',
    'real estate': '🏢',
    'property': '🏘️',
    'beauty': '💄',
    'health': '💊',
    'medical': '🏥',
    'food': '🍔',
    'drink': '🥤',
    'sport': '⚽',
    'fitness': '🏋️',
    'game': '🎮',
    'toy': '🧸',
    'baby': '👶',
    'book': '📚',
    'art': '🎨',
    'music': '🎵',
    'pet': '🐾',
    'travel': '✈️',
    'garden': '🌱',
  };

  List<Color> _colorsFor(String name) {
    final lower = name.toLowerCase();
    for (final entry in _catColors.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return [const Color(0xFF4B5563), const Color(0xFF374151)];
  }

  String _emojiFor(String name) {
    final lower = name.toLowerCase();
    for (final entry in _catEmojis.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return '🛍️';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(categoriesProvider);

    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (cats) {
        if (cats.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Text(
                    'Top Categories',
                    style: TextStyle(
                      color: context.t1,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.products),
                    child: const Row(
                      children: [
                        Text('See All',
                            style: TextStyle(
                                color: AppColors.figmaGreen,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                        Icon(Icons.chevron_right,
                            color: AppColors.figmaGreen, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  childAspectRatio: 0.75,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 8,
                ),
                itemCount: cats.length > 10 ? 10 : cats.length,
                itemBuilder: (_, i) {
                  final cat = cats[i];
                  final colors = _colorsFor(cat.name);
                  final emoji = _emojiFor(cat.name);

                  return GestureDetector(
                    onTap: () => context.go(
                      '${AppRoutes.products}?category=${cat.id}',
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: colors,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          cat.name,
                          style: TextStyle(
                              color: context.t3, fontSize: 10),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

// ─── Featured Stores ──────────────────────────────────────────────────────────

class _FeaturedStores extends StatelessWidget {
  static const _stores = [
    _StoreData('TechHub Electronics', 'Electronics', 4.8, 'Top Rated',
        [Color(0xFF3B82F6), Color(0xFF0891B2)]),
    _StoreData('Fashion Forward NG', 'Fashion', 4.7, 'Verified',
        [Color(0xFFEC4899), Color(0xFF9333EA)]),
    _StoreData('HomeStyle Living', 'Home & Living', 4.6, 'Verified',
        [Color(0xFFF97316), Color(0xFFD97706)]),
    _StoreData('Gadget World', 'Electronics', 4.9, 'Top Rated',
        [Color(0xFF22C55E), Color(0xFF059669)]),
    _StoreData('Beauty Essentials', 'Beauty', 4.5, 'Verified',
        [Color(0xFFEC4899), Color(0xFFF43F5E)]),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Text(
                'Featured Stores',
                style: TextStyle(
                  color: context.t1,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              const Text(
                'See All',
                style: TextStyle(
                    color: AppColors.figmaGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
              const Icon(Icons.chevron_right,
                  color: AppColors.figmaGreen, size: 16),
            ],
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _stores.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _StoreCard(store: _stores[i]),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _StoreData {
  final String name;
  final String category;
  final double rating;
  final String badge;
  final List<Color> gradient;

  const _StoreData(
      this.name, this.category, this.rating, this.badge, this.gradient);
}

class _StoreCard extends StatelessWidget {
  final _StoreData store;
  const _StoreCard({required this.store});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: store.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    store.name[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: store.badge == 'Top Rated'
                      ? Colors.amber.withOpacity(0.2)
                      : AppColors.figmaGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  store.badge,
                  style: TextStyle(
                    color: store.badge == 'Top Rated'
                        ? Colors.amber
                        : AppColors.figmaGreen,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            store.name,
            style: TextStyle(
              color: context.t1,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            store.category,
            style: TextStyle(color: context.t2, fontSize: 11),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 13),
              const SizedBox(width: 3),
              Text(
                store.rating.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Generic 2-column Product Section ────────────────────────────────────────

class _ProductSection extends StatelessWidget {
  final String title;
  final String viewAllRoute;
  final AsyncValue<List<Product>> providerValue;

  const _ProductSection({
    required this.title,
    required this.viewAllRoute,
    required this.providerValue,
  });

  @override
  Widget build(BuildContext context) {
    return providerValue.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (products) {
        if (products.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: context.t1,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.go(viewAllRoute),
                    child: const Row(
                      children: [
                        Text('View All',
                            style: TextStyle(
                                color: AppColors.figmaGreen,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                        Icon(Icons.chevron_right,
                            color: AppColors.figmaGreen, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.58,
                ),
                itemCount: products.length,
                itemBuilder: (_, i) => ProductCard(
                  product: products[i],
                  onTap: () =>
                      context.go(AppRoutes.productDetailPath(products[i].id)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

// ─── Recommended (horizontal scroll) ─────────────────────────────────────────

class _RecommendedSection extends ConsumerWidget {
  final WidgetRef ref;
  const _RecommendedSection({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(recommendedProvider);

    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (products) {
        if (products.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Text(
                    '⭐ Recommended For You',
                    style: TextStyle(
                      color: context.t1,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.products),
                    child: const Row(
                      children: [
                        Text('See All',
                            style: TextStyle(
                                color: AppColors.figmaGreen,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                        Icon(Icons.chevron_right,
                            color: AppColors.figmaGreen, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 260,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) => SizedBox(
                  width: 160,
                  child: ProductCard(
                    product: products[i],
                    onTap: () =>
                        context.go(AppRoutes.productDetailPath(products[i].id)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

// ─── Sell Banner ─────────────────────────────────────────────────────────────

class _SellBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.figmaTeal, AppColors.figmaTealEnd],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sell on Cometake',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Grow your business\nreaching millions',
                    style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.vendor),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.figmaGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Start Selling',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.chevron_right,
                              color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Text('💼', style: TextStyle(fontSize: 52)),
          ],
        ),
      ),
    );
  }
}
