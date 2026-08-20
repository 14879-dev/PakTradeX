/// Global Application Configuration for PakTradeX
abstract class AppConfig {
  static const String appName = 'PakTradeX';
  static const String appTagline = 'Invest Smarter. Trade Simpler.';
  static const String appVersion = '1.0.0';
  static const String currency = 'PKR';
  static const String currencySymbol = 'Rs.';

  // ── Backend API ──────────────────────────────────────────────
  // For local dev: use ngrok URL (e.g. https://xxxx.ngrok-free.app/api/v1)
  // For Railway deploy: use https://your-app.up.railway.app/api/v1
  // For device testing on same Wi-Fi: use http://192.168.x.x:8000/api/v1
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://paktradex-live.loca.lt/api/v1',
  );

  // Fallback to mock data when backend is unreachable
  static const bool useMockFallback = true;

  // ── Fee & Trading Constants (PSX Aligned) ────────────────────
  static const double standardBrokerageFeePercent = 0.0015; // 0.15%
  static const double minBrokerageFee = 25.0; // 25 PKR minimum
  static const double maxBrokerageFee = 500.0; // 500 PKR cap

  // ── Polling intervals ─────────────────────────────────────────
  static const Duration quotePollInterval = Duration(seconds: 30);
  static const Duration overviewPollInterval = Duration(seconds: 60);

  // ── Regulatory Disclosures ────────────────────────────────────
  static const String legalDisclaimer =
      'PakTradeX is a simulated learning and research platform for the Pakistan Stock Exchange (PSX). '
      'All market quotes, orders, and portfolio metrics are for educational simulation purposes only. '
      'PakTradeX is not a licensed broker-dealer under SECP regulations.';
}
