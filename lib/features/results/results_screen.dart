import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_notice.dart';
import '../../core/widgets/page_header.dart';
import '../../models/candidate.dart';
import '../../state/election_controller.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key, required this.controller});

  final ElectionController controller;

  Future<void> confirmReset(BuildContext context) async {
    if (controller.totalVotes == 0) {
      showNotice(
        context,
        message: 'There are no votes to reset.',
        tone: NoticeTone.info,
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFFFE7E3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.restart_alt_rounded, color: AppColors.danger),
        ),
        title: const Text('Reset every vote?'),
        content: const Text(
          'This clears the vote count and voter history. Candidates will stay.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Reset Votes'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    controller.resetVotes();
    showNotice(context, message: 'All votes have been reset.');
  }

  @override
  Widget build(BuildContext context) {
    final ranked = controller.rankedCandidates;
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PageHeader(
                        eyebrow: 'Live count',
                        title: 'Election results',
                        description: 'Ranked automatically after every vote. Ties stay ties.',
                        trailing: IconButton.outlined(
                          onPressed: () => confirmReset(context),
                          tooltip: 'Reset all votes',
                          icon: const Icon(Icons.restart_alt_rounded),
                        ),
                      ),
                      const SizedBox(height: 22),
                      _ResultBanner(controller: controller),
                      const SizedBox(height: 26),
                      Row(
                        children: [
                          Text(
                            'Ranking',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Spacer(),
                          Text(
                            '${controller.totalVotes} total',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (ranked.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('Add a candidate to begin.')),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              sliver: SliverList.separated(
                itemCount: ranked.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) => Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: _ResultRow(
                      candidate: ranked[index],
                      rank: index + 1,
                      percentage: controller.percentageFor(ranked[index]),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({required this.controller});

  final ElectionController controller;

  @override
  Widget build(BuildContext context) {
    final hasVotes = controller.totalVotes > 0;
    final isTie = controller.leaders.length > 1;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: hasVotes ? AppColors.ink : const Color(0xFFEAF0F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: hasVotes
                  ? AppColors.gold
                  : Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isTie ? Icons.balance_rounded : Icons.emoji_events_outlined,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasVotes ? 'CURRENT RESULT' : 'WAITING FOR VOTES',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: hasVotes ? const Color(0xFFAEC3D5) : AppColors.muted,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  controller.resultSummary,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: hasVotes ? Colors.white : AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.candidate,
    required this.rank,
    required this.percentage,
  });

  final Candidate candidate;
  final int rank;
  final double percentage;

  @override
  Widget build(BuildContext context) {
    final percentText = '${(percentage * 100).toStringAsFixed(1)}%';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: rank == 1
                  ? const Color(0xFFFFE9B8)
                  : const Color(0xFFEAF0F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$rank',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        candidate.name,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Text(
                      percentText,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: percentage),
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 560),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: value,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE6EDF5),
                      color: rank == 1
                          ? AppColors.primary
                          : const Color(0xFF73A4FF),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${candidate.votes} ${candidate.votes == 1 ? 'vote' : 'votes'}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
