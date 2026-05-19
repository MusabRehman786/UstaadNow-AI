import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../shared/models/booking_model.dart';
import '../../../../shared/models/trace_log_model.dart';
import '../../../../shared/widgets/app_cards.dart';
import '../../../../shared/widgets/app_ui_helpers.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../data/repositories/booking_repository.dart';

class BookingDetailScreen extends ConsumerWidget {
  final String bookingId;
  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsState = ref.watch(bookingsNotifierProvider);
    final bookings = bookingsState.value ?? [];
    final booking = bookings.firstWhere(
      (b) => b.id == bookingId,
      orElse: () => BookingModel(
        id: bookingId,
        serviceType: 'AC Service / اے سی سروس',
        description: 'Full servicing and gas check',
        customerName: 'Muhammad Ali',
        customerPhone: '0300-1234567',
        location: 'Islamabad, Pakistan',
        status: BookingStatus.confirmed,
        estimatedCost: 3500.0,
        scheduledAt: DateTime.now(),
        createdAt: DateTime.now(),
      ),
    );
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        title: Text('Booking ${booking.id}', style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status card
            GradientCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusBadge(status: booking.status),
                  const SizedBox(height: 12),
                  Text(booking.serviceType, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(booking.description, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _GradientDetail(icon: Icons.location_on_outlined, label: booking.location),
                      const SizedBox(width: 20),
                      _GradientDetail(icon: Icons.schedule_rounded, label: _formatDate(booking.scheduledAt)),
                    ],
                  ),
                ],
              ),
            ),
            const VGap(20),

            // Provider info
            if (booking.assignedProvider != null) ...[
              const SectionHeader(title: 'Assigned Provider'),
              const VGap(12),
              AppCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.primary.withOpacity(0.15),
                      child: Text(
                        booking.assignedProvider!.name.substring(0, 1),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(booking.assignedProvider!.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                          Text(booking.assignedProvider!.serviceType, style: theme.textTheme.bodySmall),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 14, color: AppColors.accent),
                              const SizedBox(width: 3),
                              Text('${booking.assignedProvider!.rating}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                              const SizedBox(width: 6),
                              Text('• ${booking.assignedProvider!.totalJobs} jobs', style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.phone_rounded, color: AppColors.primary),
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
              const VGap(20),
            ],

            // Booking details
            const SectionHeader(title: 'Booking Details'),
            const VGap(12),
            AppCard(
              child: Column(
                children: [
                  InfoTile(icon: Icons.person_outline_rounded, label: 'Customer', value: booking.customerName),
                  const Divider(height: 20),
                  InfoTile(icon: Icons.phone_outlined, label: 'Phone', value: booking.customerPhone),
                  const Divider(height: 20),
                  InfoTile(icon: Icons.location_on_outlined, label: 'Location', value: booking.location),
                  const Divider(height: 20),
                  InfoTile(
                    icon: Icons.payments_outlined,
                    label: 'Estimated Cost',
                    value: booking.estimatedCost != null ? '₨ ${booking.estimatedCost!.toInt()}' : 'TBD',
                    iconColor: AppColors.success,
                  ),
                  if (booking.originalRequest != null) ...[
                    const Divider(height: 20),
                    InfoTile(icon: Icons.chat_bubble_outline_rounded, label: 'Original Request', value: '"${booking.originalRequest!}"'),
                  ],
                ],
              ),
            ),
            const VGap(20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error.withOpacity(0.1),
                  foregroundColor: AppColors.error,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  await ref.read(bookingsNotifierProvider.notifier).cancelBooking(bookingId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Booking is cancelled'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                    Navigator.of(context).pop();
                  }
                },
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancel Booking', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const VGap(32),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final p = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.day} ${months[dt.month - 1]} • $h:$m $p';
  }
}

class _GradientDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  const _GradientDetail({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white70),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}

class _TraceTimeline extends StatelessWidget {
  final List<TraceStep> steps;
  const _TraceTimeline({required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(steps.length, (i) {
        final step = steps[i];
        final isLast = i == steps.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: step.success ? AppColors.success.withOpacity(0.15) : AppColors.error.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        step.success ? Icons.check_rounded : Icons.close_rounded,
                        size: 14,
                        color: step.success ? AppColors.success : AppColors.error,
                      ),
                    ),
                    if (!isLast)
                      Expanded(child: Container(width: 2, color: AppColors.border, margin: const EdgeInsets.symmetric(vertical: 2))),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(step.agentName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                          const Spacer(),
                          Text('${step.duration.inMilliseconds}ms',
                              style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(step.result, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
