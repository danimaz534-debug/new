import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/providers/app_state_provider.dart';
import 'order_details_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

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
    final mutedText = scheme.onSurface.withValues(alpha: 0.55);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          appState.text(en: 'Acquisitions', ar: 'الاقتناءات'),
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
      body: appState.orders.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: scheme.onSurface.withValues(alpha: 0.08),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    appState.text(
                      en: 'No acquisitions yet',
                      ar: 'لا توجد اقتناءات حتى الآن',
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
                      en: 'Your luxury items will appear here.',
                      ar: 'ستظهر قطعك الفاخرة هنا.',
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
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                itemCount: appState.orders.length,
                itemBuilder: (context, index) {
                  final order = appState.orders[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderColor),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OrderDetailsScreen(order: order),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  appState.text(
                                    en: 'Order #${order.id.substring(0, 8).toUpperCase()}',
                                    ar: 'الطلب #${order.id.substring(0, 8).toUpperCase()}',
                                  ),
                                  style: TextStyle(
                                    color: scheme.onSurface,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                _buildStatusBadge(order.status),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              DateFormat(
                                'MMMM dd, yyyy',
                              ).format(order.createdAt ?? DateTime.now()),
                              style: TextStyle(color: mutedText, fontSize: 14),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Divider(color: borderColor),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  appState.text(
                                    en: 'Total Value',
                                    ar: 'القيمة الإجمالية',
                                  ),
                                  style: TextStyle(
                                    color: mutedText,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '\$${order.totalAmount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: scheme.primary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'preparing':
        color = Colors.orangeAccent;
        break;
      case 'shipped':
        color = Colors.blueAccent;
        break;
      case 'on the way':
        color = Colors.purpleAccent;
        break;
      case 'delivered':
        color = Colors.greenAccent;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
