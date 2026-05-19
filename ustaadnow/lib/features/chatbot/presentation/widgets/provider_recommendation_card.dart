import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/models/booking_model.dart';
import '../../../../shared/widgets/app_buttons.dart';

class ProviderRecommendationCard extends StatelessWidget {
  final ProviderSummary provider;
  final VoidCallback onConfirm;

  const ProviderRecommendationCard({
    super.key,
    required this.provider,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.08), blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 12, color: AppColors.primary),
                    SizedBox(width: 4),
                    Text('AI Recommended', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withOpacity(0.15),
                child: Text(
                  provider.name.substring(0, 1),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(provider.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    Text(provider.serviceType, style: theme.textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: AppColors.accent),
                        const SizedBox(width: 2),
                        Text('${provider.rating}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 6),
                        Text('• ${provider.totalJobs} jobs', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: AppOutlinedButton(label: 'See Others', height: 40, onPressed: () {})),
              const SizedBox(width: 10),
              Expanded(child: AppPrimaryButton(label: 'Confirm Booking', height: 40, onPressed: onConfirm)),
            ],
          ),
        ],
      ),
    );
  }
}
