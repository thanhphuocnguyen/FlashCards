# Backup and restore

- [DeckListView.swift](../../FlashCards/Features/Decks/DeckListView.swift) owns the Backup menu, file pickers, import and export alerts, and SwiftData restore logic.
- [FlashcardsBackup.swift](../../FlashCards/Backup/FlashcardsBackup.swift) defines the Codable envelope. Export writes version 2 and import accepts versions 1 and 2. [BackupDocument.swift](../../FlashCards/Backup/BackupDocument.swift) wraps JSON bytes for the exporter.
- Deck snapshots contain `backupID`, `name`, `createdAt`, and cards. Card snapshots contain `backupID`, `front`, `back`, `vocabTypeRawVal`, `nextReviewAt`, and `intervalDays`. Optional fields can be omitted. Dates use the default JSONEncoder/JSONDecoder strategy, meaning numeric seconds from the Foundation reference date (2001-01-01 UTC).
- Export assigns missing UUIDs before encoding. Import opens a security-scoped URL, decodes and checks the version, then saves outstanding changes before merging. If the final save fails, it rolls back the pending import changes. The success alert reports newly added decks and cards.

## How matching works

| Input | Current behavior |
| --- | --- |
| Deck UUID matches an existing deck | Appends unseen card UUIDs. Existing card content and schedules are preserved. ID-less cards in that matched deck are skipped. |
| Deck UUID is new or absent | Creates a deck, collapses repeated non-nil card UUIDs inside the snapshot, and generates IDs where absent. |
| Same front/back with different UUIDs | Both cards can be imported. Matching uses identity. |
| Same ID-less deck imported twice | Each import creates another deck. |

**Check** round-trip export with vocabulary types and scheduled cards, importing an unchanged UUID-based backup twice, importing a version 1 fixture, and importing a file without UUIDs. Check that unsupported versions leave the store intact. The current picker accepts JSON.
