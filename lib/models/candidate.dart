class Candidate {
  Candidate({required this.id, required this.name, this.votes = 0});

  final int id;
  String name;
  int votes;
}

class VoteRecord {
  const VoteRecord({required this.candidateId, required this.voterKey});

  final int candidateId;
  final String voterKey;
}
