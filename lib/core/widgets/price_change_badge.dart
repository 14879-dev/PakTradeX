import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';

/// Pill badge showing positive/negative price movement.
/// Accessible: Uses both color and explicit +/- sign.
class PriceChangeBadge extends StatelessWidget {
  final double changePercent;
  final double? changeAmount;
  final bool isCompact;

  const PriceChangeBadge({
    super.key,
    required this.changePercent,
    this.changeAmount,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = changePercent >= 0;
    final bgColor = isPositive ? AppColors.successLight : AppColors.dangerLight;
    final textColor = isPositive ? AppColors.success : AppColors.danger;
    final prefix = isPositive ? '+' : '';

    String text;
    if (changeAmount != null && !isCompact) {
      text = '$prefix${changeAmount!.toStringAsFixed(2)} ($prefix${changePercent.toStringAsFixed(2)}%)';
    } else {
      text = '$prefix${changePercent.toStringAsFixed(2)}%';
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 6.0 : 8.0,
        vertical: isCompact ? 2.0 : 4.0,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.roundedSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            size: isCompact ? 14 : 16,
            color: textColor,
          ),
          Text(
            text,
            style: AppTypography.financialSmall.copyWith(
              color: textColor,
              fontSize: isCompact ? 11 : 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
