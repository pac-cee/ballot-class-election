import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_notice.dart';
import '../../core/widgets/page_header.dart';
import '../../models/candidate.dart';
import '../../state/election_controller.dart';

class VoteScreen extends StatefulWidget {
  const VoteScreen({super.key, required this.controller});

  final ElectionController controller;

  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  final voterController = TextEditingController();
  final voterFocusNode = FocusNode();

  @override
  void dispose() {
    voterController.dispose();
    voterFocusNode.dispose();
    super.dispose();
  }

  void submitVote(Candidate candidate) {
    final result = widget.controller.vote(
      voterName: voterController.text,
      candidateId: candidate.id,
    );
    switch (result.status) {
      case VoteStatus.success:
        voterController.clear();
        voterFocusNode.unfocus();
        showNotice(
          context,
          message: '${result.voterName} voted for ${candidate.name}.',
          actionLabel: 'Undo',
          onAction: widget.controller.undoLastVote,
        );
      case VoteStatus.emptyName:
        voterFocusNode.requestFocus();
        showNotice(
          context,
          message: 'Enter your name before choosing a candidate.',
          tone: NoticeTone.error,
        );
      case VoteStatus.alreadyVoted:
        voterFocusNode.requestFocus();
        showNotice(
          context,
          message: '${result.voterName} has already voted.',
          tone: NoticeTone.error,
        );
      case VoteStatus.candidateMissing:
        showNotice(
          context,
          message: 'That candidate is no longer available.',
          tone: NoticeTone.error,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                      const PageHeader(
                        eyebrow: 'Ballot · Class 2026',
                        title: 'Choose your representative',
                        description: 'Enter your name once, then vote for one candidate.',
                      ),
                      const SizedBox(height: 22),
                      _ElectionPulse(controller: widget.controller),
                      const SizedBox(height: 22),
                      TextField(
                        controller: voterController,
                        focusNode: voterFocusNode,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: 'Your name',
                          hintText: 'Aline Uwase',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                          helperText: 'Use the name on your class list.',
                        ),
                      ),
                      const SizedBox(height: 26),
                      Row(
                        children: [
                          Text(
                            'Candidates',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Spacer(),
                          Text(
                            '${widget.controller.candidates.length} running',
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
          if (widget.controller.candidates.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('No candidates yet')),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              sliver: SliverList.separated(
                itemCount: widget.controller.candidates.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final candidate = widget.controller.candidates[index];
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: _CandidateBallotRow(
                        candidate: candidate,
                        position: index + 1,
                        onVote: () => submitVote(candidate),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ElectionPulse extends StatelessWidget {
  const _ElectionPulse({required this.controller});

  final ElectionController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.ballot_outlined, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${controller.totalVotes} ${controller.totalVotes == 1 ? 'vote' : 'votes'} cast',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(color: Colors.white),
            ),
          ),
          Text(
            '${controller.voterCount} verified',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: const Color(0xFFC8D7E5)),
          ),
        ],
      ),
    );
  }
}

class _CandidateBallotRow extends StatefulWidget {
  const _CandidateBallotRow({
    required this.candidate,
    required this.position,
    required this.onVote,
  });

  final Candidate candidate;
  final int position;
  final VoidCallback onVote;

  @override
  State<_CandidateBallotRow> createState() => _CandidateBallotRowState();
}

class _CandidateBallotRowState extends State<_CandidateBallotRow> {
  bool pressed = false;

  Future<void> vote() async {
    setState(() => pressed = true);
    widget.onVote();
    await Future<void>.delayed(const Duration(milliseconds: 140));
    if (mounted) setState(() => pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final initials = widget.candidate.name
        .split(' ')
        .take(2)
        .map((part) => part[0])
        .join();
    return AnimatedScale(
      scale: pressed && !MediaQuery.disableAnimationsOf(context) ? 0.985 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  initials,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.candidate.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Candidate ${widget.position.toString().padLeft(2, '0')}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(onPressed: vote, child: const Text('Vote')),
            ],
          ),
        ),
      ),
    );
  }
}
