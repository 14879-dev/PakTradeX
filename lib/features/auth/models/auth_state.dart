enum AuthStatus {
  initial,
  unauthenticated,
  authenticating,
  otpPending,
  authenticated,
  guest,
}

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String pakTradeId;
  final String? cnic;
  final bool isVerified;
  final String kycStatus;
  final double demoBalance;
  final double realBalance;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.pakTradeId = 'PTX-000000',
    this.cnic,
    this.isVerified = true,
    this.kycStatus = 'none',
    this.demoBalance = 1_000_000.0,
    this.realBalance = 0.0,
  });

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? pakTradeId,
    String? cnic,
    bool? isVerified,
    String? kycStatus,
    double? demoBalance,
    double? realBalance,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      pakTradeId: pakTradeId ?? this.pakTradeId,
      cnic: cnic ?? this.cnic,
      isVerified: isVerified ?? this.isVerified,
      kycStatus: kycStatus ?? this.kycStatus,
      demoBalance: demoBalance ?? this.demoBalance,
      realBalance: realBalance ?? this.realBalance,
    );
  }
}

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? pendingEmailOrPhone;
  final String? pendingDevOtp; // populated in dev mode from backend
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.pendingEmailOrPhone,
    this.pendingDevOtp,
    this.errorMessage,
  });

  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);

  factory AuthState.unauthenticated([String? error]) => AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: error,
      );

  factory AuthState.authenticating() =>
      const AuthState(status: AuthStatus.authenticating);

  factory AuthState.otpPending(String target, {String? devOtp}) => AuthState(
        status: AuthStatus.otpPending,
        pendingEmailOrPhone: target,
        pendingDevOtp: devOtp,
      );

  factory AuthState.authenticated(UserModel user) => AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );

  factory AuthState.guest() => const AuthState(
        status: AuthStatus.guest,
        user: UserModel(
          id: 'guest-001',
          fullName: 'Guest Trader',
          email: 'guest@paktradex.pk',
          phoneNumber: '+923001234567',
          pakTradeId: 'PTX-000001',
        ),
      );

  bool get isAuthenticated =>
      status == AuthStatus.authenticated || status == AuthStatus.guest;

  bool get isInitializing => status == AuthStatus.initial;
}
