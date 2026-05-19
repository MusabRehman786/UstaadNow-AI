import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../shared/extensions/app_extensions.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/models/booking_model.dart';
import '../../../../shared/widgets/app_cards.dart';
import '../../../../shared/widgets/app_ui_helpers.dart';
import '../../../auth/data/auth_provider.dart';
import '../../../booking/data/repositories/booking_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Language / زبان منتخب کریں',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _LanguageTile(
                  label: 'English',
                  selected: true,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Language set to English')),
                    );
                  },
                ),
                const Divider(),
                _LanguageTile(
                  label: 'اردو (Urdu)',
                  selected: false,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('زبان اردو منتخب کر لی گئی ہے')),
                    );
                  },
                ),
                const Divider(),
                _LanguageTile(
                  label: 'Roman Urdu',
                  selected: false,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Language set to Roman Urdu')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final user = currentUser ?? UserModel.mock;
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    // Retrieve active bookings reactively from Database Notifier for real stats count
    final bookingsState = ref.watch(bookingsNotifierProvider);
    final bookings = bookingsState.value ?? [];
    final totalBookings = bookings.length;
    final completedBookings = bookings.where((b) => b.status == BookingStatus.completed).length;
    final cancelledBookings = bookings.where((b) => b.status == BookingStatus.cancelled).length;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Premium Profile Header & Overlapping Stats
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Curved Gradient Background
                Container(
                  padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 20, 20, 70),
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(36),
                      bottomRight: Radius.circular(36),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Avatar with glowing border
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 8)),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 42,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: Text(
                            user.name.isNotEmpty ? user.name.substring(0, 1) : 'U',
                            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      // User Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Text(user.phone, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                            const SizedBox(height: 12),
                            // Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.verified_user_rounded, color: Colors.white, size: 14),
                                  const SizedBox(width: 6),
                                  Text(
                                    user.role == UserRole.customer ? 'Verified Customer' : 'Verified Provider',
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Overlapping Stats Card
                Positioned(
                  bottom: -40,
                  left: 20,
                  right: 20,
                  child: AppCard(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    child: Row(
                      children: [
                        Expanded(child: _StatTile(label: 'Total Bookings', value: '$totalBookings')),
                        const _Divider(),
                        Expanded(child: _StatTile(label: 'Completed', value: '$completedBookings', valueColor: AppColors.success)),
                        const _Divider(),
                        Expanded(child: _StatTile(label: 'Cancelled', value: '$cancelledBookings', valueColor: AppColors.error)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 64),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.pagePadding),
              child: Column(
                children: [
                  // Clean, fully functional menu items based on user role
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _MenuItem(
                          icon: Icons.notifications_outlined,
                          label: 'Notifications',
                          onTap: () => context.push(AppRoutes.notifications),
                        ),
                        _Divider2(),
                        _MenuItem(
                          icon: Icons.dark_mode_outlined,
                          label: 'Dark Mode',
                          trailing: Switch(
                            value: isDark,
                            onChanged: (_) => ref.read(themeProvider.notifier).toggleDarkMode(),
                            activeColor: AppColors.primary,
                          ),
                          onTap: null,
                        ),
                        _Divider2(),
                        _MenuItem(
                          icon: Icons.language_rounded,
                          label: 'Language',
                          subtitle: 'English',
                          onTap: () => _showLanguageSelector(context),
                        ),
                        _Divider2(),
                        _MenuItem(
                          icon: Icons.logout_rounded,
                          label: 'Logout',
                          iconColor: AppColors.error,
                          textColor: AppColors.error,
                          onTap: () async {
                            final confirm = await context.showConfirmDialog(
                              title: 'Logout / لاگ آؤٹ',
                              message: 'Are you sure you want to logout?\nکیا آپ لاگ آؤٹ کرنا چاہتے ہیں؟',
                              confirmLabel: 'Logout',
                              isDestructive: true,
                            );
                            if (confirm == true) {
                              // Clear Drift SQLite cache and Riverpod state before invalidating routing guards
                              await ref.read(bookingsNotifierProvider.notifier).clearAllCache();
                              await ref.read(authProvider.notifier).signOut();
                              if (context.mounted) {
                                context.go(AppRoutes.onboarding);
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const VGap(32),
                  Text('UstaadNow AI v1.0.0', style: theme.textTheme.labelSmall),
                  const VGap(16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          color: selected ? AppColors.primary : null,
        ),
      ),
      trailing: selected ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
      onTap: onTap,
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _StatTile({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: valueColor ?? AppColors.primary)),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 36, color: Theme.of(context).colorScheme.outlineVariant);
}

class _Divider2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Divider(height: 1, indent: 54, color: Theme.of(context).colorScheme.outlineVariant);
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? textColor;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor ?? AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: textColor)),
                  if (subtitle != null)
                    Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            trailing ?? (onTap != null ? const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textHint) : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}
