# Deck management

- [DeckListView.swift](../../FlashCards/Features/Decks/DeckListView.swift) lists decks newest first using `createdAt`. The plus button opens a naming alert. Creation trims the name and rejects blank input before inserting the deck.
- [DeckRow.swift](../../FlashCards/Features/Decks/DeckRow.swift) navigates to the detail screen and shows due and total counts. It computes due against `Date.now` when the row renders. The row sends a delete request back to the list, which owns the confirm alert and deletion.
- [DeckDetailView.swift](../../FlashCards/Features/Decks/DeckDetailView.swift) owns the rename alert, card operations, and study links. Rename trims the input and preserves the deck's identity. Its due label uses a 15-second timeline. Both study links are disabled for empty decks. A nonempty deck with zero due can still open review and reach its empty state.
- Confirmed deck deletion cascades to cards via the [Deck model](../../FlashCards/Models/Deck.swift).

**Check** blank names, rename, delete cancellation, and cascade deletion. Verify that the deck-card count and Today agree after deletion. The Backup menu in this tab is documented under [backup and restore](backup-and-restore.md).
