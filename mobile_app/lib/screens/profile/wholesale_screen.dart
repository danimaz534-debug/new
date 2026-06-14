import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_state_provider.dart';

class WholesaleScreen extends StatelessWidget {
  const WholesaleScreen({super.key, this.onOpenChat});

  /// Called when the user wants to open the support chat to apply for wholesale.
  final VoidCallback? onOpenChat;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final user = appState.currentUser;
    final isWholesale = user?.isWholesale ?? false;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: isDark ? Colors.white : Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(context, isWholesale),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusSection(context, isWholesale),
                  const SizedBox(height: 32),
                  Text(
                    appState.text(
                      en: 'Program Benefits',
                      ar: 'مميزات البرنامج',
                    ),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildBenefitTile(
                    context,
                    icon: Icons.percent_rounded,
                    title: appState.text(en: 'Bulk Discounts', ar: 'خصومات الجملة'),
                    subtitle: appState.text(
                      en: 'Save up to 30% on bulk hardware orders.',
                      ar: 'وفر حتى 30% على طلبيات الأجهزة بالجملة.',
                    ),
                  ),
                  _buildBenefitTile(
                    context,
                    icon: Icons.support_agent_rounded,
                    title: appState.text(en: 'Priority Support', ar: 'دعم ذو أولوية'),
                    subtitle: appState.text(
                      en: 'Dedicated account manager for your business.',
                      ar: 'مدير حساب مخصص لعملك.',
                    ),
                  ),
                  _buildBenefitTile(
                    context,
                    icon: Icons.local_shipping_outlined,
                    title: appState.text(en: 'Free Express Shipping', ar: 'شحن سريع مجاني'),
                    subtitle: appState.text(
                      en: 'Priority handling and zero shipping costs.',
                      ar: 'تعامل ذو أولوية وتكاليف شحن صفرية.',
                    ),
                  ),
                  _buildBenefitTile(
                    context,
                    icon: Icons.verified_user_outlined,
                    title: appState.text(en: 'Exclusive Products', ar: 'منتجات حصرية'),
                    subtitle: appState.text(
                      en: 'Early access to rare Obsidian hardware.',
                      ar: 'وصول مبكر لأجهزة الأوبسيديان النادرة.',
                    ),
                  ),
                  const SizedBox(height: 48),
                  if (!isWholesale)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => _showApplyDialog(context, appState),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          appState.text(
                            en: 'Apply for Wholesale Status',
                            ar: 'طلب حالة الجملة',
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: scheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: scheme.primary.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.check_circle_outline_rounded, color: scheme.primary, size: 40),
                          const SizedBox(height: 12),
                          Text(
                            appState.text(
                              en: 'Wholesale Active',
                              ar: 'حساب الجملة نشط',
                            ),
                            style: TextStyle(
                              color: scheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            appState.text(
                              en: 'You are enjoying all wholesale benefits.',
                              ar: 'أنت تستمتع بجميع مميزات الجملة.',
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: scheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context, bool isWholesale) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A1A),
            scheme.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            top: -50,
            child: Icon(
              Icons.workspace_premium_rounded,
              size: 250,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(
                    Icons.business_center_outlined,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'OBSIDIAN ELITE',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Wholesale Program',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context, bool isWholesale) {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isWholesale ? Colors.amber.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: isWholesale ? Colors.amber.withOpacity(0.3) : Colors.blue.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isWholesale ? Icons.stars_rounded : Icons.info_outline,
            size: 16,
            color: isWholesale ? Colors.amber : Colors.blue,
          ),
          const SizedBox(width: 8),
          Text(
            isWholesale
                ? appState.text(en: 'Current Status: Wholesale', ar: 'الحالة الحالية: جملة')
                : appState.text(en: 'Current Status: Retail', ar: 'الحالة الحالية: تجزئة'),
            style: TextStyle(
              color: isWholesale ? Colors.amber : Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: scheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: scheme.onSurface.withOpacity(0.6),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showApplyDialog(BuildContext context, AppStateProvider appState) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.business_center_outlined, color: Color(0xFFD4AF37)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                appState.text(
                  en: 'How to Apply',
                  ar: 'كيفية التقديم',
                ),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(
          appState.text(
            en: 'Wholesale status is granted by our admin and sales team.\n\n'
                'To apply, simply open the Support Chat and tell us about your business. '
                'Our team will review your request and upgrade your account.',
            ar: 'حالة الجملة تُمنح من قِبَل فريق الإدارة والمبيعات.\n\n'
                'للتقديم، افتح محادثة الدعم وأخبرنا عن عملك. '
                'سيراجع فريقنا طلبك ويرقّي حسابك.',
          ),
          style: const TextStyle(fontSize: 14, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              appState.text(en: 'Cancel', ar: 'إلغاء'),
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
            label: Text(appState.text(en: 'Open Chat', ar: 'فتح المحادثة')),
            onPressed: () {
              Navigator.pop(ctx);
              // Pop the wholesale screen to go back to the shell, then open chat
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
              onOpenChat?.call();
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

