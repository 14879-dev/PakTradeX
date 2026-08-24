import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AccountMode { demo, real }
enum KycStatus { unverified, inReview, verified }

class TransactionRecord {
  final String id;
  final String title;
  final String type; // 'deposit', 'withdrawal', 'trade', 'p2p'
  final double amount;
  final String status;
  final DateTime timestamp;
  final String? paymentMethod;
  final String? reference;

  const TransactionRecord({
    required this.id,
    required this.title,
    required this.type,
    required this.amount,
    required this.status,
    required this.timestamp,
    this.paymentMethod,
    this.reference,
  });
}

class AccountState {
  final AccountMode mode;
  final String pakTradeId;
  final KycStatus kycStatus;
  final double realBalance; // Starts at 0.0 before real deposit!
  final double demoBalance; // 1,000,000 for demo practice
  final String userName;
  final String phoneNumber;
  final String cnicNumber;
  final String bankName;
  final String accountNumber;
  final List<TransactionRecord> transactionHistory;
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
    required this.transactionHistory,
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
    List<TransactionRecord>? transactionHistory,
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
      transactionHistory: transactionHistory ?? this.transactionHistory,
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
            realBalance: 0.0, // Clean 0.0 real balance before deposit
            demoBalance: 1000000.0,
            userName: 'Mudassir Munir',
            phoneNumber: '',
            cnicNumber: '',
            bankName: '',
            accountNumber: '',
            transactionHistory: [],
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

  bool depositRealFunds({
    required double amount,
    required String paymentMethod,
    String? reference,
  }) {
    if (amount <= 0) return false;
    final txn = TransactionRecord(
      id: 'DEP-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Deposit via $paymentMethod',
      type: 'deposit',
      amount: amount,
      status: 'Completed',
      timestamp: DateTime.now(),
      paymentMethod: paymentMethod,
      reference: reference ?? 'RAAST-DIRECT-${DateTime.now().millisecondsSinceEpoch % 1000000}',
    );

    state = state.copyWith(
      realBalance: state.realBalance + amount,
      transactionHistory: [txn, ...state.transactionHistory],
    );
    return true;
  }

  bool withdrawRealFunds({
    required double amount,
    required String destinationBank,
    required String iban,
  }) {
    if (amount <= 0 || state.realBalance < amount) return false;
    final txn = TransactionRecord(
      id: 'WTH-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Withdrawal to $destinationBank',
      type: 'withdrawal',
      amount: amount,
      status: 'Completed',
      timestamp: DateTime.now(),
      paymentMethod: destinationBank,
      reference: iban,
    );

    state = state.copyWith(
      realBalance: state.realBalance - amount,
      transactionHistory: [txn, ...state.transactionHistory],
    );
    return true;
  }

  void resetDemoFunds() {
    state = state.copyWith(demoBalance: 1000000.0);
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
