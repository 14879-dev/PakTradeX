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
  final String? cnic;
  final bool isVerified;
  final double demoBalance;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.cnic,
    this.isVerified = true,
    this.demoBalance = 1254300.00,
  });

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? cnic,
    bool? isVerified,
    double? demoBalance,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      cnic: cnic ?? this.cnic,
      isVerified: isVerified ?? this.isVerified,
      demoBalance: demoBalance ?? this.demoBalance,
    );
  }
}

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? pendingEmailOrPhone;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.pendingEmailOrPhone,
    this.errorMessage,
  });

  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);

  factory AuthState.unauthenticated([String? error]) => AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: error,
      );

  factory AuthState.authenticating() => const AuthState(status: AuthStatus.authenticating);

  factory AuthState.otpPending(String target) => AuthState(
        status: AuthStatus.otpPending,
        pendingEmailOrPhone: target,
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
        ),
      );

  bool get isAuthenticated => status == AuthStatus.authenticated || status == AuthStatus.guest;
}
