import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_notice.dart';
import '../../core/widgets/candidate_sheet.dart';
import '../../core/widgets/election_ui.dart';
import '../../models/candidate.dart';
import '../../models/election.dart';
import '../../state/election_controller.dart';

class VoteScreen extends StatefulWidget {
  const VoteScreen({
    super.key,
    required this.controller,
    required this.onOpenResults,
  });
  final ElectionController controller;
  final VoidCallback onOpenResults;

  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  int? selectedCandidateId;

  Candidate? get selected {
    for (final candidate in widget.controller.candidates) {
      if (candidate.id == selectedCandidateId) return candidate;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final election = widget.controller.selectedElection;
    final active = election.status == ElectionStatus.live;
    if (widget.controller.hasVoted) {
      return _VoteReceipt(
        controller: widget.controller,
        onOpenResults: widget.onOpenResults,
      );
    }
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            StatusPill(
                              label: active
                                  ? 'Ballot open'
                                  : election.status == ElectionStatus.upcoming
                                  ? 'Not open yet'
                                  : 'Ballot closed',
                              color: Color(election.colorValue),
                            ),
                            const Spacer(),
                            IconButton.outlined(
                              onPressed: () => _showHowItWorks(context),
                              tooltip: 'How voting works',
                              icon: const Icon(Icons.help_outline_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Choose one candidate',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 7),
                        Text(
                          '${election.title} · ${election.group}',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: AppColors.muted),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.verified_user_outlined,
                                size: 20,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  'Verified as ${widget.controller.currentUser?.name ?? 'student'}',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                              ),
                              Text(
                                election.scheduleLabel,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        for (
                          var i = 0;
                          i < widget.controller.candidates.length;
                          i++
                        ) ...[
                          _BallotCandidate(
                            candidate: widget.controller.candidates[i],
                            index: i + 1,
                            selected:
                                selectedCandidateId ==
                                widget.controller.candidates[i].id,
                            enabled: active,
                            onSelected: () => setState(
                              () => selectedCandidateId =
                                  widget.controller.candidates[i].id,
                            ),
                            onDetails: () => showCandidateSheet(
                              context,
                              candidate: widget.controller.candidates[i],
                              controller: widget.controller,
                              onVote: active
                                  ? () => setState(
                                      () => selectedCandidateId =
                                          widget.controller.candidates[i].id,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 11),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.lock_outline_rounded,
                              color: AppColors.muted,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Your choice is private. Results show totals only and cannot be traced back to your account.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              12 + MediaQuery.paddingOf(context).bottom,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(top: BorderSide(color: AppColors.border)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: .06),
                  blurRadius: 18,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Row(
                  children: [
                    if (selected != null) ...[
                      CandidateAvatar(candidate: selected!, size: 42),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selected!.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              'Your selection',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                    ] else
                      Expanded(
                        child: Text(
                          active
                              ? 'Select a candidate to continue'
                              : election.scheduleLabel,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    FilledButton.icon(
                      onPressed: active && selected != null
                          ? () => _reviewVote(context, selected!)
                          : null,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('Review ballot'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _reviewVote(BuildContext context, Candidate candidate) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: CandidateAvatar(
          candidate: candidate,
          size: 68,
          showVerified: true,
        ),
        title: const Text('Review your ballot'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You are voting for',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              candidate.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              widget.controller.selectedElection.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7E6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFF8A5A00),
                    size: 19,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'After you cast this ballot, your selection cannot be changed.',
                      style: TextStyle(color: Color(0xFF6D4800), height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Go back'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.lock_rounded),
            label: const Text('Cast vote'),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;
    final result = widget.controller.vote(
      voterName: widget.controller.currentUser?.name ?? '',
      candidateId: candidate.id,
    );
    if (result.status == VoteStatus.success && context.mounted) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          icon: Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.ink,
              size: 38,
            ),
          ),
          title: const Text('Your vote is in'),
          content: Text(
            'Your private ballot for ${candidate.name} was counted successfully.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('View receipt'),
            ),
          ],
        ),
      );
    } else if (context.mounted) {
      showNotice(
        context,
        message: result.status == VoteStatus.alreadyVoted
            ? 'You already voted in this election.'
            : 'This ballot is no longer available.',
        tone: NoticeTone.error,
      );
    }
  }

  void _showHowItWorks(BuildContext context) => showModalBottomSheet<void>(
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
              'A simple, private ballot',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 18),
            const _HowStep(
              number: '1',
              title: 'Choose',
              body: 'Compare candidates and select one person.',
            ),
            const _HowStep(
              number: '2',
              title: 'Review',
              body: 'Confirm the candidate before the vote is locked.',
            ),
            const _HowStep(
              number: '3',
              title: 'Count',
              body: 'Only the total is published—never your personal choice.',
            ),
          ],
        ),
      ),
    ),
  );
}

class _BallotCandidate extends StatelessWidget {
  const _BallotCandidate({
    required this.candidate,
    required this.index,
    required this.selected,
    required this.enabled,
    required this.onSelected,
    required this.onDetails,
  });
  final Candidate candidate;
  final int index;
  final bool selected;
  final bool enabled;
  final VoidCallback onSelected;
  final VoidCallback onDetails;
  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 180),
    decoration: BoxDecoration(
      color: selected
          ? Color(candidate.colorValue).withValues(alpha: .13)
          : Colors.white,
      border: Border.all(
        color: selected ? AppColors.ink : AppColors.border,
        width: selected ? 2 : 1,
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    child: InkWell(
      onTap: enabled ? onSelected : null,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CandidateAvatar(candidate: candidate, size: 58, showVerified: true),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    candidate.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    candidate.slogan,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 7),
                  InkWell(
                    onTap: onDetails,
                    child: Text(
                      'Read manifesto',
                      style: Theme.of(context).textTheme.labelLarge
                          ?.copyWith(decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: selected ? AppColors.ink : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.ink : AppColors.border,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      color: AppColors.primary,
                      size: 19,
                    )
                  : Center(
                      child: Text(
                        '$index',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _VoteReceipt extends StatelessWidget {
  const _VoteReceipt({required this.controller, required this.onOpenResults});
  final ElectionController controller;
  final VoidCallback onOpenResults;
  @override
  Widget build(BuildContext context) {
    final id = controller.selectedElection.votedCandidateId;
    Candidate? candidate;
    for (final item in controller.candidates) {
      if (item.id == id) candidate = item;
    }
    return SafeArea(
      bottom: false,
      child: Center(
        child: SingleChildScrollView(
          child: AppPagePadding(
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(Icons.how_to_vote_rounded, size: 44),
                ),
                const SizedBox(height: 22),
                Text(
                  'Ballot received',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your vote has been counted and your choice remains private.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: 26),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.receipt_long_outlined),
                          const SizedBox(width: 9),
                          Text(
                            'VOTE RECEIPT',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(letterSpacing: 1.3),
                          ),
                          const Spacer(),
                          const StatusPill(label: 'Counted'),
                        ],
                      ),
                      const Divider(height: 26),
                      _ReceiptLine(
                        'Election',
                        controller.selectedElection.title,
                      ),
                      _ReceiptLine('Class', controller.selectedElection.group),
                      _ReceiptLine(
                        'Ballot ID',
                        '#PK-${controller.selectedElection.id.toUpperCase()}-084',
                      ),
                      _ReceiptLine('Status', 'Encrypted & counted'),
                    ],
                  ),
                ),
                if (candidate != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CandidateAvatar(candidate: candidate, size: 42),
                      const SizedBox(width: 9),
                      Text(
                        'Selection recorded for ${candidate.name}',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onOpenResults,
                    icon: const Icon(Icons.bar_chart_rounded),
                    label: const Text('See live results'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReceiptLine extends StatelessWidget {
  const _ReceiptLine(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Text(
          value,
          textAlign: TextAlign.right,
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ],
    ),
  );
}

class _HowStep extends StatelessWidget {
  const _HowStep({
    required this.number,
    required this.title,
    required this.body,
  });
  final String number;
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            number,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              Text(body, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    ),
  );
}
