import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../trading/models/trading_models.dart';

class SectorAllocationPieChart extends StatefulWidget {
  final List<HoldingPosition> holdings;
  final double availableCash;

  const SectorAllocationPieChart({
    super.key,
    required this.holdings,
    required this.availableCash,
  });

  @override
  State<SectorAllocationPieChart> createState() => _SectorAllocationPieChartState();
}

class _SectorAllocationPieChartState extends State<SectorAllocationPieChart> {
  int _touchedIndex = -1;

  final List<Color> _sectorColors = [
    const Color(0xFF1E3A8A), // Navy
    const Color(0xFF0D9488), // Teal
    const Color(0xFFD97706), // Amber
    const Color(0xFF7C3AED), // Purple
    const Color(0xFF0284C7), // Sky Blue
    const Color(0xFFE11D48), // Rose
  ];

  Map<String, double> _getSectorBreakdown() {
    final map = <String, double>{};
    for (final h in widget.holdings) {
      final current = map[h.sector] ?? 0.0;
      map[h.sector] = current + h.totalCurrentValue;
    }
    if (widget.availableCash > 0) {
      map['Cash (PKR)'] = widget.availableCash;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final breakdown = _getSectorBreakdown();
    if (breakdown.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalVal = breakdown.values.fold(0.0, (a, b) => a + b);
    final entries = breakdown.entries.toList();

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 42,
              sections: List.generate(entries.length, (i) {
                final isTouched = i == _touchedIndex;
                final fontSize = isTouched ? 14.0 : 11.0;
                final radius = isTouched ? 48.0 : 42.0;
                final percent = totalVal > 0 ? (entries[i].value / totalVal) * 100 : 0.0;
                final color = _sectorColors[i % _sectorColors.length];

                return PieChartSectionData(
                  color: color,
                  value: entries[i].value,
                  title: '${percent.toStringAsFixed(0)}%',
                  radius: radius,
                  titleStyle: AppTypography.labelSmall.copyWith(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Legend Wrap
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: List.generate(entries.length, (i) {
            final percent = totalVal > 0 ? (entries[i].value / totalVal) * 100 : 0.0;
            final color = _sectorColors[i % _sectorColors.length];
            final isHighlighted = _touchedIndex == i;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${entries[i].key} (${percent.toStringAsFixed(1)}%)',
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w500,
                    color: isHighlighted ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}
