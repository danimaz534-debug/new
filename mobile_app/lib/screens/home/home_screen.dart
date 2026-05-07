import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:mobile_app/core/providers/app_state_provider.dart';
import 'package:mobile_app/models/product.dart';
import 'package:mobile_app/widgets/product_card.dart';
import 'package:mobile_app/widgets/feedback.dart';
import 'package:mobile_app/widgets/network_product_image.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onProductSelected,
    required this.onExploreCatalog,
    required this.onRequireAuth,
    required this.onOpenChat,
    required this.onOpenProfile,
    required this.onOpenNotifications,
  });

  final ValueChanged<Product> onProductSelected;
  final VoidCallback onExploreCatalog;
  final VoidCallback onRequireAuth;
  final VoidCallback onOpenChat;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenNotifications;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF111111) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : scheme.outlineVariant.withValues(alpha: 0.35);
    final heroProducts =
        [
              ...appState.featuredProducts,
              ...appState.bestSellerProducts,
              ...appState.hotDeals,
            ]
            .fold<List<Product>>(<Product>[], (items, product) {
              if (items.any((entry) => entry.id == product.id)) {
                return items;
              }
              items.add(product);
              return items;
            })
            .take(5)
            .toList(growable: false);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.82),
        elevation: 0,
        centerTitle: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: borderColor)),
          ),
        ),
        title: Text(
          appState.text(en: 'Obsidian & Ivory', ar: 'الأوبسيديان والعاج'),
          style: TextStyle(
            color: scheme.onSurface,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: appState.isGuest ? onRequireAuth : onOpenChat,
                icon: Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: scheme.primary,
                ),
              ),
              if (appState.unreadChatCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${appState.unreadChatCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            onPressed: onOpenNotifications,
            icon: Icon(Icons.notifications_none_rounded, color: scheme.primary),
          ),
          IconButton(
            onPressed: onOpenProfile,
            tooltip: appState.text(en: 'Profile', ar: 'الملف الشخصي'),
            icon: CircleAvatar(
              radius: 14,
              backgroundColor: scheme.surfaceContainerHighest,
              backgroundImage: appState.currentUser?.avatarUrl != null
                  ? NetworkImage(appState.currentUser!.avatarUrl!)
                  : null,
              child: appState.currentUser?.avatarUrl == null
                  ? Icon(Icons.person_rounded, size: 16, color: scheme.primary)
                  : null,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: appState.refreshAll,
        color: scheme.primary,
        backgroundColor: surface,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 100, 20, 120),
          children: [
            Container(
              height: 420,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: LinearGradient(
                  colors: isDark
                      ? const [Color(0xFF1A1A1A), Color(0xFF0A0A0A)]
                      : [Colors.white, const Color(0xFFF4E9C7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: heroProducts.isNotEmpty
                  ? _HeroShowcaseSlider(
                      products: heroProducts,
                      onProductSelected: onProductSelected,
                    )
                  : _HeroEmptyState(
                      title: appState.text(
                        en: 'Products are loading',
                        ar: 'جارٍ تحميل المنتجات',
                      ),
                    ),
            ),

            const SizedBox(height: 48),

            _buildSectionHeader(
              context,
              appState,
              title: appState.text(en: 'Trending Now', ar: 'الأكثر رواجاً'),
              subtitle: appState.text(
                en: 'Curated selection of our best-sellers.',
                ar: 'مجموعة مختارة من أكثر منتجاتنا مبيعاً.',
              ),
            ),
            const SizedBox(height: 24),
            _ProductCarousel(
              products: appState.bestSellerProducts,
              onProductSelected: onProductSelected,
              onExploreCatalog: onExploreCatalog,
              onRequireAuth: onRequireAuth,
            ),

            const SizedBox(height: 48),

            _buildSectionHeader(
              context,
              appState,
              title: appState.text(en: 'Exclusive Offers', ar: 'عروض حصرية'),
              subtitle: appState.text(
                en: 'Premium value on selected masterpieces.',
                ar: 'قيمة مميزة على قطع مختارة.',
              ),
            ),
            const SizedBox(height: 24),
            _ProductCarousel(
              products: appState.hotDeals.take(8).toList(),
              onProductSelected: onProductSelected,
              onExploreCatalog: onExploreCatalog,
              onRequireAuth: onRequireAuth,
            ),

            const SizedBox(height: 48),

            _buildSectionHeader(
              context,
              appState,
              title: appState.text(en: 'Newly Arrived', ar: 'وصل حديثاً'),
              subtitle: appState.text(
                en: 'The latest additions to the collection.',
                ar: 'أحدث الإضافات إلى المجموعة.',
              ),
            ),
            const SizedBox(height: 24),
            _ProductCarousel(
              products: appState.featuredProducts,
              onProductSelected: onProductSelected,
              onExploreCatalog: onExploreCatalog,
              onRequireAuth: onRequireAuth,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    AppStateProvider appState, {
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mutedText =
        theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.65) ??
        scheme.onSurface.withValues(alpha: 0.65);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: onExploreCatalog,
              child: Text(
                appState.text(en: 'See All', ar: 'عرض الكل'),
                style: TextStyle(
                  color: scheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Text(subtitle, style: TextStyle(color: mutedText, fontSize: 14)),
      ],
    );
  }
}

class _HeroShowcaseSlider extends StatefulWidget {
  const _HeroShowcaseSlider({
    required this.products,
    required this.onProductSelected,
  });

  final List<Product> products;
  final ValueChanged<Product> onProductSelected;

  @override
  State<_HeroShowcaseSlider> createState() => _HeroShowcaseSliderState();
}

class _HeroShowcaseSliderState extends State<_HeroShowcaseSlider> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1);
    if (widget.products.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (_) {
        if (!mounted) return;
        final nextIndex = (_currentIndex + 1) % widget.products.length;
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: widget.products.length,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            final product = widget.products[index];
            return GestureDetector(
              onTap: () => widget.onProductSelected(product),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  NetworkProductImage(
                    imageUrl: product.imageUrl,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.1),
                          Colors.black.withValues(alpha: 0.52),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 22, 22, 26),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            product.category.toUpperCase(),
                            style: TextStyle(
                              color: scheme.onPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '\$${product.discountedPrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: scheme.primary,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        if (widget.products.length > 1)
          Positioned(
            top: 18,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.products.length, (index) {
                final active = index == _currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: active ? 28 : 8,
                  decoration: BoxDecoration(
                    color: active
                        ? scheme.primary
                        : Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

class _HeroEmptyState extends StatelessWidget {
  const _HeroEmptyState({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 52,
            color: scheme.onSurface.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: scheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCarousel extends StatelessWidget {
  const _ProductCarousel({
    required this.products,
    required this.onProductSelected,
    required this.onExploreCatalog,
    required this.onRequireAuth,
  });

  final List<Product> products;
  final ValueChanged<Product> onProductSelected;
  final VoidCallback onExploreCatalog;
  final VoidCallback onRequireAuth;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (products.isEmpty) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : scheme.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 40,
              color: scheme.onSurface.withValues(alpha: 0.18),
            ),
            const SizedBox(height: 16),
            Text(
              appState.text(
                en: 'Collections coming soon',
                ar: 'المجموعات قريباً',
              ),
              style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.55)),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 420,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 20),
        itemBuilder: (context, index) {
          final product = products[index];
          return SizedBox(
            width: 280,
            child: ProductCard(
              product: product,
              isFavorite: appState.favoriteIds.contains(product.id),
              isAdmin: appState.isAdmin,
              favoriteCount: appState.favoriteCounts[product.id] ?? 0,
              onTap: () => onProductSelected(product),
              onFavoriteToggle: () async {
                if (appState.isGuest) {
                  onRequireAuth();
                  return;
                }
                await appState.toggleFavorite(product);
              },
              onAddToCart: () async {
                if (appState.isGuest) {
                  onRequireAuth();
                  return;
                }
                await appState.addToCart(product);
                if (!context.mounted) return;
                showAppSnackBar(
                  context,
                  appState.text(
                    en: 'Added to cart.',
                    ar: 'تمت الإضافة إلى السلة.',
                  ),
                );
              },
              isWholesale: appState.isWholesale,
            ),
          );
        },
      ),
    );
  }
}
