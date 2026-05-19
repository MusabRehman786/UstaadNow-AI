import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../shared/widgets/app_ui_helpers.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = _mockNotifications();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(onPressed: () {}, child: const Text('Mark all read')),
        ],
      ),
      body: notifications.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.notifications_off_outlined,
              title: 'No notifications',
              subtitle: 'You\'re all caught up!',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppDimensions.pagePadding),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const VGap(8),
              itemBuilder: (ctx, i) => _NotifCard(notif: notifications[i]),
            ),
    );
  }

  List<_Notif> _mockNotifications() => [
        _Notif(
          icon: Icons.check_circle_rounded,
          iconColor: AppColors.success,
          title: 'Booking Confirmed',
          body: 'Ustad Hamid has accepted your AC service booking.',
          time: '5 min ago',
          isRead: false,
        ),
        _Notif(
          icon: Icons.construction_rounded,
          iconColor: AppColors.info,
          title: 'Provider En Route',
          body: 'Ustad Hamid is on his way to your location.',
          time: '1 hour ago',
          isRead: false,
        ),
        _Notif(
          icon: Icons.verified_rounded,
          iconColor: AppColors.statusCompleted,
          title: 'Job Completed',
          body: 'Your plumbing service has been completed. Rate your experience.',
          time: '2 days ago',
          isRead: true,
        ),
        _Notif(
          icon: Icons.star_rounded,
          iconColor: AppColors.accent,
          title: 'Please Rate',
          body: 'How was your experience with Ustad Rafiq?',
          time: '3 days ago',
          isRead: true,
        ),
      ];
}

class _Notif {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final String time;
  final bool isRead;
  const _Notif({
    required this.icon, required this.iconColor, required this.title,
    required this.body, required this.time, required this.isRead,
  });
}

class _NotifCard extends StatelessWidget {
  final _Notif notif;
  const _NotifCard({required this.notif});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: notif.isRead
            ? theme.colorScheme.surface
            : AppColors.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: notif.isRead
              ? theme.colorScheme.outlineVariant
              : AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: notif.iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(notif.icon, color: notif.iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(notif.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700))),
                    if (!notif.isRead)
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(notif.body, style: theme.textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(notif.time, style: theme.textTheme.labelSmall?.copyWith(color: AppColors.textHint)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
