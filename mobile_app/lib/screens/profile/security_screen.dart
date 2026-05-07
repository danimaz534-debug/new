import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/app_state_provider.dart';
import '../../widgets/feedback.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _twoFactorEnabled = true;
  bool _dataSharingEnabled = false;
  String _deviceName = 'Loading...';
  IconData _deviceIcon = Icons.device_unknown_rounded;

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    String name = 'Unknown Device';
    IconData icon = Icons.device_unknown_rounded;

    try {
      if (kIsWeb) {
        final webInfo = await deviceInfo.webBrowserInfo;
        name = 'Web ${webInfo.browserName.name.toUpperCase()}';
        icon = Icons.language_rounded;
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        final brand =
            androidInfo.brand[0].toUpperCase() + androidInfo.brand.substring(1);
        name = '$brand ${androidInfo.model}';
        icon = Icons.smartphone_rounded;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        name = iosInfo.name;
        icon = Icons.phone_iphone_rounded;
      } else if (Platform.isWindows) {
        final winInfo = await deviceInfo.windowsInfo;
        name = winInfo.computerName;
        icon = Icons.desktop_windows_rounded;
      } else if (Platform.isMacOS) {
        final macInfo = await deviceInfo.macOsInfo;
        name = macInfo.computerName;
        icon = Icons.laptop_mac_rounded;
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _deviceName = name;
        _deviceIcon = icon;
      });
    }
  }

  Future<void> _showChangePasswordDialog(AppStateProvider appState) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: Text(
            appState.text(en: 'Change Password', ar: 'تغيير كلمة المرور'),
          ),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: InputDecoration(
              hintText: appState.text(
                en: 'Enter new password',
                ar: 'أدخل كلمة المرور الجديدة',
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(appState.text(en: 'Cancel', ar: 'إلغاء')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              style: FilledButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
              ),
              child: Text(appState.text(en: 'Update', ar: 'تحديث')),
            ),
          ],
        );
      },
    );

    if (result == null || result.isEmpty) return;

    try {
      await appState.changePassword(result);
      if (!mounted) return;
      showAppSnackBar(
        context,
        appState.text(
          en: 'Password updated successfully.',
          ar: 'تم تحديث كلمة المرور بنجاح.',
        ),
      );
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, e.toString(), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final cardColor = theme.brightness == Brightness.dark
        ? const Color(0xFF141414)
        : Colors.white;
    final borderColor = scheme.outlineVariant.withValues(alpha: 0.28);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          appState.text(en: 'Status & Privacy', ar: 'الحالة والخصوصية'),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          _buildSection(
            context,
            title: appState.text(
              en: 'Login & Password',
              ar: 'تسجيل الدخول وكلمة المرور',
            ),
            children: [
              _buildActionTile(
                context,
                cardColor: cardColor,
                borderColor: borderColor,
                icon: Icons.alternate_email_rounded,
                title: appState.text(
                  en: 'Email Address',
                  ar: 'عنوان البريد الإلكتروني',
                ),
                subtitle: appState.currentUser?.email ?? 'N/A',
              ),
              _buildActionTile(
                context,
                cardColor: cardColor,
                borderColor: borderColor,
                icon: Icons.password_rounded,
                title: appState.text(
                  en: 'Change Password',
                  ar: 'تغيير كلمة المرور',
                ),
                subtitle: appState.text(
                  en: 'Update your password whenever you need.',
                  ar: 'حدّث كلمة المرور متى احتجت.',
                ),
                onTap: () => _showChangePasswordDialog(appState),
              ),
              _buildSwitchTile(
                context,
                cardColor: cardColor,
                borderColor: borderColor,
                icon: Icons.verified_user_outlined,
                title: appState.text(
                  en: 'Two-Factor Authentication',
                  ar: 'المصادقة الثنائية',
                ),
                subtitle: _twoFactorEnabled
                    ? appState.text(en: 'Enabled', ar: 'مفعلة')
                    : appState.text(en: 'Disabled', ar: 'معطلة'),
                value: _twoFactorEnabled,
                onChanged: (val) => setState(() => _twoFactorEnabled = val),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _buildSection(
            context,
            title: appState.text(en: 'Current Session', ar: 'الجلسة الحالية'),
            children: [
              _buildActionTile(
                context,
                cardColor: cardColor,
                borderColor: borderColor,
                icon: _deviceIcon,
                title: _deviceName,
                subtitle: appState.text(
                  en: 'This device is currently signed in.',
                  ar: 'هذا الجهاز مسجّل الدخول حالياً.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _buildSection(
            context,
            title: appState.text(en: 'Privacy', ar: 'الخصوصية'),
            children: [
              _buildSwitchTile(
                context,
                cardColor: cardColor,
                borderColor: borderColor,
                icon: Icons.share_outlined,
                title: appState.text(en: 'Data Sharing', ar: 'مشاركة البيانات'),
                subtitle: appState.text(
                  en: 'Help improve the app with anonymous usage data.',
                  ar: 'ساعد في تحسين التطبيق عبر بيانات استخدام مجهولة.',
                ),
                value: _dataSharingEnabled,
                onChanged: (val) => setState(() => _dataSharingEnabled = val),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              color: scheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Column(
          children: children
              .map(
                (child) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: child,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required Color cardColor,
    required Color borderColor,
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
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
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: scheme.onSurface.withValues(alpha: 0.28),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required Color cardColor,
    required Color borderColor,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: scheme.primary,
          ),
        ],
      ),
    );
  }
}
