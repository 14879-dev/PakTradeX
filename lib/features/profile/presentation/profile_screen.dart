import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
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

  void _showSupportModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.headset_mic_rounded, color: AppColors.primary, size: 24),
                SizedBox(width: 10),
                Text(
                  'PakTradeX 24/7 Support',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Our financial desk and customer support team are available 24/7.',
              style: TextStyle(fontSize: 13, color: Color(0xFF4A5568)),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
              title: const Text('AI Market Copilot', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('Instant answers powered by Gemini AI'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/ai');
              },
            ),
            ListTile(
              leading: const Icon(Icons.email_outlined, color: AppColors.primary),
              title: const Text('Email Desk', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('support@paktradex.pk'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(String currentName) {
    final nameCtrl = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Profile Name', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: TextField(
          controller: nameCtrl,
          decoration: InputDecoration(
            labelText: 'Full Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
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
        content: const Text('This will reset your simulated cash balance to Rs. 1,000,000 and clear simulated trade orders.'),
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

  void _showRegulatoryNotice() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.shield_outlined, color: AppColors.primary, size: 22),
            SizedBox(width: 8),
            Text('SECP Compliance', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
        content: const Text(
          'PakTradeX is a simulated learning and execution platform for the Pakistan Stock Exchange (PSX).\n\n'
          '• Real mode trades settle via the Central Depository Company (CDC) of Pakistan.\n'
          '• Demo mode runs risk-free with virtual portfolio capital.\n'
          '• Direct Pay transfers are executed instantly between verified PakTrade ID holders.',
          style: TextStyle(fontSize: 13, height: 1.45, color: Color(0xFF4A5568)),
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
    final auth = ref.watch(authProvider);
    final account = ref.watch(accountProvider);

    final rawName = auth.user?.fullName.isNotEmpty == true
        ? auth.user!.fullName
        : account.userName;
    final username = rawName.toLowerCase().replaceAll(' ', '') + '52';
    final userEmail = auth.user?.email ?? 'mmk521142@gmail.com';
    final pakTradeId = auth.user?.pakTradeId ?? account.pakTradeId;
    final initials = rawName.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1A202C)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        actions: [
          // Scan QR
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF2D3748), size: 21),
            tooltip: 'Direct Pay / Scan QR',
            onPressed: _openTransferModal,
          ),
          // 24/7 Support
          IconButton(
            icon: const Icon(Icons.headset_mic_outlined, color: Color(0xFF2D3748), size: 21),
            tooltip: '24/7 Support',
            onPressed: _showSupportModal,
          ),
          // Settings
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF2D3748), size: 21),
            tooltip: 'Settings',
            onPressed: _showRegulatoryNotice,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. User Header (Matching Reference Screenshot 1) ───────────
            InkWell(
              onTap: () => _showEditProfileDialog(rawName),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    // Avatar with online status
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            initials.isNotEmpty ? initials : 'MU',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 2,
                          bottom: 2,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: account.isKycVerified ? const Color(0xFF38A169) : const Color(0xFFDD6B20),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),

                    // User Info & Badges
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'ID: $pakTradeId',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF718096),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: pakTradeId));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('PakTrade ID copied!'), duration: Duration(seconds: 1)),
                                  );
                                },
                                child: const Icon(Icons.copy_rounded, size: 13, color: Color(0xFFA0AEC0)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            username,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1A202C),
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Badges (Regular + Verified/Unverified)
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEFCBF),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  account.isDemoMode ? 'Demo Sandbox' : 'Regular Trader',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF744210),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: account.isKycVerified
                                      ? const Color(0xFFC6F6D5)
                                      : const Color(0xFFFEEBC8),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (account.isKycVerified)
                                      const Icon(Icons.check_circle_rounded, size: 11, color: Color(0xFF276749)),
                                    if (account.isKycVerified) const SizedBox(width: 3),
                                    Text(
                                      account.isKycVerified ? 'Verified' : '1-Time KYC Required',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: account.isKycVerified
                                            ? const Color(0xFF276749)
                                            : const Color(0xFF7B341E),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Icon(Icons.chevron_right_rounded, color: Color(0xFFA0AEC0)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── 2. Shortcut Section (Matching Reference Screenshot 1) ────────
            const Text(
              'Shortcut',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A202C),
              ),
            ),
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildProfileShortcut(
                    icon: Icons.swap_horiz_rounded,
                    label: 'P2P Pay',
                    onTap: _openTransferModal,
                  ),
                  _buildProfileShortcut(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Deposit',
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const DepositCashModal(),
                      );
                    },
                  ),
                  _buildProfileShortcut(
                    icon: Icons.auto_awesome_rounded,
                    label: 'AI Copilot',
                    onTap: () => context.push('/ai'),
                  ),
                  _buildProfileShortcut(
                    icon: Icons.receipt_long_rounded,
                    label: 'Orders',
                    onTap: () => context.go('/portfolio'),
                  ),
                  _buildProfileShortcut(
                    icon: Icons.edit_note_rounded,
                    label: 'Edit',
                    onTap: () => _showEditProfileDialog(rawName),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── 3. Recommend / Services Section ──────────────────────────────
            const Text(
              'Recommend',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A202C),
              ),
            ),
            const SizedBox(height: 14),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  // 1-Time KYC Verification Tile
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: account.isKycVerified
                            ? const Color(0xFFC6F6D5)
                            : const Color(0xFFFEEBC8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        account.isKycVerified
                            ? Icons.verified_rounded
                            : Icons.badge_outlined,
                        color: account.isKycVerified
                            ? const Color(0xFF276749)
                            : const Color(0xFFDD6B20),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      account.isKycVerified
                          ? 'SECP Verified Trader'
                          : '1-Time KYC Identity Verification',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                    ),
                    subtitle: Text(
                      account.isKycVerified
                          ? 'CNIC & CDC sub-account verified for real trading'
                          : 'Complete once to unlock live trading & instant withdrawals',
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF718096)),
                    ),
                    trailing: account.isKycVerified
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC6F6D5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Verified ✅',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF276749)),
                            ),
                          )
                        : const Icon(Icons.chevron_right_rounded, color: Color(0xFFA0AEC0)),
                    onTap: account.isKycVerified ? null : _openKycModal,
                  ),

                  const Divider(height: 1, indent: 64, color: Color(0xFFEDF2F7)),

                  // Bank & Raast Settlement
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.account_balance_rounded, color: AppColors.primary, size: 20),
                    ),
                    title: const Text('Bank & Raast Settlement', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                    subtitle: Text(account.bankName, style: const TextStyle(fontSize: 11.5, color: Color(0xFF718096))),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFA0AEC0)),
                    onTap: _openKycModal,
                  ),

                  const Divider(height: 1, indent: 64, color: Color(0xFFEDF2F7)),

                  // Biometric Security Lock
                  SwitchListTile(
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBF8FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.fingerprint_rounded, color: Color(0xFF3182CE), size: 20),
                    ),
                    title: const Text('Biometric Quick Unlock', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                    subtitle: const Text('Use fingerprint/face to unlock sessions', style: TextStyle(fontSize: 11.5, color: Color(0xFF718096))),
                    value: _biometricEnabled,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _biometricEnabled = val),
                  ),

                  const Divider(height: 1, indent: 64, color: Color(0xFFEDF2F7)),

                  // Reset Demo Portfolio Capital
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEFCBF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.refresh_rounded, color: Color(0xFF744210), size: 20),
                    ),
                    title: const Text('Reset Demo Portfolio', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                    subtitle: const Text('Reset virtual sandbox funds to Rs. 1,000,000 cash', style: TextStyle(fontSize: 11.5, color: Color(0xFF718096))),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFA0AEC0)),
                    onTap: _showResetDemoDialog,
                  ),

                  const Divider(height: 1, indent: 64, color: Color(0xFFEDF2F7)),

                  // SECP Compliance & Legal
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7FAFC),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shield_outlined, color: Color(0xFF718096), size: 20),
                    ),
                    title: const Text('SECP & CDC Regulatory Notice', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                    subtitle: const Text('Disclosures on sandbox simulation & CDC clearing', style: TextStyle(fontSize: 11.5, color: Color(0xFF718096))),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFA0AEC0)),
                    onTap: _showRegulatoryNotice,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── 4. Bottom Switcher Banner (Matching Binance Lite/Pro pill) ─────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('PX', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.isDemoMode ? 'PakTradeX Sandbox (Demo)' : 'PakTradeX Pro (Live PSX)',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                        ),
                        Text(
                          account.isDemoMode ? 'Tap to switch to Real PSX mode' : 'Tap to switch to Demo sandbox',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF718096)),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: account.isRealMode,
                    activeColor: AppColors.success,
                    onChanged: (isReal) {
                      if (isReal && !account.isKycVerified) {
                        _openKycModal();
                      } else {
                        ref.read(accountProvider.notifier).switchMode(
                              isReal ? AccountMode.real : AccountMode.demo,
                            );
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout_rounded, size: 18, color: Color(0xFFE53E3E)),
                label: const Text(
                  'Log Out Account',
                  style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFE53E3E)),
                ),
                onPressed: _showLogoutDialog,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  side: const BorderSide(color: Color(0xFFFEB2B2)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileShortcut({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3748),
            ),
          ),
        ],
      ),
    );
  }
}
