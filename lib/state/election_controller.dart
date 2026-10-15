import 'package:flutter/foundation.dart';

import '../models/campaign_post.dart';
import '../models/candidate.dart';
import '../models/election.dart';

enum VoteStatus {
  success,
  emptyName,
  alreadyVoted,
  candidateMissing,
  electionClosed,
}

enum AddCandidateStatus { success, emptyName, duplicate }

enum UpdateCandidateStatus { success, emptyName, duplicate, candidateMissing }

enum RemoveCandidateStatus { success, hasVotes, candidateMissing }

enum AuthStatus { success, invalidEmail, weakPassword, emptyName }

enum PostStatus { success, empty, tooLong, candidateMissing }

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
  ElectionController({
    List<Candidate>? candidates,
    List<ClassElection>? elections,
  }) : _elections =
           elections ??
           [
             ClassElection(
               id: 'main',
               title: 'Class Representative',
               group: 'Class 2026',
               status: ElectionStatus.live,
               candidates: candidates ?? [],
               eligibleVoters: 42,
               scheduleLabel: 'Closes today · 18:00',
               colorValue: 0xFFB9F227,
             ),
           ];

  factory ElectionController.withSamples() => ElectionController(
    candidates: [
      Candidate(id: 1, name: 'Keza Uwase'),
      Candidate(id: 2, name: 'Mutoni Alice'),
      Candidate(id: 3, name: 'Eric Mugisha'),
    ],
  );

  factory ElectionController.demo() => ElectionController(
    elections: [
      ClassElection(
        id: 's6-science',
        title: 'Class Representative',
        group: 'Senior 6 Science',
        status: ElectionStatus.live,
        eligibleVoters: 286,
        scheduleLabel: 'Closes today · 18:00',
        room: 'Main Hall',
        colorValue: 0xFFB9F227,
        candidates: [
          Candidate(
            id: 1,
            name: 'Keza Uwase',
            votes: 86,
            slogan: 'Make every school day count.',
            course: 'PCM',
            bio: 'Debate captain and science club mentor. Keza wants shorter feedback loops between students and teachers.',
            colorValue: 0xFFB9F227,
            manifesto: const [
              'Weekly class pulse',
              'Shared revision bank',
              'Transparent activity budget',
            ],
            endorsements: 74,
          ),
          Candidate(
            id: 2,
            name: 'Alice Mutoni',
            votes: 72,
            slogan: 'Your voice, in every decision.',
            course: 'MCB',
            bio: 'Peer counsellor and volleyball vice-captain, focused on wellbeing and fair access to class opportunities.',
            colorValue: 0xFFFF6B55,
            manifesto: const [
              'Anonymous idea box',
              'Monthly class forum',
              'Inclusive sports calendar',
            ],
            endorsements: 61,
          ),
          Candidate(
            id: 3,
            name: 'Eric Mugisha',
            votes: 55,
            slogan: 'Organised class. Bigger opportunities.',
            course: 'PCB',
            bio: 'Robotics lead who enjoys turning messy problems into clear systems the whole class can use.',
            colorValue: 0xFF59D2C9,
            manifesto: const [
              'Digital noticeboard',
              'Career guest series',
              'Project team matching',
            ],
            endorsements: 48,
          ),
          Candidate(
            id: 4,
            name: 'Aline Ishimwe',
            votes: 34,
            slogan: 'Lead with kindness. Deliver with courage.',
            course: 'HEG',
            bio: 'Library volunteer and arts coordinator building a campaign around belonging and creative student life.',
            colorValue: 0xFFFFC857,
            manifesto: const [
              'Student showcase day',
              'Buddy programme',
              'Open office hour',
            ],
            endorsements: 39,
          ),
        ],
      ),
      ClassElection(
        id: 'cs-y2',
        title: 'Course Delegate',
        group: 'Computer Science · Year 2',
        status: ElectionStatus.upcoming,
        eligibleVoters: 148,
        scheduleLabel: 'Opens Friday · 08:00',
        room: 'Online ballot',
        colorValue: 0xFF59D2C9,
        candidates: [
          Candidate(
            id: 21,
            name: 'Diane Uwera',
            course: 'Software Engineering',
            colorValue: 0xFF59D2C9,
          ),
          Candidate(
            id: 22,
            name: 'Yves Niyonzima',
            course: 'Data Science',
            colorValue: 0xFFFFC857,
          ),
        ],
      ),
      ClassElection(
        id: 'debate',
        title: 'Club President',
        group: 'Debate Society',
        status: ElectionStatus.closed,
        eligibleVoters: 84,
        scheduleLabel: 'Closed · Final result',
        room: 'Auditorium',
        colorValue: 0xFFFF6B55,
        candidates: [
          Candidate(
            id: 31,
            name: 'Doris Kayitesi',
            votes: 47,
            course: 'Arts',
            colorValue: 0xFFFF6B55,
          ),
          Candidate(
            id: 32,
            name: 'Patrick Ndayisaba',
            votes: 32,
            course: 'Science',
            colorValue: 0xFFB9F227,
          ),
        ],
      ),
    ],
  );

  final List<ClassElection> _elections;
  final Set<String> _voters = {};
  final List<VoteRecord> _history = [];
  final List<CampaignPost> _posts = [
    const CampaignPost(
      id: 1,
      candidateId: 1,
      body: 'I published the first draft of our shared revision-bank plan. Tell me which subject should come first.',
      timeLabel: '18 min',
      likes: 42,
    ),
    const CampaignPost(
      id: 2,
      candidateId: 2,
      body: 'Listening session tomorrow at lunch. No speeches—just your ideas about class wellbeing and fair opportunities.',
      timeLabel: '1 hr',
      likes: 37,
    ),
    const CampaignPost(
      id: 3,
      candidateId: 3,
      body: 'Prototype ready: one clean digital noticeboard for deadlines, teams, and opportunities. I will demo it after class.',
      timeLabel: '3 hr',
      likes: 29,
    ),
  ];
  int _nextId = 100;
  int _nextPostId = 10;
  int _selectedElectionIndex = 0;
  StudentProfile? _currentUser;

  List<ClassElection> get elections => List.unmodifiable(_elections);
  ClassElection get selectedElection => _elections[_selectedElectionIndex];
  int get selectedElectionIndex => _selectedElectionIndex;
  List<Candidate> get candidates =>
      List.unmodifiable(selectedElection.candidates);
  List<CampaignPost> get posts => List.unmodifiable(_posts);
  StudentProfile? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  int get totalVotes => candidates.fold(0, (sum, item) => sum + item.votes);
  int get voterCount =>
      _voters.where((key) => key.startsWith('${selectedElection.id}:')).length;
  bool get canUndo => _history.isNotEmpty;
  bool get hasVoted => selectedElection.votedCandidateId != null;

  int get turnoutPercent => selectedElection.eligibleVoters == 0
      ? 0
      : ((totalVotes / selectedElection.eligibleVoters) * 100)
            .clamp(0, 100)
            .round();

  List<Candidate> get rankedCandidates => [...candidates]
    ..sort((a, b) {
      final votes = b.votes.compareTo(a.votes);
      return votes != 0 ? votes : a.name.compareTo(b.name);
    });

  List<Candidate> get leaders {
    if (totalVotes == 0 || candidates.isEmpty) return [];
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

  double percentageFor(Candidate candidate) =>
      totalVotes == 0 ? 0 : candidate.votes / totalVotes;

  String cleanName(String value) {
    final words = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty);
    return words
        .map((word) {
          final lower = word.toLowerCase();
          return '${lower[0].toUpperCase()}${lower.substring(1)}';
        })
        .join(' ');
  }

  AuthStatus login({required String email, required String password}) {
    if (!_validEmail(email)) return AuthStatus.invalidEmail;
    if (password.length < 4) return AuthStatus.weakPassword;
    _currentUser = StudentProfile(
      name: _nameFromEmail(email),
      email: email.trim(),
      studentId: 'STU-2026-084',
      className: 'Senior 6 Science',
    );
    notifyListeners();
    return AuthStatus.success;
  }

  AuthStatus register({
    required String name,
    required String email,
    required String password,
  }) {
    final clean = cleanName(name);
    if (clean.isEmpty) return AuthStatus.emptyName;
    if (!_validEmail(email)) return AuthStatus.invalidEmail;
    if (password.length < 6) return AuthStatus.weakPassword;
    _currentUser = StudentProfile(
      name: clean,
      email: email.trim(),
      studentId: 'STU-2026-NEW',
      className: 'Senior 6 Science',
    );
    notifyListeners();
    return AuthStatus.success;
  }

  void continueDemo() {
    _currentUser = const StudentProfile(
      name: 'Aline Uwase',
      email: 'aline@school.edu',
      studentId: 'STU-2026-084',
      className: 'Senior 6 Science',
    );
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void selectElection(int index) {
    if (index < 0 ||
        index >= _elections.length ||
        index == _selectedElectionIndex) {
      return;
    }
    _selectedElectionIndex = index;
    notifyListeners();
  }

  VoteResult vote({required String voterName, required int candidateId}) {
    final cleanVoter = cleanName(voterName);
    if (cleanVoter.isEmpty) return const VoteResult(VoteStatus.emptyName);
    if (selectedElection.status != ElectionStatus.live) {
      return const VoteResult(VoteStatus.electionClosed);
    }
    final voterKey = '${selectedElection.id}:${cleanVoter.toLowerCase()}';
    if (_voters.contains(voterKey)) {
      return VoteResult(VoteStatus.alreadyVoted, voterName: cleanVoter);
    }
    final candidate = _candidateById(candidateId);
    if (candidate == null) return const VoteResult(VoteStatus.candidateMissing);
    candidate.votes++;
    if (_currentUser != null &&
        cleanVoter.toLowerCase() == _currentUser!.name.toLowerCase()) {
      selectedElection.votedCandidateId = candidate.id;
    }
    _voters.add(voterKey);
    _history.add(
      VoteRecord(
        candidateId: candidate.id,
        voterKey: voterKey,
        electionId: selectedElection.id,
      ),
    );
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
    ClassElection? election;
    for (final item in _elections) {
      if (item.id == vote.electionId) election = item;
    }
    Candidate? candidate;
    for (final item in election?.candidates ?? <Candidate>[]) {
      if (item.id == vote.candidateId) candidate = item;
    }
    if (candidate != null && candidate.votes > 0) candidate.votes--;
    if (election?.votedCandidateId == vote.candidateId) {
      election?.votedCandidateId = null;
    }
    _voters.remove(vote.voterKey);
    notifyListeners();
    return true;
  }

  void toggleFollow(Candidate candidate) {
    candidate.isFollowing = !candidate.isFollowing;
    notifyListeners();
  }

  PostStatus addCampaignPost({required int candidateId, required String body}) {
    final clean = body.trim();
    if (clean.isEmpty) return PostStatus.empty;
    if (clean.length > 220) return PostStatus.tooLong;
    if (_candidateById(candidateId) == null) return PostStatus.candidateMissing;
    _posts.insert(
      0,
      CampaignPost(
        id: _nextPostId++,
        candidateId: candidateId,
        body: clean,
        timeLabel: 'now',
        likes: 0,
      ),
    );
    notifyListeners();
    return PostStatus.success;
  }

  void togglePostLike(CampaignPost post) {
    final index = _posts.indexWhere((item) => item.id == post.id);
    if (index == -1) return;
    _posts[index] = post.copyWith(
      likes: post.likes + (post.isLiked ? -1 : 1),
      isLiked: !post.isLiked,
    );
    notifyListeners();
  }

  Candidate? candidateById(int id) => _candidateById(id);

  AddCandidateResult addCandidate(String value) {
    final name = cleanName(value);
    if (name.isEmpty) {
      return const AddCandidateResult(AddCandidateStatus.emptyName);
    }
    if (candidates.any(
      (item) => item.name.toLowerCase() == name.toLowerCase(),
    )) {
      return const AddCandidateResult(AddCandidateStatus.duplicate);
    }
    final candidate = Candidate(id: _nextId++, name: name);
    selectedElection.candidates.add(candidate);
    notifyListeners();
    return AddCandidateResult(AddCandidateStatus.success, candidate: candidate);
  }

  UpdateCandidateStatus updateCandidate(Candidate candidate, String value) {
    if (!selectedElection.candidates.contains(candidate)) {
      return UpdateCandidateStatus.candidateMissing;
    }
    final name = cleanName(value);
    if (name.isEmpty) return UpdateCandidateStatus.emptyName;
    if (candidates.any(
      (item) =>
          item.id != candidate.id &&
          item.name.toLowerCase() == name.toLowerCase(),
    )) {
      return UpdateCandidateStatus.duplicate;
    }
    candidate.name = name;
    notifyListeners();
    return UpdateCandidateStatus.success;
  }

  RemoveCandidateStatus removeCandidate(Candidate candidate) {
    if (!selectedElection.candidates.contains(candidate)) {
      return RemoveCandidateStatus.candidateMissing;
    }
    if (candidate.votes > 0) return RemoveCandidateStatus.hasVotes;
    selectedElection.candidates.remove(candidate);
    notifyListeners();
    return RemoveCandidateStatus.success;
  }

  void resetVotes() {
    for (final candidate in candidates) {
      candidate.votes = 0;
    }
    _voters.removeWhere((key) => key.startsWith('${selectedElection.id}:'));
    _history.removeWhere((item) => item.electionId == selectedElection.id);
    selectedElection.votedCandidateId = null;
    notifyListeners();
  }

  Candidate? _candidateById(int id) {
    for (final candidate in selectedElection.candidates) {
      if (candidate.id == id) return candidate;
    }
    return null;
  }

  bool _validEmail(String value) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());
  String _nameFromEmail(String email) =>
      cleanName(email.split('@').first.replaceAll(RegExp(r'[._-]+'), ' '));

  String _joinNames(List<String> names) {
    if (names.length < 2) return names.join();
    if (names.length == 2) return '${names.first} and ${names.last}';
    return '${names.sublist(0, names.length - 1).join(', ')}, and ${names.last}';
  }
}
