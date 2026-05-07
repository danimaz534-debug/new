import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:mobile_app/core/providers/app_state_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF151515) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : scheme.outlineVariant.withValues(alpha: 0.28);
    final mutedText = scheme.onSurface.withValues(alpha: 0.55);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          appState.text(en: 'CURATED UPDATES', ar: 'تحديثات منسقة'),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            color: scheme.primary,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.92),
        elevation: 0,
        centerTitle: true,
      ),
      body: appState.notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 64,
                    color: scheme.onSurface.withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    appState.text(
                      en: 'THE ARCHIVE IS EMPTY',
                      ar: 'الأرشيف فارغ',
                    ),
                    style: TextStyle(
                      color: mutedText,
                      fontSize: 12,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              color: scheme.primary,
              backgroundColor: surface,
              onRefresh: appState.refreshAll,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                itemCount: appState.notifications.length,
                itemBuilder: (context, index) {
                  final notification = appState.notifications[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: notification.isRead
                            ? borderColor
                            : scheme.primary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: notification.isRead
                              ? scheme.surfaceContainerHighest.withValues(
                                  alpha: 0.55,
                                )
                              : scheme.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications_active_rounded,
                          color: notification.isRead
                              ? scheme.onSurface.withValues(alpha: 0.4)
                              : scheme.primary,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        notification.title,
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            notification.body,
                            style: TextStyle(
                              color: mutedText,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            DateFormat(
                              'MMM dd, HH:mm',
                            ).format(notification.createdAt ?? DateTime.now()),
                            style: TextStyle(
                              color: scheme.onSurface.withValues(alpha: 0.35),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      trailing: !notification.isRead
                          ? Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                shape: BoxShape.circle,
                              ),
                            )
                          : null,
                      onTap: () {
                        if (!notification.isRead) {
                          appState.markNotificationRead(notification.id);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}
