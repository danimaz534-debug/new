import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/app_state_provider.dart';
import '../../models/product.dart';
import '../../widgets/feedback.dart';
import '../../widgets/product_card.dart';
import '../../widgets/section_title.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({
    super.key,
    required this.onProductSelected,
    required this.onRequireAuth,
  });

  final ValueChanged<Product> onProductSelected;
  final VoidCallback onRequireAuth;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final maxPrice = appState.maxCatalogPrice == 0
        ? 1.0
        : appState.maxCatalogPrice;
    final priceCap = appState.priceCap ?? maxPrice;
    final sectionSurface = isDark ? const Color(0xFF171717) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : scheme.outlineVariant.withValues(alpha: 0.35);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.92),
        elevation: 0,
        centerTitle: true,
        title: Text(
          appState.text(en: 'The Gallery', ar: 'المعرض'),
          style: TextStyle(
            color: scheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: borderColor)),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: appState.refreshAll,
        color: scheme.primary,
        backgroundColor: sectionSurface,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            SectionTitle(
              title: appState.text(en: 'Collections', ar: 'المجموعات'),
              subtitle: appState.text(
                en: 'Discover our curated selection of premium technology.',
                ar: 'اكتشف مجموعتنا المختارة من التكنولوجيا الفاخرة.',
              ),
            ),
            const SizedBox(height: 24),

            // Premium Search Bar
            Container(
              decoration: BoxDecoration(
                color: sectionSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                onChanged: appState.setSearchQuery,
                style: TextStyle(color: scheme.onSurface),
                cursorColor: scheme.primary,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded, color: scheme.primary),
                  hintText: appState.text(
                    en: 'Search products or brands...',
                    ar: 'ابحث عن المنتجات أو العلامات التجارية...',
                  ),
                  hintStyle: TextStyle(
                    color: scheme.onSurface.withValues(alpha: 0.45),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Category Selection
            Text(
              appState.text(en: 'Category', ar: 'الفئة'),
              style: TextStyle(
                color: scheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: ['All', 'Phones', 'Accessories', 'Audio', 'Wearables']
                    .map(
                      (category) => Padding(
                        padding: const EdgeInsetsDirectional.only(end: 10),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: appState.selectedCategory == category,
                          onSelected: (_) =>
                              appState.setSelectedCategory(category),
                          selectedColor: scheme.primary,
                          backgroundColor: sectionSurface,
                          labelStyle: TextStyle(
                            color: appState.selectedCategory == category
                                ? scheme.onPrimary
                                : scheme.onSurface.withValues(alpha: 0.72),
                            fontWeight: appState.selectedCategory == category
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: appState.selectedCategory == category
                                  ? scheme.primary
                                  : borderColor,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

            const SizedBox(height: 24),

            // Filters & Sorting Card
            Container(
              decoration: BoxDecoration(
                color: sectionSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          appState.text(en: 'Price Filter', ar: 'تصفية السعر'),
                          style: TextStyle(
                            color: scheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${priceCap.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: scheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: scheme.primary,
                        inactiveTrackColor: scheme.outlineVariant.withValues(
                          alpha: 0.35,
                        ),
                        thumbColor: scheme.primary,
                        overlayColor: scheme.primary.withValues(alpha: 0.2),
                        trackHeight: 2,
                      ),
                      child: Slider(
                        value: priceCap.clamp(1, maxPrice),
                        min: 1,
                        max: maxPrice,
                        onChanged: (value) => appState.setPriceCap(value),
                      ),
                    ),
                    Divider(color: borderColor, height: 32),
                    Row(
                      children: [
                        Icon(
                          Icons.sort_rounded,
                          color: scheme.onSurface.withValues(alpha: 0.55),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<CatalogSort>(
                              value: appState.sort,
                              dropdownColor: sectionSurface,
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: scheme.primary,
                              ),
                              isExpanded: true,
                              items: [
                                DropdownMenuItem(
                                  value: CatalogSort.recommended,
                                  child: Text(
                                    appState.text(
                                      en: 'Recommended',
                                      ar: 'مقترح',
                                    ),
                                    style: TextStyle(
                                      color: scheme.onSurface,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: CatalogSort.priceLowHigh,
                                  child: Text(
                                    appState.text(
                                      en: 'Price: Low to High',
                                      ar: 'السعر: من الأقل للأعلى',
                                    ),
                                    style: TextStyle(
                                      color: scheme.onSurface,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: CatalogSort.priceHighLow,
                                  child: Text(
                                    appState.text(
                                      en: 'Price: High to Low',
                                      ar: 'السعر: من الأعلى للأقل',
                                    ),
                                    style: TextStyle(
                                      color: scheme.onSurface,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) appState.setSort(value);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Results Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 1000
                    ? 3
                    : constraints.maxWidth > 620
                    ? 2
                    : 1;
                final products = appState.visibleProducts;

                if (products.isEmpty) {
                  return Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: sectionSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            color: scheme.onSurface.withValues(alpha: 0.2),
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            appState.text(
                              en: 'No items found',
                              ar: 'لم يتم العثور على نتائج',
                            ),
                            style: TextStyle(
                              color: scheme.onSurface.withValues(alpha: 0.55),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 24,
                    mainAxisExtent: 400,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(
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
                            en: 'Product added to cart.',
                            ar: 'تمت إضافة المنتج إلى السلة.',
                          ),
                        );
                      },
                      isWholesale: appState.isWholesale,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
