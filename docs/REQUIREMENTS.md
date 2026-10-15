# Ballot Requirements

## Class Election acceptance checklist

- [x] Starts with three sample candidates.
- [x] Cleans voter and candidate names consistently.
- [x] Allows one vote per cleaned voter identity.
- [x] Ranks candidates by votes and displays percentages.
- [x] Represents equal top scores as a true tie.
- [x] Handles zero votes without `NaN` or misleading winners.
- [x] Supports candidate create, read, update, and delete.
- [x] Rejects empty and duplicate candidate names.
- [x] Prevents deletion of a candidate with votes.
- [x] Resets votes only after confirmation.
- [x] Separates Vote, Results, and Candidates into three screens.
- [x] Keeps all business rules outside widget `build` methods.

## Experience checklist

- [x] Clear light civic color system with blue, navy, and restrained gold.
- [x] Startup skeleton and visible loading state.
- [x] At least three purposeful animations and screen transitions.
- [x] Animated progress bars communicate result proportions.
- [x] Modern top confirmations with contextual Undo.
- [x] Icons support actions without replacing important labels.
- [x] Reduced-motion behavior and semantic accessibility labels.
- [x] No developer instructions, AI language, or implementation notes in the interface.

## Manual quality checks

1. Submit an empty voter name and confirm a clear inline response.
2. Vote as ` aline ` and then `ALINE`; confirm the second vote is refused.
3. Create or rename a candidate using an existing name; confirm it is refused.
4. Build a tie and confirm every tied leader is named.
5. Undo the latest vote and confirm both count and voter eligibility revert.
6. Try to remove a candidate with votes and confirm the record is protected.
7. Reset votes and confirm candidates remain while all results return to zero.

## Scope

Ballot intentionally stores state for the running session. Authentication, identity verification, remote synchronization, and a backend are outside this design prototype.
