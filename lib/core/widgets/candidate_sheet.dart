import 'package:flutter/material.dart';

import '../../models/candidate.dart';
import '../../state/election_controller.dart';
import '../theme/app_theme.dart';
import 'election_ui.dart';

Future<void> showCandidateSheet(
  BuildContext context, {
  required Candidate candidate,
  required ElectionController controller,
  VoidCallback? onVote,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          4,
          24,
          24 + MediaQuery.viewPaddingOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CandidateAvatar(
                  candidate: candidate,
                  size: 76,
                  showVerified: true,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        candidate.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${candidate.course} · ${candidate.year}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 9),
                      StatusPill(
                        label: '${candidate.endorsements} supporters',
                        color: Color(candidate.colorValue),
                        icon: Icons.people_alt_outlined,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              candidate.slogan,
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontSize: 26),
            ),
            const SizedBox(height: 10),
            Text(
              candidate.bio,
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 24),
            Text(
              'MY THREE COMMITMENTS',
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(letterSpacing: 1.5, color: AppColors.muted),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < candidate.manifesto.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Color(candidate.colorValue)
                            .withValues(alpha: .22),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        candidate.manifesto[i],
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => controller.toggleFollow(candidate),
                    icon: Icon(
                      candidate.isFollowing
                          ? Icons.check_rounded
                          : Icons.add_rounded,
                    ),
                    label: Text(
                      candidate.isFollowing ? 'Following' : 'Follow campaign',
                    ),
                  ),
                ),
                if (onVote != null) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onVote();
                      },
                      icon: const Icon(Icons.how_to_vote_outlined),
                      label: const Text('Choose'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
