import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';

class InteractiveStockChart extends StatefulWidget {
  final String symbol;
  final double currentPrice;
  final double changePercent;

  const InteractiveStockChart({
    super.key,
    required this.symbol,
    required this.currentPrice,
    required this.changePercent,
  });

  @override
  State<InteractiveStockChart> createState() => _InteractiveStockChartState();
}

class _InteractiveStockChartState extends State<InteractiveStockChart> {
  String _selectedTimeframe = '1D';

  final List<String> _timeframes = ['1D', '1W', '1M', '3M', '1Y', 'ALL'];

  // Simulated price history per timeframe
  Map<String, List<double>> get _priceData {
    final base = widget.currentPrice;
    return {
      '1D': [
        base * 0.988, base * 0.991, base * 0.994, base * 0.992,
        base * 0.996, base * 0.998, base * 1.002, base * 1.006,
        base * 1.004, base * 1.007, base * 1.009, base
      ],
      '1W': [
        base * 0.965, base * 0.971, base * 0.979, base * 0.975,
        base * 0.982, base * 0.991, base
      ],
      '1M': [
        base * 0.940, base * 0.945, base * 0.951, base * 0.948,
        base * 0.957, base * 0.961, base * 0.968, base * 0.972,
        base * 0.980, base * 0.985, base * 0.991, base
      ],
      '3M': [
        base * 0.910, base * 0.920, base * 0.915, base * 0.930,
        base * 0.940, base * 0.950, base * 0.960, base * 0.970, base
      ],
      '1Y': [
        base * 0.780, base * 0.820, base * 0.810, base * 0.840,
        base * 0.870, base * 0.890, base * 0.910, base * 0.940,
        base * 0.960, base * 0.970, base * 0.985, base
      ],
      'ALL': [
        base * 0.550, base * 0.600, base * 0.620, base * 0.660,
        base * 0.700, base * 0.740, base * 0.780, base * 0.820,
        base * 0.860, base * 0.900, base * 0.940, base * 0.970, base
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = widget.changePercent >= 0;
    final chartColor = isPositive ? AppColors.success : AppColors.danger;
    final prices = _priceData[_selectedTimeframe] ?? [];
    final minY = prices.reduce((a, b) => a < b ? a : b) * 0.999;
    final maxY = prices.reduce((a, b) => a > b ? a : b) * 1.001;

    final spots = prices.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chart Container
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.roundedMd,
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.only(top: 12, right: 8, bottom: 4),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: (maxY - minY) / 4,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: AppColors.borderSubtle,
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 56,
                    getTitlesWidget: (value, meta) => Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(
                        value.toStringAsFixed(0),
                        style: AppTypography.labelSmall.copyWith(fontSize: 9),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              minY: minY,
              maxY: maxY,
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => AppColors.navy,
                  tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
                    return LineTooltipItem(
                      'Rs. ${spot.y.toStringAsFixed(2)}',
                      AppTypography.financialSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  }).toList(),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: chartColor,
                  barWidth: 2.2,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        chartColor.withValues(alpha: 0.18),
                        chartColor.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Timeframe Selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _timeframes.map((tf) {
            final isSelected = _selectedTimeframe == tf;
            return GestureDetector(
              onTap: () => setState(() => _selectedTimeframe = tf),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: AppRadius.roundedSm,
                ),
                child: Text(
                  tf,
                  style: AppTypography.labelSmall.copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
