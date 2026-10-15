import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_notice.dart';
import '../../core/widgets/candidate_sheet.dart';
import '../../core/widgets/election_ui.dart';
import '../../models/campaign_post.dart';
import '../../models/candidate.dart';
import '../../state/election_controller.dart';

class CandidatesScreen extends StatelessWidget {
  const CandidatesScreen({super.key, required this.controller});
  final ElectionController controller;

  @override
  Widget build(BuildContext context) {
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'THE CAMPAIGN FLOOR',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    letterSpacing: 1.5,
                                    color: AppColors.teal,
                                  ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              'Ideas before votes',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Follow candidates, compare their plans, and see what they post.',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                      IconButton.outlined(
                        onPressed: () => _manageBallot(context),
                        tooltip: 'Manage ballot',
                        icon: const Icon(Icons.tune_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 94,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.candidates.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final candidate = controller.candidates[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => showCandidateSheet(
                            context,
                            candidate: candidate,
                            controller: controller,
                          ),
                          child: Container(
                            width: 196,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                CandidateAvatar(
                                  candidate: candidate,
                                  size: 52,
                                  showVerified: true,
                                ),
                                const SizedBox(width: 11),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        candidate.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        '${candidate.endorsements} supporters',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 26),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Latest posts',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: () => _createPost(context),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Post'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Posting is mocked locally for the classroom demo.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  for (final post in controller.posts)
                    _CampaignPostTile(post: post, controller: controller),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createPost(BuildContext context) async {
    if (controller.candidates.isEmpty) return;
    final text = TextEditingController();
    var candidateId = controller.candidates.first.id;
    String? error;
    final posted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create campaign post'),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: candidateId,
                  decoration: const InputDecoration(
                    labelText: 'Posting as',
                    prefixIcon: Icon(Icons.campaign_outlined),
                  ),
                  items: [
                    for (final candidate in controller.candidates)
                      DropdownMenuItem(
                        value: candidate.id,
                        child: Text(candidate.name),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) candidateId = value;
                  },
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: text,
                  autofocus: true,
                  minLines: 4,
                  maxLines: 6,
                  maxLength: 220,
                  decoration: InputDecoration(
                    labelText: 'Campaign update',
                    hintText: 'Share one clear update with your class…',
                    alignLabelWithHint: true,
                    errorText: error,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final result = controller.addCampaignPost(
                  candidateId: candidateId,
                  body: text.text,
                );
                if (result == PostStatus.success) {
                  Navigator.pop(dialogContext, true);
                } else {
                  setState(
                    () => error = result == PostStatus.empty
                        ? 'Write something first'
                        : result == PostStatus.tooLong
                        ? 'Keep it under 220 characters'
                        : 'Candidate unavailable',
                  );
                }
              },
              child: const Text('Publish'),
            ),
          ],
        ),
      ),
    );
    text.dispose();
    if (posted == true && context.mounted) {
      showNotice(context, message: 'Campaign update published.');
    }
  }

  Future<void> _manageBallot(BuildContext context) async {
    final name = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            0,
            20,
            20 + MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ballot manager',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 5),
                Text(
                  'Teacher/demo controls for ${controller.selectedElection.group}.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: name,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Candidate name',
                          prefixIcon: Icon(Icons.person_add_alt_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        final result = controller.addCandidate(name.text);
                        if (result.status == AddCandidateStatus.success) {
                          name.clear();
                          setState(() {});
                          showNotice(
                            context,
                            message: '${result.candidate!.name} added.',
                          );
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 330),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: controller.candidates.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, index) {
                      final candidate = controller.candidates[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CandidateAvatar(
                          candidate: candidate,
                          size: 42,
                        ),
                        title: Text(candidate.name),
                        subtitle: Text('${candidate.votes} votes'),
                        trailing: IconButton(
                          tooltip: 'Remove ${candidate.name}',
                          onPressed: candidate.votes > 0
                              ? null
                              : () {
                                  controller.removeCandidate(candidate);
                                  setState(() {});
                                },
                          icon: Icon(
                            candidate.votes > 0
                                ? Icons.lock_outline_rounded
                                : Icons.delete_outline_rounded,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    name.dispose();
  }
}

class _CampaignPostTile extends StatelessWidget {
  const _CampaignPostTile({required this.post, required this.controller});
  final CampaignPost post;
  final ElectionController controller;

  @override
  Widget build(BuildContext context) {
    Candidate? candidate = controller.candidateById(post.candidateId);
    candidate ??= controller.candidates.isEmpty
        ? null
        : controller.candidates.first;
    if (candidate == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CandidateAvatar(candidate: candidate, size: 48, showVerified: true),
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
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Text(
                      post.timeLabel,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                Text(
                  candidate.course,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 10),
                Text(post.body, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 10),
                Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => controller.togglePostLike(post),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 5,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              post.isLiked
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              size: 19,
                              color: post.isLiked
                                  ? AppColors.coral
                                  : AppColors.muted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${post.likes}',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 18,
                      color: AppColors.muted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Reply',
                      style: Theme.of(context).textTheme.labelLarge,
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
