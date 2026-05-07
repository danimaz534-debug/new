import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/app_state_provider.dart';
import '../../models/shipping_address.dart';
import '../../models/user_address.dart';
import '../../widgets/feedback.dart';
import '../../widgets/section_title.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    super.key,
    required this.onOrderPlaced,
    required this.onRequireAuth,
  });

  final VoidCallback onOrderPlaced;
  final VoidCallback onRequireAuth;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPayment = 'Cash on Delivery';
  String? _selectedAddressId;
  bool _isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<AppStateProvider>();
      appState.loadUserAddresses();
    });
  }

  Future<void> _placeOrder() async {
    final appState = context.read<AppStateProvider>();

    if (appState.isGuest) {
      widget.onRequireAuth();
      return;
    }

    if (appState.cartEntries.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Your cart is empty')));
      return;
    }

    UserAddress? selectedAddress;
    if (_selectedAddressId != null) {
      selectedAddress = appState.userAddresses
          .where((a) => a.id == _selectedAddressId)
          .firstOrNull;
    } else {
      selectedAddress = appState.defaultAddress;
    }

    if (selectedAddress == null) {
      showAppSnackBar(
        context,
        appState.text(
          en: 'Please add and select a shipping address before placing the order.',
          ar: 'يرجى إضافة عنوان شحن واختياره قبل تأكيد الطلب.',
        ),
        isError: true,
      );
      _showAddAddressModal(context, appState);
      return;
    }

    final address = ShippingAddress(
      fullName: selectedAddress.fullName,
      phone: selectedAddress.phone,
      city: selectedAddress.city,
      street: selectedAddress.street,
      building: selectedAddress.building,
      notes: selectedAddress.notes ?? '',
    );

    setState(() => _isPlacingOrder = true);
    try {
      await appState.checkout(
        paymentMethod: _selectedPayment,
        shippingAddress: address,
      );
      if (mounted) {
        widget.onOrderPlaced();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isPlacingOrder = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final theme = Theme.of(context);

    if (appState.cartEntries.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(appState.text(en: 'Checkout', ar: 'الدفع')),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.shopping_cart_outlined,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                appState.text(en: 'Your cart is empty', ar: 'سلة التسوق فارغة'),
                style: theme.textTheme.headlineSmall,
              ),
            ],
          ),
        ),
      );
    }

    final addresses = appState.userAddresses;
    final defaultAddr = appState.defaultAddress;
    if (_selectedAddressId == null && defaultAddr != null) {
      _selectedAddressId = defaultAddr.id;
    }

    final shippingCost = appState.cartSubtotal >= 50 ? 0.0 : 9.99;
    final total =
        appState.cartSubtotal +
        shippingCost -
        appState.estimatedWholesaleDiscount;

    return Scaffold(
      appBar: AppBar(
        title: Text(appState.text(en: 'Checkout', ar: 'الدفع')),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                children: [
                  SectionTitle(
                    title: appState.text(en: 'Order Items', ar: 'المنتجات'),
                    subtitle: appState.text(
                      en: '${appState.cartCount} items',
                      ar: '${appState.cartCount} عنصر',
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...appState.cartEntries.map(
                    (entry) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.product.name,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${entry.product.discountedPrice.toStringAsFixed(2)} × ${entry.quantity}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SectionTitle(
                    title: appState.text(
                      en: 'Shipping Address',
                      ar: 'عناوين الشحن',
                    ),
                    subtitle: '',
                  ),
                  const SizedBox(height: 12),
                  if (addresses.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              appState.text(
                                en: 'No saved addresses. Please add an address.',
                                ar: 'لا توجد عناوين محفوظة. يرجى إضافة عنوان.',
                              ),
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () {
                                _showAddAddressModal(context, appState);
                              },
                              icon: const Icon(Icons.add, size: 18),
                              label: Text(
                                appState.text(
                                  en: 'Add Address',
                                  ar: 'إضافة عنوان',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    ...addresses.map(
                      (addr) => RadioListTile<String>(
                        value: addr.id,
                        groupValue: _selectedAddressId,
                        title: Text(addr.fullName),
                        subtitle: Text('${addr.city}, ${addr.street}'),
                        onChanged: (v) =>
                            setState(() => _selectedAddressId = v),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showAddAddressModal(context, appState),
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(
                        appState.text(
                          en: 'Add New Address',
                          ar: 'إضافة عنوان جديد',
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  SectionTitle(
                    title: appState.text(
                      en: 'Payment Method',
                      ar: 'طريقة الدفع',
                    ),
                    subtitle: '',
                  ),
                  const SizedBox(height: 12),
                  RadioListTile<String>(
                    value: 'Cash on Delivery',
                    groupValue: _selectedPayment,
                    title: const Text('Cash on Delivery'),
                    subtitle: Text(
                      appState.text(
                        en: 'Pay when you receive your order',
                        ar: 'ادفع عند استلام طلبك',
                      ),
                    ),
                    onChanged: (v) => setState(
                      () => _selectedPayment = v ?? 'Cash on Delivery',
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  RadioListTile<String>(
                    value: 'Market payment',
                    groupValue: _selectedPayment,
                    title: const Text('Market Payment'),
                    subtitle: Text(
                      appState.text(
                        en: 'Pay using your market account',
                        ar: 'ادفع باستخدام حساب السوق',
                      ),
                    ),
                    onChanged: (v) => setState(
                      () => _selectedPayment = v ?? 'Cash on Delivery',
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 24),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                appState.text(
                                  en: 'Subtotal',
                                  ar: 'المجموع الفرعي',
                                ),
                              ),
                              Text(
                                '\$${appState.cartSubtotal.toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                          if (appState.isWholesale) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  appState.text(
                                    en: 'Wholesale Discount (10%)',
                                    ar: 'خصم الجملة (10%)',
                                  ),
                                ),
                                Text(
                                  '-\$${appState.estimatedWholesaleDiscount.toStringAsFixed(2)}',
                                  style: const TextStyle(color: Colors.green),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(appState.text(en: 'Shipping', ar: 'الشحن')),
                              Text(
                                shippingCost == 0
                                    ? appState.text(en: 'Free', ar: 'مجاني')
                                    : '\$${shippingCost.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: shippingCost == 0
                                      ? Colors.green
                                      : null,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                appState.text(en: 'Total', ar: 'المجموع'),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$${total.toStringAsFixed(2)}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 80), // Space for bottom button
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: FilledButton(
          onPressed: _isPlacingOrder || appState.isCheckoutLoading
              ? null
              : _placeOrder,
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
          child: _isPlacingOrder || appState.isCheckoutLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    appState.text(en: 'Place Order', ar: 'تأكيد الطلب'),
                    maxLines: 1,
                  ),
                ),
        ),
      ),
    );
  }

  void _showAddAddressModal(BuildContext context, AppStateProvider appState) {
    final fullNameCtrl = TextEditingController(
      text: appState.profile?.fullName ?? '',
    );
    final phoneCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final streetCtrl = TextEditingController();
    final buildingCtrl = TextEditingController();
    bool isDefault = false;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appState.text(en: 'Add Address', ar: 'إضافة عنوان'),
                style: Theme.of(
                  ctx,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: fullNameCtrl,
                decoration: InputDecoration(
                  labelText: appState.text(en: 'Full Name', ar: 'الاسم الكامل'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                decoration: InputDecoration(
                  labelText: appState.text(en: 'Phone', ar: 'الهاتف'),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cityCtrl,
                decoration: InputDecoration(
                  labelText: appState.text(en: 'City', ar: 'المدينة'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: streetCtrl,
                decoration: InputDecoration(
                  labelText: appState.text(en: 'Street', ar: 'الشارع'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: buildingCtrl,
                decoration: InputDecoration(
                  labelText: appState.text(
                    en: 'Building / Notes',
                    ar: 'المبنى / ملاحظات',
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                value: isDefault,
                onChanged: (v) => setModalState(() => isDefault = v ?? false),
                title: Text(
                  appState.text(
                    en: 'Set as default address',
                    ar: 'تعيين كعنوان افتراضي',
                  ),
                ),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(appState.text(en: 'Cancel', ar: 'إلغاء')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              if (fullNameCtrl.text.trim().isEmpty ||
                                  phoneCtrl.text.trim().isEmpty ||
                                  cityCtrl.text.trim().isEmpty ||
                                  streetCtrl.text.trim().isEmpty) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      appState.text(
                                        en: 'Full name, phone, city, and street are required',
                                        ar: 'الاسم الكامل والهاتف والمدينة والشارع مطلوبة',
                                      ),
                                    ),
                                  ),
                                );
                                return;
                              }
                              setModalState(() => isSaving = true);
                              try {
                                final createdAddress = await appState
                                    .createAddress(
                                      UserAddress(
                                        id: '',
                                        label: 'Home',
                                        fullName: fullNameCtrl.text.trim(),
                                        phone: phoneCtrl.text.trim(),
                                        city: cityCtrl.text.trim(),
                                        street: streetCtrl.text.trim(),
                                        building: buildingCtrl.text.trim(),
                                        notes: null,
                                        isDefault:
                                            isDefault ||
                                            appState.userAddresses.isEmpty,
                                        createdAt: DateTime.now(),
                                      ),
                                    );
                                if (mounted) {
                                  setState(
                                    () =>
                                        _selectedAddressId = createdAddress.id,
                                  );
                                }
                                if (ctx.mounted) {
                                  Navigator.pop(ctx);
                                }
                              } catch (e) {
                                if (ctx.mounted) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                }
                              } finally {
                                setModalState(() => isSaving = false);
                              }
                            },
                      child: isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(appState.text(en: 'Save', ar: 'حفظ')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
