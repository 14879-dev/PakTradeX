enum OrderSide { buy, sell }

enum OrderType { market, limit }

enum OrderStatus { executed, pending, cancelled }

class TradeOrder {
  final String id;
  final String symbol;
  final String stockName;
  final OrderSide side;
  final OrderType type;
  final int quantity;
  final double price; // Execution price or target limit price
  final double totalValue;
  final double fee; // Brokerage fee (e.g. 0.15% or min 50 PKR)
  final OrderStatus status;
  final DateTime createdAt;

  const TradeOrder({
    required this.id,
    required this.symbol,
    required this.stockName,
    required this.side,
    required this.type,
    required this.quantity,
    required this.price,
    required this.totalValue,
    required this.fee,
    required this.status,
    required this.createdAt,
  });
}

class HoldingPosition {
  final String symbol;
  final String name;
  final String sector;
  final int shares;
  final double avgBuyPrice;
  final double currentPrice;

  const HoldingPosition({
    required this.symbol,
    required this.name,
    required this.sector,
    required this.shares,
    required this.avgBuyPrice,
    required this.currentPrice,
  });

  double get totalCurrentValue => shares * currentPrice;
  double get totalInvested => shares * avgBuyPrice;
  double get unrealizedPnl => totalCurrentValue - totalInvested;
  double get pnlPercentage => totalInvested > 0 ? (unrealizedPnl / totalInvested) * 100 : 0.0;

  HoldingPosition copyWith({
    String? symbol,
    String? name,
    String? sector,
    int? shares,
    double? avgBuyPrice,
    double? currentPrice,
  }) {
    return HoldingPosition(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      sector: sector ?? this.sector,
      shares: shares ?? this.shares,
      avgBuyPrice: avgBuyPrice ?? this.avgBuyPrice,
      currentPrice: currentPrice ?? this.currentPrice,
    );
  }
}

class OrderBookLevel {
  final double price;
  final int volume;
  final int ordersCount;

  const OrderBookLevel({
    required this.price,
    required this.volume,
    required this.ordersCount,
  });
}

class MarketDepth {
  final List<OrderBookLevel> bids; // Buyers (highest to lowest)
  final List<OrderBookLevel> asks; // Sellers (lowest to highest)

  const MarketDepth({
    required this.bids,
    required this.asks,
  });
}
