import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/election_ui.dart';
import '../../state/election_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.controller});
  final ElectionController controller;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool reminders = true;
  bool campaignUpdates = true;

  @override
  Widget build(BuildContext context) {
    final profile = widget.controller.currentUser!;
    final initials = profile.name
        .split(' ')
        .take(2)
        .map((part) => part[0])
        .join();
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        child: AppPagePadding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PROFILE & SECURITY',
                style: Theme.of(context).textTheme.labelMedium
                    ?.copyWith(letterSpacing: 1.5, color: AppColors.teal),
              ),
              const SizedBox(height: 7),
              Text(
                'Your election ID',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            initials,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.name,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(color: Colors.white),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                profile.email,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.white60),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.qr_code_2_rounded,
                          color: Colors.white,
                          size: 38,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.verified_user_rounded,
                            color: AppColors.primary,
                            size: 19,
                          ),
                          const SizedBox(width: 9),
                          Text(
                            'Verified student',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(color: Colors.white),
                          ),
                          const Spacer(),
                          Text(
                            profile.studentId,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: Colors.white60,
                                  letterSpacing: .7,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const SectionTitle(title: 'Election activity'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _Metric(
                      value: '${widget.controller.elections.length}',
                      label: 'Election spaces',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Metric(
                      value: widget.controller.hasVoted ? '1' : '0',
                      label: 'Ballots cast',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Metric(
                      value:
                          '${widget.controller.candidates.where((item) => item.isFollowing).length}',
                      label: 'Following',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const SectionTitle(title: 'Preferences'),
              const SizedBox(height: 8),
              _SettingTile(
                icon: Icons.notifications_active_outlined,
                title: 'Voting reminders',
                subtitle: 'A reminder before a ballot closes',
                trailing: Switch(
                  value: reminders,
                  onChanged: (value) => setState(() => reminders = value),
                ),
              ),
              _SettingTile(
                icon: Icons.campaign_outlined,
                title: 'Campaign updates',
                subtitle: 'Posts from candidates you follow',
                trailing: Switch(
                  value: campaignUpdates,
                  onChanged: (value) => setState(() => campaignUpdates = value),
                ),
              ),
              const _SettingTile(
                icon: Icons.lock_outline_rounded,
                title: 'Ballot privacy',
                subtitle: 'Your choices are never shown on your profile',
                trailing: Icon(Icons.chevron_right_rounded),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmLogout(context),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Log out'),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  'Piga Kura · classroom prototype v2.0',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.logout_rounded, size: 32),
        title: const Text('Log out of Piga Kura?'),
        content: const Text(
          'Your mocked vote and campaign state will stay available for this demo session.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay signed in'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed == true) widget.controller.logout();
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(label, maxLines: 2, style: Theme.of(context).textTheme.bodyMedium),
      ],
    ),
  );
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: AppColors.border)),
    ),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.soft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        trailing,
      ],
    ),
  );
}
