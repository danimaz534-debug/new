import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/providers/app_state_provider.dart';
import '../../widgets/feedback.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late TextEditingController _nameController;
  String _selectedLanguage = 'en';
  ThemeMode _selectedTheme = ThemeMode.light;
  bool _isLoading = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppStateProvider>();
    _nameController = TextEditingController(
      text: appState.currentUser?.displayName ?? '',
    );
    _selectedLanguage = appState.localeCode;
    _selectedTheme = appState.themeMode;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save(AppStateProvider appState) async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      showAppSnackBar(
        context,
        appState.text(en: 'Full name is required.', ar: 'الاسم الكامل مطلوب.'),
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await appState.updateProfile(
        fullName: name,
        preferredLanguage: _selectedLanguage,
      );
      await appState.setThemeMode(_selectedTheme);
      if (!mounted) return;
      showAppSnackBar(
        context,
        appState.text(
          en: 'Profile updated successfully.',
          ar: 'تم تحديث الملف الشخصي بنجاح.',
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, e.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickAndUploadImage(AppStateProvider appState) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 900,
        maxHeight: 900,
        imageQuality: 86,
      );
      if (image == null) return;

      final user = appState.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      setState(() => _isUploadingImage = true);

      final bytes = await image.readAsBytes();
      final mimeType = image.mimeType?.toLowerCase() ?? 'image/jpeg';
      final fileExt = switch (mimeType) {
        'image/png' => 'png',
        'image/webp' => 'webp',
        'image/gif' => 'gif',
        'image/jpeg' => 'jpg',
        _ => 'jpg',
      };
      final fileName =
          '${user.id}/avatar_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final contentType = mimeType;

      await Supabase.instance.client.storage
          .from('avatars')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(upsert: true, contentType: contentType),
          );

      final avatarUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(fileName);

      await appState.updateAvatar(avatarUrl);
      if (!mounted) return;
      showAppSnackBar(
        context,
        appState.text(
          en: 'Profile picture updated.',
          ar: 'تم تحديث صورة الملف الشخصي.',
        ),
      );
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, e.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sectionSurface = theme.brightness == Brightness.dark
        ? const Color(0xFF151515)
        : Colors.white;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          appState.text(en: 'Edit Profile', ar: 'تعديل الملف الشخصي'),
        ),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: () => _save(appState),
              child: Text(
                appState.text(en: 'Save', ar: 'حفظ'),
                style: TextStyle(
                  color: scheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: sectionSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  Stack(
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
                      if (_isUploadingImage)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.35),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appState.text(
                            en: 'Profile picture',
                            ar: 'صورة الملف الشخصي',
                          ),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appState.text(
                            en: 'Change the photo from inside edit settings.',
                            ar: 'غيّر الصورة من داخل إعدادات التعديل.',
                          ),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.65),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.tonalIcon(
                          onPressed: _isUploadingImage
                              ? null
                              : () => _pickAndUploadImage(appState),
                          icon: const Icon(
                            Icons.photo_camera_outlined,
                            size: 18,
                          ),
                          label: Text(
                            appState.text(
                              en: 'Change Photo',
                              ar: 'تغيير الصورة',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildFieldLabel(
              context,
              appState.text(en: 'Full Name', ar: 'الاسم الكامل'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: appState.text(
                  en: 'Enter your full name',
                  ar: 'أدخل الاسم الكامل',
                ),
              ),
            ),
            const SizedBox(height: 28),
            _buildFieldLabel(
              context,
              appState.text(en: 'Language Preference', ar: 'تفضيلات اللغة'),
            ),
            const SizedBox(height: 12),
            _buildOptionCard(
              context,
              title: 'English',
              subtitle: appState.text(en: 'English', ar: 'الإنجليزية'),
              selected: _selectedLanguage == 'en',
              onTap: () => setState(() => _selectedLanguage = 'en'),
            ),
            const SizedBox(height: 12),
            _buildOptionCard(
              context,
              title: 'Arabic',
              subtitle: appState.text(en: 'Arabic', ar: 'العربية'),
              selected: _selectedLanguage == 'ar',
              onTap: () => setState(() => _selectedLanguage = 'ar'),
            ),
            const SizedBox(height: 28),
            _buildFieldLabel(
              context,
              appState.text(en: 'Appearance', ar: 'المظهر'),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildThemeChip(
                  context,
                  mode: ThemeMode.light,
                  icon: Icons.light_mode_outlined,
                  label: appState.text(en: 'Light', ar: 'فاتح'),
                ),
                _buildThemeChip(
                  context,
                  mode: ThemeMode.dark,
                  icon: Icons.dark_mode_outlined,
                  label: appState.text(en: 'Dark', ar: 'داكن'),
                ),
                _buildThemeChip(
                  context,
                  mode: ThemeMode.system,
                  icon: Icons.phone_android_rounded,
                  label: appState.text(en: 'System', ar: 'النظام'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(BuildContext context, String label) {
    final scheme = Theme.of(context).colorScheme;
    return Text(
      label,
      style: TextStyle(
        color: scheme.onSurface.withValues(alpha: 0.72),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary.withValues(alpha: 0.12)
              : scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? scheme.primary
                : scheme.outlineVariant.withValues(alpha: 0.35),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
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
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, color: scheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeChip(
    BuildContext context, {
    required ThemeMode mode,
    required IconData icon,
    required String label,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final selected = _selectedTheme == mode;
    return InkWell(
      onTap: () => setState(() => _selectedTheme = mode),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary.withValues(alpha: 0.12)
              : scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? scheme.primary
                : scheme.outlineVariant.withValues(alpha: 0.35),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? scheme.primary : scheme.onSurface,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? scheme.primary : scheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
