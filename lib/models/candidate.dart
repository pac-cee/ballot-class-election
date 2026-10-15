class Candidate {
  Candidate({
    required this.id,
    required this.name,
    this.votes = 0,
    this.position = 'Class Representative',
    this.slogan = 'A better class, together.',
    this.course = 'Senior 6 Science',
    this.year = 'Class of 2026',
    this.bio =
        'Student leader focused on practical ideas and an inclusive class.',
    this.colorValue = 0xFFB9F227,
    this.manifesto = const [
      'Listen first',
      'Publish class updates',
      'Make every voice count',
    ],
    this.endorsements = 0,
    this.isFollowing = false,
  });

  final int id;
  String name;
  int votes;
  String position;
  String slogan;
  String course;
  String year;
  String bio;
  int colorValue;
  List<String> manifesto;
  int endorsements;
  bool isFollowing;
}

class VoteRecord {
  const VoteRecord({
    required this.candidateId,
    required this.voterKey,
    this.electionId = 'main',
  });

  final int candidateId;
  final String voterKey;
  final String electionId;
}
