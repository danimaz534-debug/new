import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/app_state_provider.dart';
import '../../widgets/section_title.dart';
import '../about/about_screen.dart';
import '../addresses/addresses_screen.dart';
import '../orders/orders_screen.dart';
import '../support/help_center_screen.dart';
import 'account_management_screen.dart';
import 'profile_edit_screen.dart';
import 'security_screen.dart';
import 'wholesale_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.onRequireAuth});

  final VoidCallback onRequireAuth;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final sectionSurface = isDark ? const Color(0xFF151515) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : scheme.outlineVariant.withValues(alpha: 0.3);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.92),
        elevation: 0,
        centerTitle: true,
        title: Text(
          appState.text(en: 'Profile', ar: 'الملف الشخصي'),
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
              title: appState.text(en: 'Account', ar: 'الحساب'),
              subtitle: appState.text(
                en: 'Profile details, appearance, addresses, and privacy settings.',
                ar: 'تفاصيل الحساب، المظهر، العناوين، وإعدادات الخصوصية.',
              ),
            ),
            const SizedBox(height: 24),
            if (appState.isAuthenticated) ...[
              Container(
                decoration: BoxDecoration(
                  color: sectionSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: scheme.primary, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 38,
                          backgroundColor: scheme.surfaceContainerHighest,
                          backgroundImage:
                              appState.currentUser?.avatarUrl != null
                              ? NetworkImage(appState.currentUser!.avatarUrl!)
                              : null,
                          child: appState.currentUser?.avatarUrl == null
                              ? Icon(
                                  Icons.person_rounded,
                                  size: 36,
                                  color: scheme.onSurface.withValues(
                                    alpha: 0.35,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appState.currentUser?.displayName ?? 'N/A',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              appState.currentUser?.email ?? 'N/A',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurface.withValues(alpha: 0.65),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _RoleChip(
                                  label:
                                      appState.currentUser?.shortRole
                                          .toUpperCase() ??
                                      'RETAIL',
                                  foreground: scheme.primary,
                                  background: scheme.primary.withValues(
                                    alpha: 0.12,
                                  ),
                                ),
                                _RoleChip(
                                  label: appState.text(
                                    en: 'Photo & Theme in Edit',
                                    ar: 'الصورة والثيم في التعديل',
                                  ),
                                  foreground: scheme.onSurface.withValues(
                                    alpha: 0.75,
                                  ),
                                  background: scheme.surfaceContainerHighest,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ProfileEditScreen(),
                            ),
                          );
                        },
                        icon: Icon(Icons.edit_outlined, color: scheme.primary),
                        tooltip: appState.text(
                          en: 'Edit profile',
                          ar: 'تعديل الملف الشخصي',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (!appState.isWholesale)
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const WholesaleScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          scheme.primary,
                          scheme.primary.withValues(alpha: 0.72),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.stars_rounded,
                          color: scheme.onPrimary,
                          size: 30,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appState.text(
                                  en: 'Join Wholesale Club',
                                  ar: 'انضم لنادي الجملة',
                                ),
                                style: TextStyle(
                                  color: scheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                appState.text(
                                  en: 'Unlock wholesale pricing and a dedicated checkout experience.',
                                  ar: 'احصل على أسعار الجملة وتجربة شراء مخصصة.',
                                ),
                                style: TextStyle(
                                  color: scheme.onPrimary.withValues(
                                    alpha: 0.8,
                                  ),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: scheme.onPrimary,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: sectionSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    _buildMenuTile(
                      context,
                      icon: Icons.shopping_bag_outlined,
                      title: appState.text(en: 'My Orders', ar: 'طلباتي'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const OrdersScreen()),
                      ),
                    ),
                    _buildDivider(borderColor),
                    _buildMenuTile(
                      context,
                      icon: Icons.location_on_outlined,
                      title: appState.text(
                        en: 'Shipping Addresses',
                        ar: 'عناوين الشحن',
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AddressesScreen(),
                        ),
                      ),
                    ),
                    _buildDivider(borderColor),
                    _buildMenuTile(
                      context,
                      icon: Icons.shield_outlined,
                      title: appState.text(
                        en: 'Status & Privacy',
                        ar: 'الحالة والخصوصية',
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SecurityScreen(),
                        ),
                      ),
                    ),
                    _buildDivider(borderColor),
                    _buildMenuTile(
                      context,
                      icon: Icons.manage_accounts_outlined,
                      title: appState.text(
                        en: 'Account Management',
                        ar: 'إدارة الحساب',
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AccountManagementScreen(),
                        ),
                      ),
                    ),
                    _buildDivider(borderColor),
                    _buildMenuTile(
                      context,
                      icon: Icons.help_outline_rounded,
                      title: appState.text(
                        en: 'Help Center',
                        ar: 'مركز المساعدة',
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HelpCenterScreen(),
                        ),
                      ),
                    ),
                    _buildDivider(borderColor),
                    _buildMenuTile(
                      context,
                      icon: Icons.info_outline_rounded,
                      title: appState.text(en: 'About', ar: 'حول التطبيق'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AboutScreen()),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: sectionSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: _buildMenuTile(
                  context,
                  icon: Icons.logout_rounded,
                  title: appState.text(en: 'Sign Out', ar: 'تسجيل الخروج'),
                  color: Colors.redAccent,
                  onTap: () async {
                    await appState.logout();
                    onRequireAuth();
                  },
                ),
              ),
            ] else ...[
              Container(
                decoration: BoxDecoration(
                  color: sectionSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                    Icon(
                      Icons.account_circle_outlined,
                      size: 78,
                      color: scheme.onSurface.withValues(alpha: 0.18),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      appState.text(
                        en: 'Sign in to manage your account',
                        ar: 'سجّل الدخول لإدارة حسابك',
                      ),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      appState.text(
                        en: 'Orders, addresses, appearance, and privacy settings live here.',
                        ar: 'الطلبات، العناوين، المظهر، وإعدادات الخصوصية موجودة هنا.',
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.65),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: onRequireAuth,
                        child: Text(
                          appState.text(en: 'Sign In', ar: 'تسجيل الدخول'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? scheme.primary.withValues(alpha: 0.85),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? scheme.onSurface,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: scheme.onSurface.withValues(alpha: 0.28),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Widget _buildDivider(Color color) {
    return Divider(color: color, height: 1, indent: 20, endIndent: 20);
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
