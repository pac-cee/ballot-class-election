# Ballot Architecture

## Overview

Ballot is a local-state Flutter application with no backend. `ElectionController` is the authoritative source for candidate data, voter identities, vote history, rankings, and validation. Screens only collect input, call controller methods, and render the result.

```text
Vote / Results / Candidates screens
                 |
                 v
         ElectionController
          /       |       \
 candidates    voters    vote history
```

## Main modules

| Area | Responsibility |
| --- | --- |
| `lib/features/vote/` | Voter input, candidate selection, vote submission |
| `lib/features/results/` | Ranking, percentages, winner or true tie presentation |
| `lib/features/candidates/` | Candidate create, edit, and delete workflows |
| `lib/state/election_controller.dart` | All election rules and mutations |
| `lib/navigation/election_shell.dart` | Three-screen navigation and transitions |
| `lib/core/` | Theme, page headers, top notices, and loading skeleton |
| `lib/models/candidate.dart` | Candidate and vote-record models |

## Election rules

- Names are trimmed, repeated spaces collapse, and display names use Title Case.
- Comparisons are case-insensitive, so formatting cannot bypass duplicate checks.
- A cleaned voter identity can vote once.
- Voting is refused when the voter is empty, has voted, or the candidate is unavailable.
- Results sort by vote count, then candidate name for deterministic equal-score ordering.
- Percentages return zero before the first vote, avoiding division by zero and `NaN`.
- Every candidate sharing the highest score is preserved as a true tie.
- Undo reverses only the latest vote and releases that voter identity.
- Reset clears votes, voters, and history while preserving the candidate list.

## Candidate CRUD

| Operation | Rule |
| --- | --- |
| Create | Non-empty and unique after normalization |
| Read | Exposed as an unmodifiable list |
| Update | Existing candidate; non-empty and unique name |
| Delete | Existing candidate with zero votes only |

## Motion system

Ballot uses motion to communicate state rather than decorate it:

1. A pulsing skeleton indicates the initial preparation state.
2. The application fades and slides into place when ready.
3. Screen changes animate through a controlled `PageView` transition.
4. Candidate cards scale slightly during selection.
5. Result bars animate from zero to their calculated share.
6. Confirmation notices slide and fade from the top.

Reduced-motion settings replace or shorten nonessential transitions.

## Feedback and accessibility

Success and error notices appear at the top, include a status icon, and expose Undo only when it is valid. Reset and destructive actions use explicit confirmation. Interactive elements use semantic labels, readable contrast, and large touch targets.

## Verification

```sh
flutter analyze
flutter test
flutter build ios --simulator
```

Controller tests cover voting, duplicate prevention, ranking, percentages, ties, full candidate CRUD, Undo, and reset.
