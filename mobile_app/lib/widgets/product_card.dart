import 'package:flutter/material.dart';

import '../models/product.dart';
import 'network_product_image.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.onAddToCart,
    this.compact = false,
    this.isAdmin = false,
    this.favoriteCount = 0,
    this.isWholesale = false,
  });

  final Product product;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onAddToCart;
  final bool compact;
  final bool isAdmin;
  final int favoriteCount;
  final bool isWholesale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : scheme.outlineVariant.withValues(alpha: 0.28);
    final displayedPrice = product.discountedPrice;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final imageHeight = compact ? 120.0 : constraints.maxHeight * 0.55;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    NetworkProductImage(
                      imageUrl: product.imageUrl,
                      height: imageHeight,
                      borderRadius: BorderRadius.zero,
                    ),
                    if (product.discountPercent > 0 || product.isBestSeller)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (product.discountPercent > 0)
                              _pill(
                                context,
                                '-${product.discountPercent}%',
                                scheme.primary,
                                textColor: scheme.onPrimary,
                              ),
                            if (product.isBestSeller) ...[
                              const SizedBox(height: 4),
                              _pill(
                                context,
                                'BESTSELLER',
                                isDark
                                    ? Colors.white.withValues(alpha: 0.92)
                                    : const Color(0xFF151515),
                                textColor: isDark ? Colors.black : Colors.white,
                              ),
                            ],
                          ],
                        ),
                      ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: isAdmin
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: cardColor.withValues(alpha: 0.88),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: scheme.primary.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.favorite_rounded,
                                    color: scheme.primary,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$favoriteCount',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: scheme.primary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Material(
                              color: cardColor.withValues(alpha: 0.76),
                              borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                onTap: onFavoriteToggle,
                                borderRadius: BorderRadius.circular(14),
                                child: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: Icon(
                                    isFavorite
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    color: isFavorite
                                        ? scheme.primary
                                        : scheme.onSurface.withValues(
                                            alpha: 0.65,
                                          ),
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.category.toUpperCase(),
                          style: TextStyle(
                            color: scheme.primary.withValues(alpha: 0.88),
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                            color: scheme.onSurface,
                            fontSize: 15,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (product.discountPercent > 0)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 4),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: scheme.primary,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${product.discountPercent}% OFF',
                                        style: TextStyle(
                                          color: scheme.onPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  Text(
                                    '\$${displayedPrice.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: scheme.primary,
                                      fontSize: 18,
                                    ),
                                  ),
                                  if (product.discountPercent > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        '\$${product.price.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          color: scheme.onSurface.withValues(
                                            alpha: 0.42,
                                          ),
                                          decoration:
                                              TextDecoration.lineThrough,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )
                                  else if (isWholesale)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        'Wholesale discount at checkout',
                                        style: TextStyle(
                                          color: scheme.onSurface.withValues(
                                            alpha: 0.55,
                                          ),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: product.isOutOfStock
                                      ? null
                                      : onAddToCart,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    child: Icon(
                                      Icons.add_rounded,
                                      size: 22,
                                      color: scheme.onPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _pill(
    BuildContext context,
    String text,
    Color color, {
    Color textColor = Colors.white,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w900,
          fontSize: 9,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
