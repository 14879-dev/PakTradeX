import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../features/home/models/market_data_models.dart';
import '../models/trading_models.dart';
import '../providers/trading_provider.dart';

class OrderSheet extends ConsumerStatefulWidget {
  final StockQuote stock;
  final bool initialBuy;

  const OrderSheet({
    super.key,
    required this.stock,
    required this.initialBuy,
  });

  @override
  ConsumerState<OrderSheet> createState() => _OrderSheetState();
}

class _OrderSheetState extends ConsumerState<OrderSheet> {
  late bool _isBuy;
  OrderType _orderType = OrderType.market;
  final TextEditingController _qtyController = TextEditingController(text: '10');
  bool _isLoading = false;
  bool _orderSuccess = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _isBuy = widget.initialBuy;
  }

  double get _price => widget.stock.price;
  int get _quantity => int.tryParse(_qtyController.text) ?? 0;
  double get _totalValue => _quantity * _price;
  double get _fee => (_totalValue * 0.0015).clamp(25.0, 500.0);
  double get _grandTotal => _isBuy ? _totalValue + _fee : _totalValue - _fee;

  void _setQtyPercent(double percent) {
    final portfolio = ref.read(tradingProvider);
    if (_isBuy) {
      final maxShares = (portfolio.availableCash * percent / _price).floor();
      _qtyController.text = maxShares > 0 ? maxShares.toString() : '0';
    } else {
      final holding = portfolio.holdings.where((h) => h.symbol == widget.stock.symbol).firstOrNull;
      if (holding != null) {
        _qtyController.text = (holding.shares * percent).floor().toString();
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final portfolio = ref.watch(tradingProvider);
    final currency = NumberFormat('#,##0.00', 'en_US');
    final holding = portfolio.holdings
        .where((h) => h.symbol == widget.stock.symbol)
        .firstOrNull;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              if (_orderSuccess)
                _buildSuccessState(currency)
              else
                Expanded(
                  child: SingleChildScrollView(
                    controller: controller,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title & Symbol
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Place Order', style: AppTypography.titleLarge),
                                Text(
                                  '${widget.stock.symbol} · Rs. ${currency.format(_price)}',
                                  style: AppTypography.bodySmall,
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.warningLight,
                                borderRadius: AppRadius.roundedSm,
                              ),
                              child: Text(
                                'SIMULATED',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Buy / Sell Tab
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: AppRadius.roundedMd,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Expanded(child: _buildSideTab('Buy', true)),
                              Expanded(child: _buildSideTab('Sell', false)),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Order Type
                        Text('Order Type', style: AppTypography.labelMedium),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Expanded(child: _buildOrderTypeButton('Market Order', OrderType.market, 'Instant execution at current price')),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(child: _buildOrderTypeButton('Limit Order', OrderType.limit, 'Set your target price')),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Quantity input
                        Text('Quantity (Shares)', style: AppTypography.labelMedium),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _qtyController,
                                keyboardType: TextInputType.number,
                                onChanged: (_) => setState(() {}),
                                style: AppTypography.financialLarge.copyWith(fontSize: 20),
                                decoration: InputDecoration(
                                  hintText: '0',
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  filled: true,
                                  fillColor: AppColors.background,
                                  border: OutlineInputBorder(
                                    borderRadius: AppRadius.roundedMd,
                                    borderSide: const BorderSide(color: AppColors.border),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),

                        // Quick percentage buttons
                        Row(
                          children: ['25%', '50%', '75%', 'Max'].asMap().entries.map((e) {
                            final percents = [0.25, 0.50, 0.75, 1.0];
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(right: e.key < 3 ? 6.0 : 0),
                                child: OutlinedButton(
                                  onPressed: () => _setQtyPercent(percents[e.key]),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 7),
                                    side: const BorderSide(color: AppColors.border),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: AppRadius.roundedSm,
                                    ),
                                  ),
                                  child: Text(
                                    e.value,
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Order Summary Box
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: AppRadius.roundedMd,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              _buildSummaryRow('Quantity', '$_quantity shares'),
                              const Divider(height: 16),
                              _buildSummaryRow('Price per Share', 'Rs. ${currency.format(_price)}'),
                              _buildSummaryRow('Subtotal', 'Rs. ${currency.format(_totalValue)}'),
                              _buildSummaryRow('Brokerage Fee (0.15%)', 'Rs. ${currency.format(_fee)}'),
                              const Divider(height: 16),
                              _buildSummaryRow(
                                _isBuy ? 'Total Cost' : 'Net Proceeds',
                                'Rs. ${currency.format(_grandTotal)}',
                                isBold: true,
                                valueColor: _isBuy ? AppColors.danger : AppColors.success,
                              ),
                              const SizedBox(height: 8),
                              _buildSummaryRow(
                                'Available Cash',
                                'Rs. ${currency.format(portfolio.availableCash)}',
                              ),
                              if (holding != null)
                                _buildSummaryRow(
                                  '${widget.stock.symbol} Holdings',
                                  '${holding.shares} shares',
                                ),
                            ],
                          ),
                        ),

                        // Error message
                        if (_errorMsg != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.dangerLight,
                              borderRadius: AppRadius.roundedSm,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: AppColors.danger, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMsg!,
                                    style: AppTypography.bodySmall.copyWith(color: AppColors.danger),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.xl),

                        // Place Order Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading || _quantity == 0 ? null : _placeOrder,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isBuy ? AppColors.success : AppColors.danger,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: const RoundedRectangleBorder(
                                borderRadius: AppRadius.roundedMd,
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Text(
                                    _isBuy
                                        ? 'Confirm Buy · Rs. ${currency.format(_grandTotal)}'
                                        : 'Confirm Sell · Rs. ${currency.format(_grandTotal)}',
                                    style: AppTypography.labelLarge.copyWith(color: Colors.white),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSideTab(String label, bool isBuy) {
    final isSelected = _isBuy == isBuy;
    return GestureDetector(
      onTap: () => setState(() {
        _isBuy = isBuy;
        _errorMsg = null;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? (isBuy ? AppColors.success : AppColors.danger)
              : Colors.transparent,
          borderRadius: AppRadius.roundedMd,
        ),
        child: Text(
          label,
          style: AppTypography.labelLarge.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderTypeButton(String label, OrderType type, String subtitle) {
    final isSelected = _orderType == type;
    return GestureDetector(
      onTap: () => setState(() => _orderType = type),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.background,
          borderRadius: AppRadius.roundedSm,
          border: Border.all(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.4) : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(subtitle, style: AppTypography.bodySmall.copyWith(fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySmall),
        Text(
          value,
          style: (isBold ? AppTypography.titleSmall : AppTypography.labelSmall).copyWith(
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState(NumberFormat currency) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: (_isBuy ? AppColors.success : AppColors.danger).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: _isBuy ? AppColors.success : AppColors.danger,
                size: 52,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              _isBuy ? 'Buy Order Executed!' : 'Sell Order Executed!',
              style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '$_quantity shares of ${widget.stock.symbol} at Rs. ${currency.format(_price)}\nTotal: Rs. ${currency.format(_grandTotal)}',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '⚠ This is a simulated demo trade. No real money transferred.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.warning),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxxl),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _placeOrder() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    await Future.delayed(const Duration(milliseconds: 700));

    String? error;
    if (_isBuy) {
      error = await ref.read(tradingProvider.notifier).placeBuyOrder(
            symbol: widget.stock.symbol,
            stockName: widget.stock.name,
            sector: widget.stock.sector,
            quantity: _quantity,
            price: _price,
            orderType: _orderType,
          );
    } else {
      error = await ref.read(tradingProvider.notifier).placeSellOrder(
            symbol: widget.stock.symbol,
            quantity: _quantity,
            price: _price,
            orderType: _orderType,
          );
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (error != null) {
        _errorMsg = error;
      } else {
        _orderSuccess = true;
      }
    });
  }
}
