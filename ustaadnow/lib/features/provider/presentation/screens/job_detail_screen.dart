import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../shared/models/booking_model.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/app_cards.dart';
import '../../../../shared/widgets/app_ui_helpers.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../booking/data/repositories/booking_repository.dart';

class JobDetailScreen extends ConsumerStatefulWidget {
  final String jobId;
  const JobDetailScreen({super.key, required this.jobId});

  @override
  ConsumerState<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends ConsumerState<JobDetailScreen> {
  final List<_StatusStep> _steps = const [
    _StatusStep(BookingStatus.confirmed, 'Accepted', Icons.check_circle_outline_rounded),
    _StatusStep(BookingStatus.inProgress, 'In Progress', Icons.construction_rounded),
    _StatusStep(BookingStatus.completed, 'Completed', Icons.verified_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final bookingsState = ref.watch(bookingsNotifierProvider);
    final bookings = bookingsState.value ?? [];
    final booking = bookings.firstWhere(
      (b) => b.id == widget.jobId,
      orElse: () => BookingModel(
        id: widget.jobId,
        serviceType: 'AC Service / اے سی سروس',
        description: 'AC Servicing by Provider',
        customerName: 'Muhammad Ali',
        customerPhone: '0300-1234567',
        location: 'Islamabad, Pakistan',
        status: BookingStatus.confirmed,
        estimatedCost: 3500.0,
        scheduledAt: DateTime.now(),
        createdAt: DateTime.now(),
      ),
    );

    final currentStatus = booking.status;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_rounded, color: AppColors.primary),
            onPressed: () async {
              final phone = booking.customerPhone;
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job header card
            GradientCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusBadge(status: currentStatus),
                  const SizedBox(height: 12),
                  Text(booking.serviceType,
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(booking.description,
                      style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
                  const SizedBox(height: 16),
                  Row(children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(booking.location, style: const TextStyle(color: Colors.white, fontSize: 12)),
                    const Spacer(),
                    Text('₨ ${booking.estimatedCost?.toInt() ?? "TBD"}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                  ]),
                ],
              ),
            ),
            const VGap(20),

            // Customer info
            const SectionHeader(title: 'Customer'),
            const VGap(12),
            AppCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.accent.withOpacity(0.2),
                    child: Text(booking.customerName.isNotEmpty ? booking.customerName.substring(0, 1) : 'U',
                        style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.accent, fontSize: 18)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(booking.customerName, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                        Text(booking.customerPhone, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.message_outlined, color: AppColors.success, size: 18),
                  ),
                ],
              ),
            ),
            const VGap(20),

            // Progress tracker
            const SectionHeader(title: 'Job Progress'),
            const VGap(12),
            AppCard(
              child: Column(
                children: _steps.map((step) {
                  final stepIndex = _steps.indexOf(step);
                  final currentIndex = _steps.indexWhere((s) => s.status == currentStatus);
                  final isDone = stepIndex < currentIndex;
                  final isCurrent = stepIndex == currentIndex;
                  final isLast = stepIndex == _steps.length - 1;

                  return Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: isDone || isCurrent ? AppColors.primary : AppColors.surfaceVariant,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isDone ? Icons.check_rounded : step.icon,
                              size: 18,
                              color: isDone || isCurrent ? Colors.white : AppColors.textHint,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            step.label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                              color: isCurrent ? AppColors.primary : null,
                            ),
                          ),
                          const Spacer(),
                          if (isCurrent)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: const Text('Current', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
                            ),
                        ],
                      ),
                      if (!isLast)
                        Padding(
                          padding: const EdgeInsets.only(left: 17),
                          child: Container(height: 20, width: 2, color: isDone ? AppColors.primary : AppColors.border),
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
            const VGap(24),

            // Status update buttons - wired directly to Drift database and backend patching
            const SectionHeader(title: 'Update Status'),
            const VGap(12),
            Row(
              children: [
                if (currentStatus == BookingStatus.confirmed)
                  Expanded(
                    child: AppPrimaryButton(
                      label: 'Start Job',
                      icon: Icons.play_arrow_rounded,
                      onPressed: () => ref.read(bookingsNotifierProvider.notifier).updateBookingStatus(widget.jobId, BookingStatus.inProgress),
                    ),
                  ),
                if (currentStatus == BookingStatus.inProgress)
                  Expanded(
                    child: AppPrimaryButton(
                      label: 'Mark Completed',
                      icon: Icons.check_rounded,
                      backgroundColor: AppColors.success,
                      onPressed: () => ref.read(bookingsNotifierProvider.notifier).updateBookingStatus(widget.jobId, BookingStatus.completed),
                    ),
                  ),
                if (currentStatus == BookingStatus.completed)
                  Expanded(
                    child: AppCard(
                      backgroundColor: AppColors.success.withOpacity(0.08),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.verified_rounded, color: AppColors.success),
                          const SizedBox(width: 8),
                          Text('Job Completed!', style: theme.textTheme.titleSmall?.copyWith(color: AppColors.success, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const VGap(32),
          ],
        ),
      ),
    );
  }
}

class _StatusStep {
  final BookingStatus status;
  final String label;
  final IconData icon;
  const _StatusStep(this.status, this.label, this.icon);
}
