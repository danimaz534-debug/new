import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/app_state_provider.dart';
import '../../models/cart_entry.dart';
import '../../models/product.dart';
import '../../widgets/network_product_image.dart';
import '../../widgets/section_title.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({
    super.key,
    required this.onProductSelected,
    required this.onRequireAuth,
    required this.onCheckout,
  });

  final ValueChanged<Product> onProductSelected;
  final VoidCallback onRequireAuth;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : scheme.outlineVariant.withValues(alpha: 0.28);
    final mutedText =
        theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ??
        scheme.onSurface.withValues(alpha: 0.6);
    final shippingCost = appState.cartSubtotal >= 50 ? 0.0 : 9.99;
    final cartPreviewTotal = appState.cartSubtotal + shippingCost;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.92),
        elevation: 0,
        centerTitle: true,
        title: Text(
          appState.text(en: 'My Collection', ar: 'مجموعتي'),
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
      body: appState.cartEntries.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: scheme.onSurface.withValues(alpha: 0.08),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    appState.text(
                      en: 'Your collection is empty',
                      ar: 'مجموعتك فارغة',
                    ),
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    appState.text(
                      en: 'Discover masterpieces in the catalog.',
                      ar: 'اكتشف التحف الفنية في الكتالوج.',
                    ),
                    style: TextStyle(color: mutedText, fontSize: 14),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: appState.refreshAll,
              color: scheme.primary,
              backgroundColor: surface,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  SectionTitle(
                    title: appState.text(en: 'Items', ar: 'المنتجات'),
                    subtitle: appState.text(
                      en: 'Products reserved for your acquisition.',
                      ar: 'المنتجات المحجوزة لاقتنائك.',
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...appState.cartEntries.map(
                    (entry) => _CartItemTile(
                      entry: entry,
                      appState: appState,
                      onProductSelected: onProductSelected,
                      onUpdateQuantity: (quantity) => appState
                          .updateCartQuantity(entry.product.id, quantity),
                      onRemove: () => appState.removeFromCart(entry.product.id),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appState.text(
                            en: 'Acquisition Summary',
                            ar: 'ملخص الاقتناء',
                          ),
                          style: TextStyle(
                            color: scheme.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildSummaryRow(
                          context,
                          appState.text(en: 'Subtotal', ar: 'المجموع الفرعي'),
                          '\$${appState.cartSubtotal.toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: 12),
                        _buildSummaryRow(
                          context,
                          appState.text(en: 'Premium Shipping', ar: 'شحن فاخر'),
                          shippingCost == 0
                              ? appState.text(en: 'Complimentary', ar: 'مجاني')
                              : '\$${shippingCost.toStringAsFixed(2)}',
                          isGold: appState.cartSubtotal >= 50,
                        ),
                        if (appState.isWholesale) ...[
                          const SizedBox(height: 12),
                          _buildSummaryRow(
                            context,
                            appState.text(
                              en: 'Wholesale Discount',
                              ar: 'خصم الجملة',
                            ),
                            appState.text(
                              en: 'Shown at checkout',
                              ar: 'يظهر عند الدفع',
                            ),
                            isGold: true,
                          ),
                        ],
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Divider(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              appState.text(
                                en: 'Total Amount',
                                ar: 'المبلغ الإجمالي',
                              ),
                              style: TextStyle(
                                color: scheme.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\$${cartPreviewTotal.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: scheme.primary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: appState.cartEntries.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                border: Border(top: BorderSide(color: borderColor)),
              ),
              child: ElevatedButton(
                onPressed: onCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      appState.text(
                        en: 'Proceed to Acquisition',
                        ar: 'المتابعة للاقتناء',
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value, {
    bool isGold = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: scheme.onSurface.withValues(alpha: 0.6),
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isGold ? scheme.primary : scheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({
    required this.entry,
    required this.appState,
    required this.onProductSelected,
    required this.onUpdateQuantity,
    required this.onRemove,
  });

  final CartEntry entry;
  final AppStateProvider appState;
  final ValueChanged<Product> onProductSelected;
  final ValueChanged<int> onUpdateQuantity;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : scheme.outlineVariant.withValues(alpha: 0.28);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onProductSelected(entry.product),
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: NetworkProductImage(
                  imageUrl: entry.product.imageUrl,
                  borderRadius: BorderRadius.zero,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.product.name,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '\$${entry.product.discountedPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: scheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (entry.product.discountPercent > 0) ...[
                      const SizedBox(width: 8),
                      Text(
                        '\$${entry.product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: scheme.onSurface.withValues(alpha: 0.42),
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildQtyBtn(
                      context,
                      Icons.remove,
                      entry.quantity > 1
                          ? () => onUpdateQuantity(entry.quantity - 1)
                          : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '${entry.quantity}',
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildQtyBtn(
                      context,
                      Icons.add,
                      () => onUpdateQuantity(entry.quantity + 1),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: onRemove,
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(
    BuildContext context,
    IconData icon,
    VoidCallback? onTap,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: onTap == null
              ? scheme.onSurface.withValues(alpha: 0.24)
              : scheme.onSurface,
          size: 18,
        ),
      ),
    );
  }
}
