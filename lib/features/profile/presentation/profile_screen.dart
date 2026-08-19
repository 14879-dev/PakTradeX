import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../../portfolio/presentation/widgets/deposit_cash_modal.dart';
import '../../trading/providers/trading_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _biometricEnabled = true;
  bool _twoFactorEnabled = true;
  String _riskProfile = 'Moderate Growth';

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
                'PakTradeX Simulation & Risk Notice',
                style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'PakTradeX is a simulated investment learning platform and research copilot for the Pakistan capital market.\n\n'
                '• All trades executed within the application are simulated with virtual currency.\n'
                '• PakTradeX is not a licensed broker-dealer or securities exchange under the Securities and Exchange Commission of Pakistan (SECP).\n'
                '• Past simulated performance does not guarantee future financial returns.',
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
    final portfolio = ref.watch(tradingProvider);
    final userEmail = auth.user?.email ?? 'investor@paktradex.pk';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Account & Settings',
          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User Profile Header Card
            AppCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      userEmail.substring(0, userEmail.length >= 2 ? 2 : 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PSX Trader',
                          style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          userEmail,
                          style: AppTypography.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius: AppRadius.roundedXs,
                          ),
                          child: Text(
                            'Demo Tier 1 Verified',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.success,
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
            ),
            const SizedBox(height: AppSpacing.lg),

            // Wallet & Simulation Balance Card
            AppCard(
              backgroundColor: AppColors.primaryLight,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Simulated Wallet Balance', style: AppTypography.bodySmall),
                          const SizedBox(height: 2),
                          Text(
                            'Rs. ${currency.format(portfolio.availableCash)}',
                            style: AppTypography.financialLarge.copyWith(fontSize: 22, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const DepositCashModal(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        ),
                        child: const Text('Add Funds'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Trading & Risk Profile Section
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
                    leading: const Icon(Icons.restart_alt_rounded, color: AppColors.warning, size: 22),
                    title: Text('Reset Demo Portfolio', style: AppTypography.bodyMedium),
                    subtitle: const Text('Restore default 1M PKR cash balance', style: TextStyle(fontSize: 11)),
                    trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textSecondary),
                    onTap: _showResetDemoDialog,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Security Settings
            _buildSectionHeader('Security & Biometrics'),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.fingerprint_rounded, color: AppColors.primary, size: 22),
                    title: Text('Biometric Quick Login', style: AppTypography.bodyMedium),
                    subtitle: const Text('FaceID / TouchID simulated authentication', style: TextStyle(fontSize: 11)),
                    value: _biometricEnabled,
                    onChanged: (val) {
                      setState(() => _biometricEnabled = val);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Biometrics ${val ? 'enabled' : 'disabled'}')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.security_rounded, color: AppColors.primary, size: 22),
                    title: Text('Two-Factor Authentication (OTP)', style: AppTypography.bodyMedium),
                    subtitle: const Text('Require 6-digit SMS OTP on every sign-in', style: TextStyle(fontSize: 11)),
                    value: _twoFactorEnabled,
                    onChanged: (val) {
                      setState(() => _twoFactorEnabled = val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Compliance & Legal
            _buildSectionHeader('Disclosures & Legal'),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.shield_outlined, color: AppColors.textPrimary, size: 22),
                    title: Text('Fintech Disclosures & SECP Notice', style: AppTypography.bodyMedium),
                    trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textSecondary),
                    onTap: _showRegulatoryDisclosures,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.article_outlined, color: AppColors.textPrimary, size: 22),
                    title: Text('Terms of Service & Privacy Policy', style: AppTypography.bodyMedium),
                    trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textSecondary),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Terms of Service v1.0.4 loaded')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _showLogoutDialog,
                icon: const Icon(Icons.logout_rounded, color: AppColors.danger, size: 18),
                label: Text(
                  'Log Out of PakTradeX',
                  style: AppTypography.labelMedium.copyWith(color: AppColors.danger, fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.danger),
                  shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 6.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
