import 'package:flutter/foundation.dart';

import '../models/candidate.dart';

enum VoteStatus { success, emptyName, alreadyVoted, candidateMissing }

enum AddCandidateStatus { success, emptyName, duplicate }

enum UpdateCandidateStatus { success, emptyName, duplicate, candidateMissing }

enum RemoveCandidateStatus { success, hasVotes, candidateMissing }

class VoteResult {
  const VoteResult(this.status, {this.voterName, this.candidate});

  final VoteStatus status;
  final String? voterName;
  final Candidate? candidate;
}

class AddCandidateResult {
  const AddCandidateResult(this.status, {this.candidate});

  final AddCandidateStatus status;
  final Candidate? candidate;
}

class ElectionController extends ChangeNotifier {
  ElectionController({List<Candidate>? candidates})
    : _candidates = candidates ?? [];

  factory ElectionController.withSamples() {
    return ElectionController(
      candidates: [
        Candidate(id: 1, name: 'Keza Uwase'),
        Candidate(id: 2, name: 'Mutoni Alice'),
        Candidate(id: 3, name: 'Eric Mugisha'),
      ],
    );
  }

  final List<Candidate> _candidates;
  final Set<String> _voters = {};
  final List<VoteRecord> _history = [];
  int _nextId = 100;

  List<Candidate> get candidates => List.unmodifiable(_candidates);
  int get totalVotes => _candidates.fold(0, (sum, item) => sum + item.votes);
  int get voterCount => _voters.length;
  bool get canUndo => _history.isNotEmpty;

  List<Candidate> get rankedCandidates {
    return [..._candidates]..sort((first, second) {
      final byVotes = second.votes.compareTo(first.votes);
      if (byVotes != 0) return byVotes;
      return first.name.compareTo(second.name);
    });
  }

  List<Candidate> get leaders {
    if (totalVotes == 0 || _candidates.isEmpty) return [];
    final highest = rankedCandidates.first.votes;
    return rankedCandidates.where((item) => item.votes == highest).toList();
  }

  String get resultSummary {
    final currentLeaders = leaders;
    if (currentLeaders.isEmpty) return 'No votes yet';
    if (currentLeaders.length == 1) {
      return 'Winner: ${currentLeaders.first.name}';
    }
    final names = _joinNames(currentLeaders.map((item) => item.name).toList());
    final votes = currentLeaders.first.votes;
    return 'Tie between $names ($votes ${votes == 1 ? 'vote' : 'votes'} each)';
  }

  double percentageFor(Candidate candidate) {
    if (totalVotes == 0) return 0;
    return candidate.votes / totalVotes;
  }

  String cleanName(String value) {
    final words = value.trim().split(RegExp(r'\s+')).where((word) {
      return word.isNotEmpty;
    });
    return words
        .map((word) {
          final lower = word.toLowerCase();
          return '${lower[0].toUpperCase()}${lower.substring(1)}';
        })
        .join(' ');
  }

  VoteResult vote({required String voterName, required int candidateId}) {
    final cleanVoter = cleanName(voterName);
    if (cleanVoter.isEmpty) return const VoteResult(VoteStatus.emptyName);

    final voterKey = cleanVoter.toLowerCase();
    if (_voters.contains(voterKey)) {
      return VoteResult(VoteStatus.alreadyVoted, voterName: cleanVoter);
    }

    final candidate = _candidateById(candidateId);
    if (candidate == null) {
      return const VoteResult(VoteStatus.candidateMissing);
    }

    candidate.votes++;
    _voters.add(voterKey);
    _history.add(VoteRecord(candidateId: candidate.id, voterKey: voterKey));
    notifyListeners();
    return VoteResult(
      VoteStatus.success,
      voterName: cleanVoter,
      candidate: candidate,
    );
  }

  bool undoLastVote() {
    if (_history.isEmpty) return false;
    final vote = _history.removeLast();
    final candidate = _candidateById(vote.candidateId);
    if (candidate != null && candidate.votes > 0) candidate.votes--;
    _voters.remove(vote.voterKey);
    notifyListeners();
    return true;
  }

  AddCandidateResult addCandidate(String value) {
    final name = cleanName(value);
    if (name.isEmpty) {
      return const AddCandidateResult(AddCandidateStatus.emptyName);
    }
    final duplicate = _candidates.any(
      (candidate) => candidate.name.toLowerCase() == name.toLowerCase(),
    );
    if (duplicate) {
      return const AddCandidateResult(AddCandidateStatus.duplicate);
    }

    final candidate = Candidate(id: _nextId++, name: name);
    _candidates.add(candidate);
    notifyListeners();
    return AddCandidateResult(AddCandidateStatus.success, candidate: candidate);
  }

  UpdateCandidateStatus updateCandidate(Candidate candidate, String value) {
    if (!_candidates.contains(candidate)) {
      return UpdateCandidateStatus.candidateMissing;
    }
    final name = cleanName(value);
    if (name.isEmpty) return UpdateCandidateStatus.emptyName;
    final duplicate = _candidates.any(
      (item) =>
          item.id != candidate.id &&
          item.name.toLowerCase() == name.toLowerCase(),
    );
    if (duplicate) return UpdateCandidateStatus.duplicate;
    candidate.name = name;
    notifyListeners();
    return UpdateCandidateStatus.success;
  }

  RemoveCandidateStatus removeCandidate(Candidate candidate) {
    if (!_candidates.contains(candidate)) {
      return RemoveCandidateStatus.candidateMissing;
    }
    if (candidate.votes > 0) return RemoveCandidateStatus.hasVotes;
    _candidates.remove(candidate);
    notifyListeners();
    return RemoveCandidateStatus.success;
  }

  void resetVotes() {
    for (final candidate in _candidates) {
      candidate.votes = 0;
    }
    _voters.clear();
    _history.clear();
    notifyListeners();
  }

  Candidate? _candidateById(int id) {
    for (final candidate in _candidates) {
      if (candidate.id == id) return candidate;
    }
    return null;
  }

  String _joinNames(List<String> names) {
    if (names.length < 2) return names.join();
    if (names.length == 2) return '${names.first} and ${names.last}';
    return '${names.sublist(0, names.length - 1).join(', ')}, and ${names.last}';
  }
}
