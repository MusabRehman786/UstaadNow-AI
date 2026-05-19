import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../shared/models/booking_model.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/app_cards.dart';
import '../../../../shared/widgets/app_ui_helpers.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final BookingModel? booking;
  const BookingConfirmationScreen({super.key, this.booking});

  @override
  Widget build(BuildContext context) {
    final b = booking ?? BookingModel.mockList.first;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.pagePadding),
          child: Column(
            children: [
              const Spacer(),
              // Success animation
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (_, v, child) => Transform.scale(scale: v, child: child),
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 30)],
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 50),
                ),
              ),
              const VGap(24),
              Text('Booking Confirmed!', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
              const VGap(8),
              Text(
                'Your booking has been confirmed and the provider has been notified.',
                style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const VGap(32),
              AppCard(
                child: Column(
                  children: [
                    _Row('Service', b.serviceType),
                    const Divider(height: 16),
                    _Row('Provider', b.assignedProvider?.name ?? 'Being assigned...'),
                    const Divider(height: 16),
                    _Row('Location', b.location),
                    const Divider(height: 16),
                    _Row('Estimated Cost', b.estimatedCost != null ? '₨ ${b.estimatedCost!.toInt()}' : 'TBD'),
                    const Divider(height: 16),
                    _Row('Booking ID', b.id, valueColor: AppColors.primary),
                  ],
                ),
              ),
              const Spacer(),
              AppGradientButton(
                label: 'Track Booking',
                icon: Icons.my_location_rounded,
                onPressed: () => context.go('/booking/${b.id}'),
              ),
              const VGap(12),
              AppOutlinedButton(
                label: 'Back to Home',
                onPressed: () => context.go(AppRoutes.userHome),
              ),
              const VGap(16),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _Row(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
        Flexible(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
