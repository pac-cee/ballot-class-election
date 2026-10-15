import 'package:class_election/models/candidate.dart';
import 'package:class_election/state/election_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ElectionController', () {
    test('cleans names before storing and comparing voters', () {
      final controller = ElectionController.withSamples();

      final first = controller.vote(
        voterName: '  aLINE   uWASE ',
        candidateId: 1,
      );
      final duplicate = controller.vote(
        voterName: 'Aline Uwase',
        candidateId: 2,
      );

      expect(first.status, VoteStatus.success);
      expect(first.voterName, 'Aline Uwase');
      expect(duplicate.status, VoteStatus.alreadyVoted);
      expect(controller.totalVotes, 1);
    });

    test('ranks candidates and calculates one-decimal-ready percentages', () {
      final candidates = [
        Candidate(id: 1, name: 'Keza', votes: 4),
        Candidate(id: 2, name: 'Mutoni', votes: 4),
        Candidate(id: 3, name: 'Eric', votes: 1),
      ];
      final controller = ElectionController(candidates: candidates);

      expect(controller.rankedCandidates.map((item) => item.votes), [4, 4, 1]);
      expect(
        controller.percentageFor(candidates[0]) * 100,
        closeTo(44.4, 0.05),
      );
      expect(
        controller.percentageFor(candidates[2]) * 100,
        closeTo(11.1, 0.05),
      );
      expect(
        controller.resultSummary,
        'Tie between Keza and Mutoni (4 votes each)',
      );
    });

    test('zero votes has a safe summary and zero percentages', () {
      final controller = ElectionController.withSamples();

      expect(controller.resultSummary, 'No votes yet');
      expect(controller.percentageFor(controller.candidates.first), 0);
    });

    test('candidate names cannot be empty or duplicated after cleaning', () {
      final controller = ElectionController.withSamples();

      final empty = controller.addCandidate('   ');
      final duplicate = controller.addCandidate('  kEZA   uWASE ');

      expect(empty.status, AddCandidateStatus.emptyName);
      expect(duplicate.status, AddCandidateStatus.duplicate);
      expect(controller.candidates, hasLength(3));
    });

    test('candidate with votes cannot be removed', () {
      final controller = ElectionController.withSamples();
      final candidate = controller.candidates.first;
      controller.vote(voterName: 'Aline', candidateId: candidate.id);

      final result = controller.removeCandidate(candidate);

      expect(result, RemoveCandidateStatus.hasVotes);
      expect(controller.candidates, contains(candidate));
    });

    test('candidate can be renamed but not to a duplicate or empty name', () {
      final controller = ElectionController.withSamples();
      final candidate = controller.candidates.last;

      final renamed = controller.updateCandidate(candidate, '  eric   kay ');
      final duplicate = controller.updateCandidate(candidate, ' KEZA uwase ');
      final empty = controller.updateCandidate(candidate, '   ');

      expect(renamed, UpdateCandidateStatus.success);
      expect(candidate.name, 'Eric Kay');
      expect(duplicate, UpdateCandidateStatus.duplicate);
      expect(empty, UpdateCandidateStatus.emptyName);
      expect(candidate.name, 'Eric Kay');
    });

    test('undo allows the same voter to vote again', () {
      final controller = ElectionController.withSamples();
      controller.vote(voterName: 'Aline', candidateId: 1);

      expect(controller.undoLastVote(), isTrue);
      final second = controller.vote(voterName: ' aline ', candidateId: 2);

      expect(second.status, VoteStatus.success);
      expect(controller.totalVotes, 1);
    });

    test('reset clears votes and voter history but keeps candidates', () {
      final controller = ElectionController.withSamples();
      controller.vote(voterName: 'Aline', candidateId: 1);
      controller.vote(voterName: 'Eric', candidateId: 2);

      controller.resetVotes();

      expect(controller.totalVotes, 0);
      expect(controller.voterCount, 0);
      expect(controller.canUndo, isFalse);
      expect(controller.candidates, hasLength(3));
      expect(controller.resultSummary, 'No votes yet');
    });
  });
}
