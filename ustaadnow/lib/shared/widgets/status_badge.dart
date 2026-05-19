import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../shared/models/booking_model.dart';

class StatusBadge extends StatelessWidget {
  final BookingStatus status;
  final bool compact;

  const StatusBadge({super.key, required this.status, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(status);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppDimensions.sm : AppDimensions.md,
        vertical: compact ? 3 : AppDimensions.xs,
      ),
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: config.dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: config.textColor,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getConfig(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return _StatusConfig(
          bgColor: AppColors.statusPending.withOpacity(0.12),
          dotColor: AppColors.statusPending,
          textColor: AppColors.statusPending,
        );
      case BookingStatus.confirmed:
        return _StatusConfig(
          bgColor: AppColors.statusConfirmed.withOpacity(0.12),
          dotColor: AppColors.statusConfirmed,
          textColor: AppColors.statusConfirmed,
        );
      case BookingStatus.inProgress:
        return _StatusConfig(
          bgColor: AppColors.statusInProgress.withOpacity(0.12),
          dotColor: AppColors.statusInProgress,
          textColor: AppColors.statusInProgress,
        );
      case BookingStatus.completed:
        return _StatusConfig(
          bgColor: AppColors.statusCompleted.withOpacity(0.12),
          dotColor: AppColors.statusCompleted,
          textColor: AppColors.statusCompleted,
        );
      case BookingStatus.cancelled:
        return _StatusConfig(
          bgColor: AppColors.statusCancelled.withOpacity(0.12),
          dotColor: AppColors.statusCancelled,
          textColor: AppColors.statusCancelled,
        );
    }
  }
}

class _StatusConfig {
  final Color bgColor;
  final Color dotColor;
  final Color textColor;
  const _StatusConfig({
    required this.bgColor,
    required this.dotColor,
    required this.textColor,
  });
}
