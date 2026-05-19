import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../shared/models/booking_model.dart';
import '../../../../shared/widgets/app_cards.dart';
import '../../../../shared/widgets/app_ui_helpers.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../booking/data/repositories/booking_repository.dart';
import '../../../chatbot/presentation/screens/chat_screen.dart';

class UserHomeScreen extends ConsumerWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bookingsState = ref.watch(bookingsNotifierProvider);
    final bookings = bookingsState.value ?? [];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.pagePadding),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const VGap(20),
                _buildAIChatBanner(context),
                const VGap(24),
                _buildQuickServices(context),
                const VGap(24),
                SectionHeader(
                  title: 'Recent Bookings',
                  action: 'See all',
                  onAction: () => context.go(AppRoutes.bookingHistory),
                ),
                const VGap(12),
                _buildRecentBookings(context, bookings),
                const VGap(24),
                _buildStatsRow(context, bookings),
                const VGap(32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: AppColors.primaryDark,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      title: Row(
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text('U', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
            ),
          ),
          const SizedBox(width: 10),
          const Text('UstaadNow', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.white)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () => context.push(AppRoutes.notifications),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildAIChatBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text('AI Powered', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your City, You Ustaad, Book Now',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700, height: 1.2),
                ),
                const SizedBox(height: 6),
                Text(
                  'Just type in Urdu, Roman Urdu or English',
                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // AI icon illustration
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.smart_toy_rounded, size: 40, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickServices(BuildContext context) {
    final services = [
      _Service('AC Technician', Icons.ac_unit_rounded, const Color(0xFF2563EB)),
      _Service('Plumber', Icons.water_drop_rounded, const Color(0xFF0891B2)),
      _Service('Electrician', Icons.bolt_rounded, const Color(0xFFF59E0B)),
      _Service('Carpenter', Icons.handyman_rounded, const Color(0xFF92400E)),
      _Service('Painter', Icons.format_paint_rounded, const Color(0xFFDB2777)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Quick Book'),
        const VGap(12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemCount: services.length,
          itemBuilder: (context, i) => _ServiceChip(service: services[i]),
        ),
      ],
    );
  }

  Widget _buildRecentBookings(BuildContext context, List<BookingModel> bookings) {
    final recent = bookings.take(2).toList();
    if (recent.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.receipt_long_rounded,
        title: 'No bookings yet',
        subtitle: 'Start a chat to book your first service',
      );
    }
    return Column(
      children: recent.map((b) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _BookingCard(booking: b),
      )).toList(),
    );
  }

  Widget _buildStatsRow(BuildContext context, List<BookingModel> bookings) {
    final total = bookings.length;
    final completed = bookings.where((b) => b.status == BookingStatus.completed).length;
    final pending = bookings.where((b) => b.status == BookingStatus.pending).length;
    final inProgress = bookings.where((b) => b.status == BookingStatus.inProgress || b.status == BookingStatus.confirmed).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Overview'),
        const VGap(12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Total Bookings',
                value: '$total',
                icon: Icons.receipt_long_rounded,
                color: AppColors.primary,
              ),
            ),
            const HGap(12),
            Expanded(
              child: _StatCard(
                label: 'Completed',
                value: '$completed',
                icon: Icons.check_circle_rounded,
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const VGap(12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Pending',
                value: '$pending',
                icon: Icons.hourglass_empty_rounded,
                color: AppColors.warning,
              ),
            ),
            const HGap(12),
            Expanded(
              child: _StatCard(
                label: 'In Progress',
                value: '$inProgress',
                icon: Icons.play_circle_outline_rounded,
                color: AppColors.info,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Service {
  final String name;
  final IconData icon;
  final Color color;
  const _Service(this.name, this.icon, this.color);
}

class _ServiceChip extends ConsumerWidget {
  final _Service service;
  const _ServiceChip({required this.service});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        context.go(AppRoutes.chat);
        Future.delayed(const Duration(milliseconds: 300), () {
          ref.read(chatMessagesProvider.notifier).sendMessage('${service.name} chahiye');
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: service.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(service.icon, color: service.color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              service.name,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: () => context.push('/booking/${booking.id}'),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.build_circle_rounded, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(booking.serviceType, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(booking.location, style: theme.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          StatusBadge(status: booking.status, compact: true),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
