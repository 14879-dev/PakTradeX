import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.initial());

  Future<void> login(String email, String password) async {
    state = AuthState.authenticating();
    await Future.delayed(const Duration(milliseconds: 600));

    if (email.isEmpty || password.isEmpty) {
      state = AuthState.unauthenticated('Please provide both email and password.');
      return;
    }

    // Move to OTP verification for security (Fintech standard 2FA)
    state = AuthState.otpPending(email);
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    state = AuthState.authenticating();
    await Future.delayed(const Duration(milliseconds: 700));

    if (fullName.isEmpty || email.isEmpty || phoneNumber.isEmpty || password.isEmpty) {
      state = AuthState.unauthenticated('All registration fields are required.');
      return;
    }

    state = AuthState.otpPending(email);
  }

  Future<bool> verifyOtp(String code) async {
    state = AuthState.authenticating();
    await Future.delayed(const Duration(milliseconds: 500));

    // For demo/hackathon MVP, '123456' or any 6-digit code passes
    if (code.length == 6) {
      state = AuthState.authenticated(
        UserModel(
          id: 'usr-10492',
          fullName: 'Pakistani Investor',
          email: state.pendingEmailOrPhone ?? 'investor@paktradex.pk',
          phoneNumber: '+92 300 1234567',
        ),
      );
      return true;
    } else {
      state = AuthState.unauthenticated('Invalid OTP code. Please enter 6 digits.');
      return false;
    }
  }

  void loginAsGuest() {
    state = AuthState.guest();
  }

  void logout() {
    state = AuthState.unauthenticated();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
