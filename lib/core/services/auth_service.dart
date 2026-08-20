import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';

/// Data class returned after successful auth.
class AuthUser {
  final String userId;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String pakTradeId;
  final bool isVerified;
  final String kycStatus;
  final double demoBalance;
  final double realBalance;
  final String accessToken;

  const AuthUser({
    required this.userId,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    required this.pakTradeId,
    required this.isVerified,
    required this.kycStatus,
    required this.demoBalance,
    required this.realBalance,
    required this.accessToken,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json, String token) {
    return AuthUser(
      userId: json['user_id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      phoneNumber: json['phone_number'] as String?,
      pakTradeId: json['pak_trade_id'] as String? ?? 'PTX-000000',
      isVerified: json['is_verified'] == true || json['is_verified'] == 1,
      kycStatus: json['kyc_status'] as String? ?? 'none',
      demoBalance: (json['demo_balance'] as num?)?.toDouble() ?? 1000000.0,
      realBalance: (json['real_balance'] as num?)?.toDouble() ?? 0.0,
      accessToken: token,
    );
  }
}

/// Wraps all /auth/* backend calls and manages JWT in secure storage.
class AuthService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _tokenKey = 'ptx_jwt_token';

  final ApiClient _api;
  AuthService(this._api);

  // ── Token storage ─────────────────────────────────────────────────

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  Future<void> deleteToken() => _storage.delete(key: _tokenKey);

  // ── Register ──────────────────────────────────────────────────────

  /// Returns the OTP code (only in dev — backend prints it to console).
  /// Returns null on network failure (caller should use mock OTP '123456').
  Future<({String? devOtp, String? error})> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final resp = await _api.post('/auth/register', data: {
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'password': password,
      });
      return (devOtp: resp.data['dev_otp'] as String?, error: null);
    } on ApiException catch (e) {
      if (e.statusCode == 409) {
        return (devOtp: null, error: 'An account with this email already exists.');
      }
      return (devOtp: null, error: e.message);
    } catch (_) {
      return (devOtp: null, error: null); // fallback — let caller use demo OTP
    }
  }

  // ── Login ─────────────────────────────────────────────────────────

  Future<({String? devOtp, String? error})> login({
    required String email,
    required String password,
  }) async {
    try {
      final resp = await _api.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return (devOtp: resp.data['dev_otp'] as String?, error: null);
    } on ApiException catch (e) {
      return (devOtp: null, error: e.message);
    } catch (_) {
      return (devOtp: null, error: null);
    }
  }

  // ── Verify OTP → get JWT ──────────────────────────────────────────

  Future<({AuthUser? user, String? error})> verifyOtp({
    required String email,
    required String code,
  }) async {
    try {
      final resp = await _api.post('/auth/verify-otp', data: {
        'email': email,
        'code': code,
      });
      final data = resp.data as Map<String, dynamic>;
      final token = data['access_token'] as String;
      await saveToken(token);
      final user = AuthUser.fromJson(data, token);
      return (user: user, error: null);
    } on ApiException catch (e) {
      return (user: null, error: e.message);
    } catch (_) {
      return (user: null, error: 'Network error. Please check your connection.');
    }
  }

  // ── Restore session from stored JWT ──────────────────────────────

  Future<AuthUser?> tryRestoreSession() async {
    final token = await getToken();
    if (token == null) return null;

    try {
      final resp = await _api.get(
        '/auth/me',
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = resp.data as Map<String, dynamic>;
      return AuthUser.fromJson(data, token);
    } catch (_) {
      // Token expired or backend unreachable — clear it
      await deleteToken();
      return null;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────

  Future<void> logout() => deleteToken();
}
