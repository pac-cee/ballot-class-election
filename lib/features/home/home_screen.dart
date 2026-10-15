import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/candidate_sheet.dart';
import '../../core/widgets/election_ui.dart';
import '../../models/candidate.dart';
import '../../models/election.dart';
import '../../state/election_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.controller,
    required this.onOpenBallot,
    required this.onOpenCampaigns,
    required this.onOpenResults,
  });
  final ElectionController controller;
  final VoidCallback onOpenBallot;
  final VoidCallback onOpenCampaigns;
  final VoidCallback onOpenResults;

  @override
  Widget build(BuildContext context) {
    final firstName =
        controller.currentUser?.name.split(' ').first ?? 'Student';
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: AppPagePadding(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good afternoon,',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              firstName,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: () => _showNotifications(context),
                        tooltip: 'Notifications',
                        icon: const Badge(
                          smallSize: 8,
                          child: Icon(Icons.notifications_none_rounded),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const SectionTitle(
                    title: 'Your elections',
                    subtitle: 'Switch class or club spaces',
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 82,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.elections.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final election = controller.elections[index];
                        final selected =
                            controller.selectedElectionIndex == index;
                        return _ElectionChip(
                          election: election,
                          selected: selected,
                          onTap: () => controller.selectElection(index),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  _ElectionHero(
                    controller: controller,
                    onOpenBallot: onOpenBallot,
                    onOpenResults: onOpenResults,
                  ),
                  const SizedBox(height: 28),
                  SectionTitle(
                    title: 'Meet the candidates',
                    subtitle:
                        '${controller.candidates.length} people on this ballot',
                    trailing: TextButton(
                      onPressed: onOpenCampaigns,
                      child: const Text('Campaigns'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 212,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.candidates.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final candidate = controller.candidates[index];
                        return _CandidatePreview(
                          candidate: candidate,
                          onTap: () => showCandidateSheet(
                            context,
                            candidate: candidate,
                            controller: controller,
                            onVote:
                                controller.selectedElection.status ==
                                    ElectionStatus.live
                                ? onOpenBallot
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 28),
                  SectionTitle(
                    title: 'Campaign pulse',
                    subtitle: 'Latest from the people running',
                    trailing: IconButton(
                      onPressed: onOpenCampaigns,
                      tooltip: 'Open campaign feed',
                      icon: const Icon(Icons.arrow_forward_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (controller.posts.isNotEmpty)
                    _PostPreview(controller: controller),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 4, 22, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 18),
            const _NoticeRow(
              icon: Icons.schedule_rounded,
              title: 'Voting closes today',
              body: 'Senior 6 Science ballot closes at 18:00.',
            ),
            const Divider(height: 28),
            const _NoticeRow(
              icon: Icons.campaign_outlined,
              title: 'New campaign update',
              body: 'Keza posted about the shared revision bank.',
            ),
            const Divider(height: 28),
            const _NoticeRow(
              icon: Icons.verified_user_outlined,
              title: 'Identity verified',
              body: 'Your student account can cast one private ballot.',
            ),
          ],
        ),
      ),
    ),
  );
}

class _ElectionChip extends StatelessWidget {
  const _ElectionChip({
    required this.election,
    required this.selected,
    required this.onTap,
  });
  final ClassElection election;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: selected ? AppColors.ink : Colors.white,
    borderRadius: BorderRadius.circular(18),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 210,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? AppColors.ink : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 42,
              decoration: BoxDecoration(
                color: Color(election.colorValue),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    election.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: selected ? Colors.white : AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    election.group,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: selected ? Colors.white60 : AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ElectionHero extends StatelessWidget {
  const _ElectionHero({
    required this.controller,
    required this.onOpenBallot,
    required this.onOpenResults,
  });
  final ElectionController controller;
  final VoidCallback onOpenBallot;
  final VoidCallback onOpenResults;
  @override
  Widget build(BuildContext context) {
    final election = controller.selectedElection;
    final live = election.status == ElectionStatus.live;
    final status = switch (election.status) {
      ElectionStatus.live => 'Live now',
      ElectionStatus.upcoming => 'Upcoming',
      ElectionStatus.closed => 'Final',
    };
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -35,
            top: -24,
            child: Opacity(
              opacity: .92,
              child: Image.asset(
                'assets/images/ballot-box-3d.png',
                width: 190,
                height: 190,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                    StatusPill(label: status, color: Color(election.colorValue), solid: true),
                const SizedBox(height: 52),
                SizedBox(
                  width: 260,
                  child: Text(
                    election.title,
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(color: Colors.white, fontSize: 34),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  election.group,
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 14,
                  runSpacing: 7,
                  children: [
                    _HeroFact(Icons.schedule_rounded, election.scheduleLabel),
                    _HeroFact(
                      Icons.groups_outlined,
                      '${controller.turnoutPercent}% turnout',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: live ? onOpenBallot : onOpenResults,
                        icon: Icon(
                          live
                              ? Icons.how_to_vote_outlined
                              : Icons.bar_chart_rounded,
                        ),
                        label: Text(live ? 'Open my ballot' : 'View results'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton.outlined(
                      onPressed: onOpenResults,
                      tooltip: 'Live results',
                      style: IconButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                        minimumSize: const Size(52, 52),
                      ),
                      icon: const Icon(Icons.insights_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroFact extends StatelessWidget {
  const _HeroFact(this.icon, this.label);
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: AppColors.primary, size: 17),
      const SizedBox(width: 6),
      Text(
        label,
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: Colors.white70),
      ),
    ],
  );
}

class _CandidatePreview extends StatelessWidget {
  const _CandidatePreview({required this.candidate, required this.onTap});
  final Candidate candidate;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 174,
    child: Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CandidateAvatar(
                candidate: candidate,
                size: 58,
                showVerified: true,
              ),
              const Spacer(),
              Text(
                candidate.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                candidate.course,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.arrow_outward_rounded, size: 17),
                  const SizedBox(width: 5),
                  Text(
                    'View plan',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _PostPreview extends StatelessWidget {
  const _PostPreview({required this.controller});
  final ElectionController controller;
  @override
  Widget build(BuildContext context) {
    final post = controller.posts.first;
    final candidate =
        controller.candidateById(post.candidateId) ??
        controller.candidates.first;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CandidateAvatar(candidate: candidate, size: 42),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${candidate.course} · ${post.timeLabel}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(post.body, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 14),
          Row(
            children: [
              IconButton(
                onPressed: () => controller.togglePostLike(post),
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  post.isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: post.isLiked ? AppColors.coral : AppColors.muted,
                ),
              ),
              Text(
                '${post.likes}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const Spacer(),
              const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 19,
                color: AppColors.muted,
              ),
              const SizedBox(width: 7),
              Text('Discuss', style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoticeRow extends StatelessWidget {
  const _NoticeRow({
    required this.icon,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 3),
            Text(body, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    ],
  );
}
