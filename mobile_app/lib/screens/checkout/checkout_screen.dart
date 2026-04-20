import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/app_state_provider.dart';
import '../../widgets/section_title.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(appState.text(en: 'Checkout', ar: 'الدفع')),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            SectionTitle(
              title: appState.text(en: 'Shipping Information', ar: 'معلومات الشحن'),
              subtitle: appState.text(
                en: 'Please provide your shipping details.',
                ar: 'يرجى تقديم تفاصيل الشحن.',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: appState.text(en: 'Full Name', ar: 'الاسم الكامل'),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return appState.text(en: 'Please enter your name', ar: 'يرجى إدخال اسمك');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: appState.text(en: 'Phone Number', ar: 'رقم الهاتف'),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return appState.text(en: 'Please enter your phone number', ar: 'يرجى إدخال رقم هاتفك');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: appState.text(en: 'Address', ar: 'العنوان'),
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return appState.text(en: 'Please enter your address', ar: 'يرجى إدخال عنوانك');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: appState.text(en: 'City', ar: 'المدينة'),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return appState.text(en: 'Please enter your city', ar: 'يرجى إدخال مدينتك');
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _zipController,
                    decoration: InputDecoration(
                      labelText: appState.text(en: 'ZIP Code', ar: 'الرمز البريدي'),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return appState.text(en: 'Please enter ZIP code', ar: 'يرجى إدخال الرمز البريدي');
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appState.text(en: 'Order Summary', ar: 'ملخص الطلب'),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...appState.cartEntries.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${entry.product.name} x${entry.quantity}',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          Text(
                            '\$${(entry.product.price * entry.quantity).toStringAsFixed(2)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          appState.text(en: 'Total', ar: 'المجموع'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '\$${appState.cartTotal.toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // TODO: Process payment and create order
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(appState.text(
                        en: 'Order placed successfully!',
                        ar: 'تم تقديم الطلب بنجاح!',
                      )),
                    ),
                  );
                  // Clear cart and navigate back
                  await appState.clearCart();
                  Navigator.of(context).pop();
                }
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(appState.text(en: 'Place Order', ar: 'تقديم الطلب')),
            ),
          ],
        ),
      ),
    );
  }
}