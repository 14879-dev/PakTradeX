import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AccountMode { demo, real }
enum KycStatus { unverified, inReview, verified }

class AccountState {
  final AccountMode mode;
  final String pakTradeId;
  final KycStatus kycStatus;
  final double realBalance;
  final double demoBalance;
  final String userName;
  final String phoneNumber;
  final String cnicNumber;
  final String bankName;
  final String accountNumber;
  final List<P2pTransferRecord> transferHistory;

  const AccountState({
    required this.mode,
    required this.pakTradeId,
    required this.kycStatus,
    required this.realBalance,
    required this.demoBalance,
    required this.userName,
    required this.phoneNumber,
    required this.cnicNumber,
    required this.bankName,
    required this.accountNumber,
    required this.transferHistory,
  });

  bool get isRealMode => mode == AccountMode.real;
  bool get isDemoMode => mode == AccountMode.demo;
  bool get isKycVerified => kycStatus == KycStatus.verified;

  double get activeBalance => isRealMode ? realBalance : demoBalance;

  AccountState copyWith({
    AccountMode? mode,
    String? pakTradeId,
    KycStatus? kycStatus,
    double? realBalance,
    double? demoBalance,
    String? userName,
    String? phoneNumber,
    String? cnicNumber,
    String? bankName,
    String? accountNumber,
    List<P2pTransferRecord>? transferHistory,
  }) {
    return AccountState(
      mode: mode ?? this.mode,
      pakTradeId: pakTradeId ?? this.pakTradeId,
      kycStatus: kycStatus ?? this.kycStatus,
      realBalance: realBalance ?? this.realBalance,
      demoBalance: demoBalance ?? this.demoBalance,
      userName: userName ?? this.userName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      cnicNumber: cnicNumber ?? this.cnicNumber,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      transferHistory: transferHistory ?? this.transferHistory,
    );
  }
}

class P2pTransferRecord {
  final String id;
  final String recipientId;
  final String recipientName;
  final double amount;
  final String note;
  final DateTime timestamp;
  final AccountMode mode;

  const P2pTransferRecord({
    required this.id,
    required this.recipientId,
    required this.recipientName,
    required this.amount,
    required this.note,
    required this.timestamp,
    required this.mode,
  });
}

class AccountNotifier extends StateNotifier<AccountState> {
  AccountNotifier()
      : super(
          const AccountState(
            mode: AccountMode.demo,
            pakTradeId: 'PTX-148790',
            kycStatus: KycStatus.unverified,
            realBalance: 50000.0,
            demoBalance: 1000000.0,
            userName: 'Syed Ali Raza',
            phoneNumber: '+92 300 8492014',
            cnicNumber: '42101-9284102-1',
            bankName: 'Meezan Bank Ltd',
            accountNumber: 'PK42MEZN0001928491028301',
            transferHistory: [],
          ),
        );

  void switchMode(AccountMode mode) {
    state = state.copyWith(mode: mode);
  }

  void toggleMode() {
    state = state.copyWith(
      mode: state.isDemoMode ? AccountMode.real : AccountMode.demo,
    );
  }

  void completeKyc({
    required String phone,
    required String cnic,
    required String bank,
    required String accountNum,
  }) {
    state = state.copyWith(
      kycStatus: KycStatus.verified,
      phoneNumber: phone,
      cnicNumber: cnic,
      bankName: bank,
      accountNumber: accountNum,
    );
  }

  void depositRealFunds(double amount) {
    state = state.copyWith(
      realBalance: state.realBalance + amount,
    );
  }

  void withdrawRealFunds(double amount) {
    if (state.realBalance >= amount) {
      state = state.copyWith(
        realBalance: state.realBalance - amount,
      );
    }
  }

  bool sendP2pTransfer({
    required String recipientId,
    required String recipientName,
    required double amount,
    required String note,
  }) {
    if (state.isRealMode) {
      if (state.realBalance < amount) return false;
      final record = P2pTransferRecord(
        id: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
        recipientId: recipientId,
        recipientName: recipientName,
        amount: amount,
        note: note,
        timestamp: DateTime.now(),
        mode: AccountMode.real,
      );
      state = state.copyWith(
        realBalance: state.realBalance - amount,
        transferHistory: [record, ...state.transferHistory],
      );
      return true;
    } else {
      if (state.demoBalance < amount) return false;
      final record = P2pTransferRecord(
        id: 'TXN-DEMO-${DateTime.now().millisecondsSinceEpoch}',
        recipientId: recipientId,
        recipientName: recipientName,
        amount: amount,
        note: note,
        timestamp: DateTime.now(),
        mode: AccountMode.demo,
      );
      state = state.copyWith(
        demoBalance: state.demoBalance - amount,
        transferHistory: [record, ...state.transferHistory],
      );
      return true;
    }
  }
}

final accountProvider =
    StateNotifierProvider<AccountNotifier, AccountState>((ref) {
  return AccountNotifier();
});
