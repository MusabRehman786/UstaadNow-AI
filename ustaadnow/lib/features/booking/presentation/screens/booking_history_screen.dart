import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../shared/models/booking_model.dart';
import '../../../../shared/widgets/app_ui_helpers.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/app_cards.dart';
import '../../data/repositories/booking_repository.dart';

class BookingHistoryScreen extends ConsumerStatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  ConsumerState<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends ConsumerState<BookingHistoryScreen> {
  BookingStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final bookingsState = ref.watch(bookingsNotifierProvider);
    final all = bookingsState.value ?? [];
    final filtered = _filter == null ? all : all.where((b) => b.status == _filter).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 48,
        title: const Text('My Bookings', style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildFilters(),
          Expanded(
            child: bookingsState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (_) => filtered.isEmpty
                  ? const EmptyStateWidget(
                      icon: Icons.receipt_long_rounded,
                      title: 'No bookings found',
                      subtitle: 'Try a different filter or start a new booking',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppDimensions.pagePadding),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const VGap(12),
                      itemBuilder: (ctx, i) => _BookingHistoryCard(booking: filtered[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final filters = [null, ...BookingStatus.values];
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.pagePadding),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final f = filters[i];
          final isSelected = _filter == f;
          return GestureDetector(
            onTap: () => setState(() => _filter = f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Text(
                f == null ? 'All' : f.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BookingHistoryCard extends StatefulWidget {
  final BookingModel booking;
  const _BookingHistoryCard({required this.booking});

  @override
  State<_BookingHistoryCard> createState() => _BookingHistoryCardState();
}

class _BookingHistoryCardState extends State<_BookingHistoryCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final booking = widget.booking;

    return AppCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
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
                        Text(
                          booking.serviceType,
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'ID: ${booking.id}',
                          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textHint),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StatusBadge(status: booking.status),
                      const SizedBox(width: 6),
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 22,
                          color: AppColors.primary.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _Detail(icon: Icons.location_on_outlined, label: booking.location),
                  ),
                  if (booking.estimatedCost != null)
                    _Detail(icon: Icons.payments_outlined, label: '₨ ${booking.estimatedCost!.toInt()}'),
                ],
              ),
              const SizedBox(height: 6),
              _Detail(
                icon: Icons.access_time_rounded,
                label: _formatDate(booking.createdAt),
              ),

              // Expandable body
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 280),
                crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                firstChild: const SizedBox.shrink(),
                secondChild: _buildExpandedBody(context, theme, isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedBody(BuildContext context, ThemeData theme, bool isDark) {
    final booking = widget.booking;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 12),
        
        // Description Section
        if (booking.description.isNotEmpty) ...[
          Text(
            'Request Description',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            booking.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Assigned Provider Section
        Text(
          'Assigned Provider',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        if (booking.assignedProvider != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? theme.colorScheme.surfaceContainer : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      booking.assignedProvider!.name.isNotEmpty ? booking.assignedProvider!.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.assignedProvider!.name,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFC107)),
                          const SizedBox(width: 4),
                          Text(
                            '${booking.assignedProvider!.rating} (${booking.assignedProvider!.totalJobs} jobs)',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  icon: const Icon(Icons.phone_rounded, size: 18),
                  onPressed: () async {
                    final phone = booking.assignedProvider!.phone;
                    final Uri launchUri = Uri(
                      scheme: 'tel',
                      path: phone,
                    );
                    try {
                      if (await canLaunchUrl(launchUri)) {
                        await launchUrl(launchUri);
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Could not launch dialer for $phone')),
                          );
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    booking.status == BookingStatus.pending
                        ? 'Finding matching ustaad...'
                        : 'Provider assignment in progress...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        
        const SizedBox(height: 16),
        
        // Actions Section
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: () => context.push('/booking/${booking.id}'),
                icon: const Icon(Icons.visibility_rounded, size: 16),
                label: const Text(
                  'View Track Status',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${months[dt.month - 1]}, ${dt.year}';
  }
}

class _Detail extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Detail({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
