import 'candidate.dart';

enum ElectionStatus { live, upcoming, closed }

class ClassElection {
  ClassElection({
    required this.id,
    required this.title,
    required this.group,
    required this.status,
    required this.candidates,
    required this.eligibleVoters,
    required this.scheduleLabel,
    required this.colorValue,
    this.room = '',
    this.votedCandidateId,
  });

  final String id;
  final String title;
  final String group;
  final ElectionStatus status;
  final List<Candidate> candidates;
  final int eligibleVoters;
  final String scheduleLabel;
  final int colorValue;
  final String room;
  int? votedCandidateId;
}

class StudentProfile {
  const StudentProfile({
    required this.name,
    required this.email,
    required this.studentId,
    required this.className,
  });
  final String name;
  final String email;
  final String studentId;
  final String className;
}
