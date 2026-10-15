import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_notice.dart';
import '../../core/widgets/page_header.dart';
import '../../models/candidate.dart';
import '../../state/election_controller.dart';

class CandidatesScreen extends StatefulWidget {
  const CandidatesScreen({super.key, required this.controller});

  final ElectionController controller;

  @override
  State<CandidatesScreen> createState() => _CandidatesScreenState();
}

class _CandidatesScreenState extends State<CandidatesScreen> {
  final nameController = TextEditingController();
  final nameFocusNode = FocusNode();

  @override
  void dispose() {
    nameController.dispose();
    nameFocusNode.dispose();
    super.dispose();
  }

  void addCandidate() {
    final result = widget.controller.addCandidate(nameController.text);
    switch (result.status) {
      case AddCandidateStatus.success:
        nameController.clear();
        nameFocusNode.unfocus();
        showNotice(
          context,
          message: '${result.candidate!.name} joined the ballot.',
        );
      case AddCandidateStatus.emptyName:
        nameFocusNode.requestFocus();
        showNotice(
          context,
          message: 'Enter a candidate name.',
          tone: NoticeTone.error,
        );
      case AddCandidateStatus.duplicate:
        nameFocusNode.requestFocus();
        showNotice(
          context,
          message: 'That candidate is already on the ballot.',
          tone: NoticeTone.error,
        );
    }
  }

  void removeCandidate(Candidate candidate) {
    final result = widget.controller.removeCandidate(candidate);
    switch (result) {
      case RemoveCandidateStatus.success:
        showNotice(
          context,
          message: '${candidate.name} was removed.',
          tone: NoticeTone.info,
        );
      case RemoveCandidateStatus.hasVotes:
        showNotice(
          context,
          message: '${candidate.name} has votes and cannot be removed.',
          tone: NoticeTone.error,
        );
      case RemoveCandidateStatus.candidateMissing:
        showNotice(
          context,
          message: 'That candidate is no longer on the ballot.',
          tone: NoticeTone.error,
        );
    }
  }

  Future<void> editCandidate(Candidate candidate) async {
    final editController = TextEditingController(text: candidate.name);
    String? errorText;
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          void save() {
            final result = widget.controller.updateCandidate(
              candidate,
              editController.text,
            );
            if (result == UpdateCandidateStatus.success) {
              Navigator.of(dialogContext).pop(true);
              return;
            }
            setDialogState(() {
              errorText = switch (result) {
                UpdateCandidateStatus.emptyName => 'Enter a candidate name',
                UpdateCandidateStatus.duplicate =>
                  'That candidate is already on the ballot',
                UpdateCandidateStatus.candidateMissing =>
                  'That candidate is no longer available',
                UpdateCandidateStatus.success => null,
              };
            });
          }

          return AlertDialog(
            title: const Text('Edit Candidate'),
            content: TextField(
              controller: editController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Candidate name',
                errorText: errorText,
              ),
              onSubmitted: (_) => save(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(onPressed: save, child: const Text('Save Changes')),
            ],
          );
        },
      ),
    );
    editController.dispose();
    if (saved == true && mounted) {
      showNotice(context, message: '${candidate.name} was updated.');
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
                        eyebrow: 'Ballot setup',
                        title: 'Manage candidates',
                        description: 'Add or rename a candidate. Remove anyone with no votes.',
                      ),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: nameController,
                              focusNode: nameFocusNode,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => addCandidate(),
                              decoration: const InputDecoration(
                                labelText: 'Candidate name',
                                hintText: 'Keza Uwase',
                                prefixIcon: Icon(
                                  Icons.person_add_alt_1_outlined,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          FilledButton(
                            onPressed: addCandidate,
                            child: const Text('Add'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 26),
                      Row(
                        children: [
                          Text(
                            'On the ballot',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Spacer(),
                          Text(
                            '${widget.controller.candidates.length} total',
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
              child: Center(child: Text('No candidates yet. Add one above.')),
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
                      child: _CandidateAdminRow(
                        candidate: candidate,
                        onEdit: () => editCandidate(candidate),
                        onRemove: () => removeCandidate(candidate),
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

class _CandidateAdminRow extends StatelessWidget {
  const _CandidateAdminRow({
    required this.candidate,
    required this.onEdit,
    required this.onRemove,
  });

  final Candidate candidate;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final locked = candidate.votes > 0;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        leading: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F0FF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.person_outline, color: AppColors.primary),
        ),
        title: Text(candidate.name),
        subtitle: Text(
          locked
              ? '${candidate.votes} ${candidate.votes == 1 ? 'vote' : 'votes'} · Locked'
              : 'No votes · Can be removed',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onEdit,
              tooltip: 'Edit ${candidate.name}',
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              onPressed: onRemove,
              tooltip: locked
                  ? '${candidate.name} cannot be removed after voting starts'
                  : 'Remove ${candidate.name}',
              color: locked ? AppColors.muted : AppColors.danger,
              icon: Icon(locked ? Icons.lock_outline : Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}
