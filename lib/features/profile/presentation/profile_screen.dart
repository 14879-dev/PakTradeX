import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    child: const Text(
                      'PT',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pakistani Investor',
                          style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'investor@paktradex.pk',
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
                            'Demo Account Verified',
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

            // Settings List
            _buildSettingSection(
              title: 'Trading & Simulation',
              items: [
                _SettingItem(icon: Icons.account_balance_wallet_outlined, title: 'Demo Wallet & Funds'),
                _SettingItem(icon: Icons.history_rounded, title: 'Order History & Executions'),
                _SettingItem(icon: Icons.notifications_none_rounded, title: 'Price Alerts & Triggers'),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            _buildSettingSection(
              title: 'Security & Auth',
              items: [
                _SettingItem(icon: Icons.lock_outline_rounded, title: 'Two-Factor Authentication (2FA)'),
                _SettingItem(icon: Icons.fingerprint_rounded, title: 'Biometric Unlock'),
                _SettingItem(icon: Icons.devices_rounded, title: 'Active Sessions & Devices'),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            _buildSettingSection(
              title: 'Preferences & Compliance',
              items: [
                _SettingItem(icon: Icons.language_rounded, title: 'Language (English / اردو)'),
                _SettingItem(icon: Icons.policy_outlined, title: 'Fintech & Broker Disclaimers'),
                _SettingItem(icon: Icons.help_outline_rounded, title: 'Help & Support Desk'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingSection({required String title, required List<_SettingItem> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 6.0),
          child: Text(
            title,
            style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: Icon(item.icon, color: AppColors.textPrimary, size: 22),
                title: Text(item.title, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
                onTap: () {},
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SettingItem {
  final IconData icon;
  final String title;

  _SettingItem({required this.icon, required this.title});
}
