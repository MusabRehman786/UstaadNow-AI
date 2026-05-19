import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../shared/models/booking_model.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/app_cards.dart';
import '../../../../shared/widgets/app_ui_helpers.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../auth/data/auth_provider.dart';
import '../../../booking/data/repositories/booking_repository.dart';

class ProviderHomeScreen extends ConsumerStatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  ConsumerState<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends ConsumerState<ProviderHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final userName = currentUser?.name ?? 'Ustaad';

    final bookingsState = ref.watch(bookingsNotifierProvider);
    final bookings = bookingsState.value ?? [];
    final completedCount = bookings.where((b) => b.status == BookingStatus.completed).length;
    double earnings = 0;
    for (final b in bookings) {
      if (b.status == BookingStatus.completed) {
        earnings += (b.estimatedCost ?? 0);
      }
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.primaryDark,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.pagePadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.white24,
                              child: Text(
                                userName.isNotEmpty ? userName.substring(0, 1) : 'U',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                userName,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() => _isOnline = !_isOnline);
                                ref.read(authProvider.notifier).updateAvailability(_isOnline);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(_isOnline ? 0.95 : 0.15),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8, height: 8,
                                      decoration: BoxDecoration(
                                        color: _isOnline ? AppColors.success : Colors.white54,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _isOnline ? 'Online' : 'Offline',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: _isOnline ? AppColors.primaryDark : Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const _QuickStat(label: 'Rating', value: '5.0★'),
                            const SizedBox(width: 24),
                            _QuickStat(label: 'Jobs Done', value: '$completedCount'),
                            const SizedBox(width: 24),
                            _QuickStat(label: 'Earnings', value: '₨ ${earnings.toInt()}'),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              tabs: const [Tab(text: 'New Jobs'), Tab(text: 'Active'), Tab(text: 'Completed')],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _JobsList(status: BookingStatus.pending),
            _JobsList(status: BookingStatus.inProgress),
            _JobsList(status: BookingStatus.completed),
          ],
        ),
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String label;
  final String value;
  const _QuickStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

class _JobsList extends ConsumerWidget {
  final BookingStatus status;
  const _JobsList({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsState = ref.watch(bookingsNotifierProvider);
    final bookings = bookingsState.value ?? [];
    final jobs = bookings.where((b) => b.status == status).toList();

    if (jobs.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.work_outline_rounded,
        title: 'No ${status.label} jobs',
        subtitle: 'Jobs will appear here when available',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.pagePadding),
      itemCount: jobs.length,
      separatorBuilder: (_, __) => const VGap(12),
      itemBuilder: (context, i) => _ProviderJobCard(booking: jobs[i]),
    );
  }
}

class _ProviderJobCard extends StatelessWidget {
  final BookingModel booking;
  const _ProviderJobCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isNew = booking.status == BookingStatus.pending;

    return AppCard(
      hasShadow: isNew,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.build_circle_rounded, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.serviceType, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    Text(booking.customerName, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              StatusBadge(status: booking.status, compact: true),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 15, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Expanded(child: Text(booking.location, style: theme.textTheme.bodySmall)),
              Text('₨ ${booking.estimatedCost?.toInt() ?? "TBD"}',
                  style: theme.textTheme.titleSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
            ],
          ),
          if (isNew) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: AppOutlinedButton(label: 'Reject', height: 40, borderColor: AppColors.error, textColor: AppColors.error, onPressed: () {})),
                const HGap(10),
                Expanded(child: AppPrimaryButton(label: 'Accept', height: 40, onPressed: () => context.push('/job/${booking.id}'))),
              ],
            ),
          ] else ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.push('/job/${booking.id}'),
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 38)),
                child: const Text('View Details'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
