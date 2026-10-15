import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/election_ui.dart';
import '../../models/candidate.dart';
import '../../models/election.dart';
import '../../state/election_controller.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key, required this.controller});
  final ElectionController controller;

  @override
  Widget build(BuildContext context) {
    final election = controller.selectedElection;
    final live = election.status == ElectionStatus.live;
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () async =>
            Future<void>.delayed(const Duration(milliseconds: 600)),
        color: AppColors.ink,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            AppPagePadding(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StatusPill(
                        label: live
                            ? 'Live count'
                            : election.status == ElectionStatus.closed
                            ? 'Final result'
                            : 'Preview',
                        color: live ? AppColors.primary : AppColors.teal,
                      ),
                      const Spacer(),
                      IconButton.outlined(
                        onPressed: () => _showResultInfo(context),
                        tooltip: 'About results',
                        icon: const Icon(Icons.info_outline_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'The class has spoken',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '${election.title} · ${election.group}',
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: 22),
                  _ResultHero(controller: controller),
                  const SizedBox(height: 28),
                  SectionTitle(
                    title: 'Live ranking',
                    subtitle: '${controller.totalVotes} ballots counted',
                    trailing: Text(
                      '${controller.turnoutPercent}% turnout',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        for (
                          var i = 0;
                          i < controller.rankedCandidates.length;
                          i++
                        )
                          _RankingRow(
                            candidate: controller.rankedCandidates[i],
                            rank: i + 1,
                            percentage: controller.percentageFor(
                              controller.rankedCandidates[i],
                            ),
                            last: i == controller.rankedCandidates.length - 1,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF7F5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.shield_outlined,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Privacy preserved',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Results aggregate totals only. Individual student choices are never displayed.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: Text(
                      'Pull down to refresh the mocked live count',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResultInfo(BuildContext context) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.insights_rounded, size: 34),
      title: const Text('How results work'),
      content: const Text(
        'This classroom prototype recalculates rankings immediately after every vote. A real deployment would use an audited backend, encrypted ballots, and a formal election close.',
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Got it'),
        ),
      ],
    ),
  );
}

class _ResultHero extends StatelessWidget {
  const _ResultHero({required this.controller});
  final ElectionController controller;
  @override
  Widget build(BuildContext context) {
    final leader = controller.leaders.isEmpty ? null : controller.leaders.first;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 116,
            height: 116,
            child: CustomPaint(
              painter: _TurnoutPainter(value: controller.turnoutPercent / 100),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${controller.turnoutPercent}%',
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(color: Colors.white),
                    ),
                    Text(
                      'turnout',
                      style: Theme.of(context).textTheme.labelMedium
                          ?.copyWith(color: Colors.white60),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.selectedElection.status == ElectionStatus.closed
                      ? 'WINNER'
                      : 'CURRENT LEADER',
                  style: Theme.of(context).textTheme.labelMedium
                      ?.copyWith(color: AppColors.primary, letterSpacing: 1.4),
                ),
                const SizedBox(height: 7),
                Text(
                  leader?.name ?? 'No votes yet',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  leader == null
                      ? 'Waiting for the first ballot.'
                      : '${leader.votes} votes · ${(controller.percentageFor(leader) * 100).toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TurnoutPainter extends CustomPainter {
  const _TurnoutPainter({required this.value});
  final double value;
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - 11) / 2;
    const stroke = 9.0;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: .12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * value.clamp(0, 1),
      false,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _TurnoutPainter oldDelegate) =>
      oldDelegate.value != value;
}

class _RankingRow extends StatelessWidget {
  const _RankingRow({
    required this.candidate,
    required this.rank,
    required this.percentage,
    required this.last,
  });
  final Candidate candidate;
  final int rank;
  final double percentage;
  final bool last;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      border: last
          ? null
          : const Border(bottom: BorderSide(color: AppColors.border)),
    ),
    child: Row(
      children: [
        Text(
          rank.toString().padLeft(2, '0'),
          style: Theme.of(context).textTheme.labelLarge
              ?.copyWith(color: rank == 1 ? AppColors.ink : AppColors.muted),
        ),
        const SizedBox(width: 12),
        CandidateAvatar(candidate: candidate, size: 46),
        const SizedBox(width: 12),
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
                    '${(percentage * 100).toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: percentage),
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 520),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 7,
                    backgroundColor: AppColors.soft,
                    color: Color(candidate.colorValue),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${candidate.votes} votes',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
