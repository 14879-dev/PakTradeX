/// Global Application Configuration for PakTradeX
abstract class AppConfig {
  static const String appName = 'PakTradeX';
  static const String appTagline = 'Invest Smarter. Trade Simpler.';
  static const String appVersion = '1.0.0';
  static const String currency = 'PKR';
  static const String currencySymbol = 'Rs.';
  static const bool isDemoMode = true;

  // Backend Gateway
  static const String apiBaseUrl = 'http://localhost:8000/api/v1';

  // Fee & Trading Constants (PSX Aligned)
  static const double standardBrokerageFeePercent = 0.0015; // 0.15%
  static const double minBrokerageFee = 25.0; // 25 PKR minimum
  static const double maxBrokerageFee = 500.0; // 500 PKR cap

  // Regulatory Disclosures
  static const String legalDisclaimer =
      'PakTradeX is a simulated learning and research platform for the Pakistan Stock Exchange (PSX). '
      'All market quotes, orders, and portfolio metrics are for educational simulation purposes only.';
}
