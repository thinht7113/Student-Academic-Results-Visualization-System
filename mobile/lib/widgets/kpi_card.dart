import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final Color? color;
  final IconData? icon;
  final LinearGradient? gradient;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    this.color,
    this.icon,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: gradient == null ? context.cardColor : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.cardShadow,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (gradient != null
                    ? Colors.white24
                    : (color ?? AppTheme.primaryColor).withValues(alpha: 0.1)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: gradient != null
                    ? Colors.white
                    : (color ?? AppTheme.primaryColor),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            title,
            style: AppTheme.caption.copyWith(
              color: gradient != null ? Colors.white70 : context.textMuted,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTheme.kpiValue.copyWith(
              color: gradient != null
                  ? Colors.white
                  : (color ?? context.textPrimary),
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }
}
