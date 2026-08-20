import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../../portfolio/presentation/widgets/deposit_cash_modal.dart';
import '../../portfolio/presentation/widgets/p2p_transfer_modal.dart';
import '../../trading/providers/trading_provider.dart';
import '../providers/account_provider.dart';
import 'widgets/kyc_verification_modal.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _biometricEnabled = true;
  bool _twoFactorEnabled = true;
  String _riskProfile = 'Moderate Growth';

  void _openKycModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const KycVerificationModal(),
    );
  }

  void _openTransferModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const P2pTransferModal(),
    );
  }

  void _showRegulatoryDisclosures() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
        title: Row(
          children: [
            const Icon(Icons.shield_outlined, color: AppColors.primary, size: 22),
            const SizedBox(width: 8),
            Text('Regulatory Notice', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w800)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'PakTradeX SECP & CDC Compliance',
                style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'PakTradeX provides simulated sandbox training and real-money execution through regulated SECP brokers.\n\n'
                '• Real mode trades settle via the Central Depository Company (CDC) of Pakistan.\n'
                '• Demo mode runs completely risk-free with virtual capital.\n'
                '• P2P transfers are executed instantly between verified PakTrade ID holders.',
                style: AppTypography.bodySmall.copyWith(height: 1.45),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('I Understand'),
          ),
        ],
      ),
    );
  }

  void _showResetDemoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Demo Portfolio?'),
        content: const Text('This will reset your simulated cash balance to Rs. 1,000,000 and clear simulated trade history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(tradingProvider.notifier).resetDemo();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Demo wallet reset to Rs. 1,000,000 cash')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Reset All'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out of your PakTradeX account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat('#,##0.00', 'en_US');
    final auth = ref.watch(authProvider);
    final account = ref.watch(accountProvider);
    final portfolio = ref.watch(tradingProvider);
    final userEmail = auth.user?.email ?? 'syed.ali@paktradex.pk';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(
          'Account & Profile',
          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            onPressed: _openTransferModal,
            tooltip: 'P2P Transfer',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Mode Switcher Segment (Demo vs Real)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.roundedMd,
                border: Border.all(color: AppColors.border),
                boxShadow: AppShadows.subtle,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ref.read(accountProvider.notifier).switchMode(AccountMode.demo);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: account.isDemoMode ? AppColors.warning : Colors.transparent,
                          borderRadius: AppRadius.roundedSm,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.code_rounded,
                              size: 16,
                              color: account.isDemoMode ? Colors.white : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Sandbox Account',
                              style: TextStyle(
                                color: account.isDemoMode ? Colors.white : AppColors.textSecondary,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (!account.isKycVerified) {
                          _openKycModal();
                        } else {
                          ref.read(accountProvider.notifier).switchMode(AccountMode.real);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: account.isRealMode ? AppColors.success : Colors.transparent,
                          borderRadius: AppRadius.roundedSm,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shield_rounded,
                              size: 16,
                              color: account.isRealMode ? Colors.white : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Real Account',
                              style: TextStyle(
                                color: account.isRealMode ? Colors.white : AppColors.textSecondary,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // User Profile & PakTrade Unique ID Card
            AppCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.primary,
                        child: const Text(
                          'AR',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  account.userName,
                                  style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                                ),
                                if (account.isKycVerified) ...[
                                  const SizedBox(width: 4),
                                  const Icon(Icons.verified_rounded, color: AppColors.success, size: 16),
                                ],
                              ],
                            ),
                            Text(
                              userEmail,
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: account.isKycVerified ? AppColors.successLight : AppColors.warningLight,
                                borderRadius: AppRadius.roundedXs,
                              ),
                              child: Text(
                                account.isKycVerified ? 'Verified SECP Trader' : 'Unverified (KYC Pending)',
                                style: AppTypography.labelSmall.copyWith(
                                  color: account.isKycVerified ? AppColors.success : AppColors.warning,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // PakTrade Unique ID Banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: AppRadius.roundedSm,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Unique PakTrade ID',
                              style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
                            ),
                            Text(
                              account.pakTradeId,
                              style: AppTypography.labelLarge.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.copy_rounded, size: 20, color: AppColors.primary),
                              tooltip: 'Copy ID',
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: account.pakTradeId));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${account.pakTradeId} copied to clipboard!')),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.swap_horiz_rounded, size: 20, color: AppColors.primary),
                              tooltip: 'Transfer via ID',
                              onPressed: _openTransferModal,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Active Balance & Wallet Actions
            AppCard(
              backgroundColor: account.isRealMode ? AppColors.successLight : AppColors.primaryLight,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            account.isRealMode ? 'Real Cash Balance' : 'Simulated Wallet Balance',
                            style: AppTypography.bodySmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Rs. ${currency.format(account.isRealMode ? account.realBalance : portfolio.availableCash)}',
                            style: AppTypography.financialLarge.copyWith(fontSize: 22, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                            label: const Text('P2P Send'),
                            onPressed: _openTransferModal,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add_rounded, size: 16),
                            label: const Text('Deposit'),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => const DepositCashModal(),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.surface,
                              foregroundColor: AppColors.textPrimary,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // KYC Status Card
            if (!account.isKycVerified)
              AppCard(
                border: Border.all(color: AppColors.warning, width: 1.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'KYC Verification Required',
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Complete NADRA identity check and OTP verification to unlock live real-money trading and withdrawals.',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      label: 'Start Verification',
                      onPressed: _openKycModal,
                    ),
                  ],
                ),
              )
            else
              AppCard(
                border: Border.all(color: AppColors.success, width: 1.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified_rounded, color: AppColors.success, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'SECP & CDC Verified Trader',
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildVerifiedRow('CNIC', account.cnicNumber),
                    const SizedBox(height: 4),
                    _buildVerifiedRow('Linked Bank', account.bankName),
                    const SizedBox(height: 4),
                    _buildVerifiedRow('IBAN / Raast', account.accountNumber),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.lg),

            // Trading Preferences Section
            _buildSectionHeader('Trading & Investment Preferences'),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.trending_up_rounded, color: AppColors.primary, size: 22),
                    title: Text('Risk Profile', style: AppTypography.bodyMedium),
                    trailing: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _riskProfile,
                        style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                        items: ['Conservative', 'Moderate Growth', 'Aggressive Growth'].map((r) {
                          return DropdownMenuItem(value: r, child: Text(r));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _riskProfile = val);
                        },
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.refresh_rounded, color: AppColors.warning, size: 22),
                    title: Text('Reset Portfolio Balance', style: AppTypography.bodyMedium),
                    subtitle: Text('Reset cash balance to Rs. 1,000,000', style: AppTypography.bodySmall),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _showResetDemoDialog,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Security & App Settings
            _buildSectionHeader('Security & Biometrics'),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.fingerprint_rounded, color: AppColors.primary, size: 22),
                    title: Text('Biometric Login', style: AppTypography.bodyMedium),
                    subtitle: Text('Use Fingerprint / Face ID to unlock', style: AppTypography.bodySmall),
                    value: _biometricEnabled,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) => setState(() => _biometricEnabled = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.security_rounded, color: AppColors.primary, size: 22),
                    title: Text('Two-Factor Authentication (2FA)', style: AppTypography.bodyMedium),
                    subtitle: Text('SMS OTP required for trading actions', style: AppTypography.bodySmall),
                    value: _twoFactorEnabled,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) => setState(() => _twoFactorEnabled = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Legal, Support & Sign Out
            _buildSectionHeader('Compliance & Support'),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.shield_outlined, color: AppColors.textSecondary, size: 22),
                    title: Text('Regulatory & Risk Notice', style: AppTypography.bodyMedium),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _showRegulatoryDisclosures,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.headset_mic_outlined, color: AppColors.textSecondary, size: 22),
                    title: Text('24/7 Investor Support', style: AppTypography.bodyMedium),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Support line: support@paktradex.pk')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout_rounded, color: AppColors.danger, size: 22),
                    title: Text('Sign Out', style: AppTypography.bodyMedium.copyWith(color: AppColors.danger)),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.danger),
                    onTap: _showLogoutDialog,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildVerifiedRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
        Text(value, style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
