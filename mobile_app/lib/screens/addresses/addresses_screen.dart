import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/app_state_provider.dart';
import '../../models/user_address.dart';
import '../../widgets/section_title.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          appState.text(en: 'Shipping Portals', ar: 'بوابات الشحن'),
          style: TextStyle(
            color: scheme.onSurface,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: scheme.onSurface,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline_rounded, color: scheme.primary),
            onPressed: () => _showAddEditModal(context, appState, null),
          ),
        ],
      ),
      body: appState.isGuest
          ? _buildGuestView(context, appState)
          : _buildAddressList(context, appState),
    );
  }

  Widget _buildGuestView(BuildContext context, AppStateProvider appState) {
    final scheme = Theme.of(context).colorScheme;
    final mutedText = scheme.onSurface.withValues(alpha: 0.55);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 80,
              color: scheme.onSurface.withValues(alpha: 0.08),
            ),
            const SizedBox(height: 24),
            Text(
              appState.text(en: 'Destination Unknown', ar: 'الوجهة غير معروفة'),
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              appState.text(
                en: 'Please sign in to establish your delivery destinations.',
                ar: 'يرجى تسجيل الدخول لتحديد وجهات التوصيل الخاصة بك.',
              ),
              style: TextStyle(color: mutedText, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  appState.text(en: 'Sign In', ar: 'تسجيل الدخول'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressList(BuildContext context, AppStateProvider appState) {
    final addresses = appState.userAddresses;
    final scheme = Theme.of(context).colorScheme;
    final mutedText = scheme.onSurface.withValues(alpha: 0.55);

    if (addresses.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.map_outlined,
              size: 80,
              color: scheme.onSurface.withValues(alpha: 0.08),
            ),
            const SizedBox(height: 24),
            Text(
              appState.text(
                en: 'No Saved Destinies',
                ar: 'لا توجد وجهات محفوظة',
              ),
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              appState.text(
                en: 'Add an address before placing a new order.',
                ar: 'أضف عنواناً قبل إنشاء طلب جديد.',
              ),
              style: TextStyle(color: mutedText, fontSize: 14),
            ),
            const SizedBox(height: 24),
            _buildGoldButton(
              onPressed: () => _showAddEditModal(context, appState, null),
              label: appState.text(
                en: 'Establish New Portal',
                ar: 'إنشاء بوابة جديدة',
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        SectionTitle(
          title: appState.text(en: 'Registry', ar: 'السجل'),
          subtitle: appState.text(
            en: 'Curated delivery locations for your acquisitions.',
            ar: 'مواقع توصيل مختارة لاقتناءاتك.',
          ),
        ),
        const SizedBox(height: 24),
        ...addresses.map(
          (addr) => _AddressTile(
            address: addr,
            appState: appState,
            onEdit: () => _showAddEditModal(context, appState, addr),
            onDelete: () => _confirmDelete(context, appState, addr),
          ),
        ),
      ],
    );
  }

  Widget _buildGoldButton({
    required VoidCallback onPressed,
    required String label,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  void _confirmDelete(
    BuildContext context,
    AppStateProvider appState,
    UserAddress addr,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF1A1A1A) : Colors.white;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          appState.text(en: 'Archive Entry?', ar: 'أرشفة الإدخال؟'),
          style: TextStyle(
            color: scheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          appState.text(
            en: 'This delivery portal will be permanently removed from your registry.',
            ar: 'ستتم إزالة بوابة التوصيل هذه نهائياً من سجلك.',
          ),
          style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.6)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(appState.text(en: 'Maintain', ar: 'الإبقاء')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await appState.deleteAddress(addr.id);
            },
            child: Text(
              appState.text(en: 'Dissolve', ar: 'حل'),
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEditModal(
    BuildContext context,
    AppStateProvider appState,
    UserAddress? existing,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          _AddEditAddressModal(appState: appState, existing: existing),
    );
  }
}

class _AddressTile extends StatelessWidget {
  const _AddressTile({
    required this.address,
    required this.appState,
    required this.onEdit,
    required this.onDelete,
  });

  final UserAddress address;
  final AppStateProvider appState;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

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
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: address.isDefault
              ? scheme.primary.withValues(alpha: 0.3)
              : borderColor,
          width: address.isDefault ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: address.isDefault
                      ? scheme.primary.withValues(alpha: 0.12)
                      : scheme.surfaceContainerHighest.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  address.isDefault
                      ? Icons.star_rounded
                      : Icons.location_on_outlined,
                  color: address.isDefault
                      ? scheme.primary
                      : scheme.onSurface.withValues(alpha: 0.4),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          address.fullName,
                          style: TextStyle(
                            color: scheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (address.isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: scheme.primary.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Text(
                              appState.text(en: 'DEFAULT', ar: 'افتراضي'),
                              style: TextStyle(
                                color: scheme.primary,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${address.city}, ${address.street}',
                      style: TextStyle(
                        color: scheme.onSurface.withValues(alpha: 0.55),
                        fontSize: 14,
                      ),
                    ),
                    if (address.building.isNotEmpty)
                      Text(
                        address.building,
                        style: TextStyle(
                          color: scheme.onSurface.withValues(alpha: 0.4),
                          fontSize: 13,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      address.phone,
                      style: TextStyle(
                        color: scheme.onSurface.withValues(alpha: 0.45),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddEditAddressModal extends StatefulWidget {
  const _AddEditAddressModal({required this.appState, this.existing});

  final AppStateProvider appState;
  final UserAddress? existing;

  @override
  State<_AddEditAddressModal> createState() => _AddEditAddressModalState();
}

class _AddEditAddressModalState extends State<_AddEditAddressModal> {
  late TextEditingController fullNameCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController cityCtrl;
  late TextEditingController streetCtrl;
  late TextEditingController buildingCtrl;
  late bool isDefault;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    fullNameCtrl = TextEditingController(
      text:
          widget.existing?.fullName ??
          widget.appState.currentUser?.fullName ??
          '',
    );
    phoneCtrl = TextEditingController(text: widget.existing?.phone ?? '');
    cityCtrl = TextEditingController(text: widget.existing?.city ?? '');
    streetCtrl = TextEditingController(text: widget.existing?.street ?? '');
    buildingCtrl = TextEditingController(text: widget.existing?.building ?? '');
    isDefault = widget.existing?.isDefault ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF1A1A1A) : Colors.white;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 40,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.onSurface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            widget.existing == null
                ? widget.appState.text(
                    en: 'Establish New Portal',
                    ar: 'إنشاء بوابة جديدة',
                  )
                : widget.appState.text(
                    en: 'Refine Portal',
                    ar: 'تعديل البوابة',
                  ),
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildTextField(
            fullNameCtrl,
            widget.appState.text(en: 'Full Name', ar: 'الاسم الكامل'),
            Icons.person_outline,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            phoneCtrl,
            widget.appState.text(en: 'Phone Number', ar: 'رقم الهاتف'),
            Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            cityCtrl,
            widget.appState.text(en: 'City', ar: 'المدينة'),
            Icons.location_city_outlined,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            streetCtrl,
            widget.appState.text(en: 'Street', ar: 'الشارع'),
            Icons.map_outlined,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            buildingCtrl,
            widget.appState.text(en: 'Building / Suite', ar: 'المبنى / الجناح'),
            Icons.business_outlined,
          ),
          const SizedBox(height: 16),
          Theme(
            data: Theme.of(context).copyWith(
              checkboxTheme: CheckboxThemeData(
                side: BorderSide(
                  color: scheme.onSurface.withValues(alpha: 0.24),
                ),
              ),
            ),
            child: CheckboxListTile(
              value: isDefault,
              onChanged: (v) => setState(() => isDefault = v ?? false),
              title: Text(
                widget.appState.text(
                  en: 'Set as Primary Destiny',
                  ar: 'تعيين كوجهة رئيسية',
                ),
                style: TextStyle(color: scheme.onSurface, fontSize: 14),
              ),
              activeColor: scheme.primary,
              checkColor: scheme.onPrimary,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      widget.appState.text(
                        en: 'Save Configuration',
                        ar: 'حفظ الإعدادات',
                      ),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: TextStyle(color: scheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: scheme.onSurface.withValues(alpha: 0.4)),
        prefixIcon: Icon(
          icon,
          color: scheme.primary.withValues(alpha: 0.8),
          size: 20,
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (cityCtrl.text.isEmpty || streetCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.appState.text(
              en: 'City and street are required',
              ar: 'المدينة والشارع مطلوبان',
            ),
          ),
        ),
      );
      return;
    }

    setState(() => isSaving = true);
    try {
      if (widget.existing == null) {
        await widget.appState.createAddress(
          UserAddress(
            id: '',
            label: 'Home',
            fullName: fullNameCtrl.text.trim(),
            phone: phoneCtrl.text.trim(),
            city: cityCtrl.text.trim(),
            street: streetCtrl.text.trim(),
            building: buildingCtrl.text.trim(),
            notes: null,
            isDefault: isDefault,
            createdAt: DateTime.now(),
          ),
        );
      } else {
        await widget.appState.updateAddress(
          widget.existing!.copyWith(
            fullName: fullNameCtrl.text.trim(),
            phone: phoneCtrl.text.trim(),
            city: cityCtrl.text.trim(),
            street: streetCtrl.text.trim(),
            building: buildingCtrl.text.trim(),
            isDefault: isDefault,
          ),
        );
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }
}
