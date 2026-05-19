import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SuggestionChips extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onTap;

  const SuggestionChips({super.key, required this.suggestions, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Suggestions:',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((s) => _Chip(label: s, onTap: () => onTap(s))).toList(),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceVariantDark : AppColors.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.2),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primary),
        ),
      ),
    );
  }
}
