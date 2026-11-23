# App and persistence

## Source

- [FlashCardsApp.swift](../../FlashCards/App/FlashCardsApp.swift) owns app launch, Today and Decks tabs, and the shared SwiftData container.
- [Deck.swift](../../FlashCards/Models/Deck.swift) and [Flashcard.swift](../../FlashCards/Models/Flashcard.swift) define the persisted models.

## Data flow

- The app's container registers both models. Today queries flashcards and Decks queries decks through the same container. Deck detail and study screens receive model instances from those entry points.
- `Deck` has a name, creation date, optional backup UUID, and a cascade relationship to its cards. The inverse is `Flashcard.deck`.
- `Flashcard` stores front, back, vocabulary type raw value, review date, interval in days, and optional backup UUID. The computed vocabulary enum bridges to the raw value. Both model initializers generate backup IDs.
- A missing review date means due immediately. A scheduled card is due at or after its timestamp. Today, deck rows, deck detail, and review use the same predicate.
- Normal edits mutate SwiftData models in the shared context. JSON transport uses separate snapshots. Review and reminder preferences use `@AppStorage` and sit outside the model store.

## Verification

Create a deck and card, relaunch the app, and verify both tabs show the same stored data. Confirm that deleting the deck removes its cards from Today. Check the [backup context](backup-and-restore.md) when adding a persisted field. Several previews use in-memory storage. The existing XCTest targets contain template tests.
