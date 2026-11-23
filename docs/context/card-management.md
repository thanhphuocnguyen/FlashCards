# Card management

- [DeckDetailView.swift](../../FlashCards/Features/Decks/DeckDetailView.swift) lists cards, searches front and back case-insensitively, opens the add/edit sheets, and confirms swipe deletion. Rows show the front, known vocabulary type, and a one-line summary of the back.
- [AddCardView.swift](../../FlashCards/Features/Decks/AddCardView.swift) uses one draft array for single add, edit, and batch add. Providing an edit card seeds a draft. Providing `onSaveAll` without an edit card enables the batch controls. The deck's New Card entry point supplies the batch callback.
- [CardDraft.swift](../../FlashCards/Models/CardDraft.swift) gives each form row stable identity, holds its own vocabulary type, and requires nonblank front and back after trimming. Save validates every draft and invokes the matching callback before dismissing.
- [VocabType.swift](../../FlashCards/Models/VocabType.swift) defines the available values. The optional raw value is persisted as `vocabTypeRawVal`. A raw value outside the enum resolves to no type in the UI.
- Creation appends to the deck relationship. Editing copies fields onto the original model to retain its identity and schedule. At this baseline the edit callback copies front and back and drops vocabulary-type changes.

**Check** editing and reopening a card, adding cards with two different vocabulary types in one batch, a blank draft blocking Save All, and deleting a card from filtered results. AddCardView has single, batch, and edit previews.
