# Ballot — Class Election

Ballot gives a class a simple, honest way to vote once, see ranked results, preserve ties, and manage the ballot without a backend.

## Features

- Three screens: Vote, Results, and Candidates.
- Three sample candidates on first launch.
- Cleans every voter and candidate name by trimming spaces, collapsing repeated spaces, and applying Title Case.
- Treats names case-insensitively, so ` aline ` and `ALINE` are the same voter.
- Allows each cleaned voter name to vote only once.
- Supports Undo for the latest vote.
- Ranks candidates by votes, shows one-decimal percentages, and keeps equal scores tied.
- Shows **No votes yet** before the first vote instead of dividing by zero.
- Supports candidate create, read, edit, and delete operations.
- Refuses empty and duplicate candidate names during both add and edit.
- Prevents removing a candidate who already has votes.
- Resets all votes only after a clear confirmation dialog.
- Uses accessible labels, large touch targets, responsive content widths, and reduced-motion-aware floating notices.
- Includes a pulsing startup skeleton, animated screen changes, tactile vote feedback, and animated result bars.

## Screenshots

Screenshots are stored in `screenshots/`:

| Vote | Vote confirmation |
| --- | --- |
| ![Vote screen](screenshots/vote.png) | ![Modern vote confirmation](screenshots/vote-confirmation.png) |

| Results | Candidates |
| --- | --- |
| ![Ranked results](screenshots/results.png) | ![Candidate management](screenshots/candidates.png) |

## Business rules

Names are normalized before comparison so differences in spaces or capitalization cannot create duplicate voters or candidates. Results rank candidates by vote count, preserve all equal leaders as a true tie, and safely show zero percent before the first vote. All election rules live in `ElectionController`, outside widget `build` methods.

## Run

```sh
flutter pub get
flutter run
```

## Documentation

- [Architecture and business rules](docs/ARCHITECTURE.md)
- [Requirements and acceptance checklist](docs/REQUIREMENTS.md)

## Verify

```sh
flutter analyze
flutter test
flutter build ios --simulator
```
