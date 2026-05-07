import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_state_provider.dart';
import '../../models/order_summary.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderSummary order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppStateProvider>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : scheme.outlineVariant.withValues(alpha: 0.28);
    final mutedText = scheme.onSurface.withValues(alpha: 0.55);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          appState.text(en: 'Acquisition Detail', ar: 'تفاصيل الاقتناء'),
          style: TextStyle(
            color: scheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: scheme.onSurface,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        order.status,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(
                          order.status,
                        ).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      order.status.toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(order.status),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Order #${order.id.substring(0, 12).toUpperCase()}',
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat(
                      'MMMM dd, yyyy • hh:mm a',
                    ).format(order.createdAt ?? DateTime.now()),
                    style: TextStyle(color: mutedText, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Items List
            Text(
              appState.text(en: 'Collection', ar: 'المجموعة'),
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = order.items[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: item.product?.imageUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(
                                    item.product!.imageUrl ?? '',
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          color: scheme.surfaceContainerHighest,
                        ),
                        child: item.product?.imageUrl == null
                            ? Icon(
                                Icons.inventory_2_outlined,
                                color: scheme.onSurface.withValues(alpha: 0.24),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product?.name ?? 'Premium Item',
                              style: TextStyle(
                                color: scheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Qty: ${item.quantity}',
                              style: TextStyle(color: mutedText, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$${(item.discountedUnitPrice * item.quantity).toStringAsFixed(0)}',
                        style: TextStyle(
                          color: scheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Summary
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
                      en: 'Investment Summary',
                      ar: 'ملخص الاستثمار',
                    ),
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _summaryRow(
                    context,
                    'Subtotal',
                    '\$${order.subtotal.toStringAsFixed(0)}',
                  ),
                  if (order.wholesaleDiscount > 0)
                    _summaryRow(
                      context,
                      'Wholesale Benefit',
                      '-\$${order.wholesaleDiscount.toStringAsFixed(0)}',
                      isHighlight: true,
                    ),
                  if (order.loyaltyDiscount > 0)
                    _summaryRow(
                      context,
                      'Loyalty Reward',
                      '-\$${order.loyaltyDiscount.toStringAsFixed(0)}',
                      isHighlight: true,
                    ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: borderColor),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Acquisition',
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${order.totalAmount.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: scheme.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Delivery
            Text(
              appState.text(en: 'Delivery Destination', ar: 'وجهة التسليم'),
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.shippingAddress['full_name'] ?? 'Recipient',
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${order.shippingAddress['address_line1']}\n${order.shippingAddress['city']}, ${order.shippingAddress['state']} ${order.shippingAddress['postal_code']}',
                    style: TextStyle(
                      color: mutedText,
                      height: 1.6,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(
    BuildContext context,
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: scheme.onSurface.withValues(alpha: 0.55),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isHighlight ? scheme.primary : scheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'preparing':
        return Colors.orangeAccent;
      case 'shipped':
        return Colors.blueAccent;
      case 'on the way':
        return Colors.purpleAccent;
      case 'delivered':
        return Colors.greenAccent;
      default:
        return Colors.grey;
    }
  }
}
