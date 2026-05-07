import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/app_state_provider.dart';

class AccountManagementScreen extends StatelessWidget {
  const AccountManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final cardColor = theme.brightness == Brightness.dark
        ? const Color(0xFF141414)
        : Colors.white;
    final borderColor = scheme.outlineVariant.withValues(alpha: 0.3);
    final history = appState.watchHistory;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          appState.text(en: 'Account Management', ar: 'إدارة الحساب'),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.manage_accounts_outlined,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appState.currentUser?.shortRole.toUpperCase() ??
                            'RETAIL',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appState.text(
                          en: 'Overview of your account activity and stored profile data.',
                          ar: 'نظرة عامة على نشاط الحساب وبيانات الملف الشخصي المخزنة.',
                        ),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _InfoTile(
            icon: Icons.history_outlined,
            title: appState.text(en: 'Recently Viewed', ar: 'شوهد مؤخراً'),
            subtitle: history.isEmpty
                ? appState.text(
                    en: 'No recent products yet.',
                    ar: 'لا توجد منتجات شوهدت مؤخراً بعد.',
                  )
                : '${history.length} ${appState.text(en: 'items in your recent history', ar: 'عنصر في السجل الأخير')}',
            cardColor: cardColor,
            borderColor: borderColor,
          ),
          const SizedBox(height: 12),
          _InfoTile(
            icon: Icons.location_on_outlined,
            title: appState.text(
              en: 'Saved Addresses',
              ar: 'العناوين المحفوظة',
            ),
            subtitle:
                '${appState.userAddresses.length} ${appState.text(en: 'address entries', ar: 'مدخل عنوان')}',
            cardColor: cardColor,
            borderColor: borderColor,
          ),
          const SizedBox(height: 12),
          _InfoTile(
            icon: Icons.language_outlined,
            title: appState.text(en: 'Preferred Language', ar: 'اللغة المفضلة'),
            subtitle: appState.localeCode == 'ar'
                ? appState.text(en: 'Arabic', ar: 'العربية')
                : appState.text(en: 'English', ar: 'الإنجليزية'),
            cardColor: cardColor,
            borderColor: borderColor,
          ),
          const SizedBox(height: 12),
          _InfoTile(
            icon: Icons.color_lens_outlined,
            title: appState.text(en: 'Appearance Mode', ar: 'وضع المظهر'),
            subtitle: switch (appState.themeMode) {
              ThemeMode.dark => appState.text(
                en: 'Dark mode',
                ar: 'الوضع الداكن',
              ),
              ThemeMode.system => appState.text(
                en: 'Follow device settings',
                ar: 'اتّباع إعدادات الجهاز',
              ),
              _ => appState.text(en: 'Light mode', ar: 'الوضع الفاتح'),
            },
            cardColor: cardColor,
            borderColor: borderColor,
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.cardColor,
    required this.borderColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color cardColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: scheme.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
