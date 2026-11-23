# FlashCards code review

Static review of `main` at `8400842`. The iOS app was not built or run in this environment.

## P1 · Review reveals and rates the wrong card

[StudyView.swift, lines 97–100 and 201–219](https://github.com/thanhphuocnguyen/FlashCards/blob/8400842f8ef4b58e492a7157681018aac13c4f31/FlashCards/Features/Study/StudyView.swift#L97-L100)

Show Answer increments `currentIndex` before revealing. In a one-card session this jumps directly to the summary without a rating. In a multi-card session it reveals the next card and a rating modifies that card's schedule. Move the index increment out of Show Answer and put it at the end of `rate(_:card:)`, after any Again append. Test a one-card queue and a two-card queue with distinct prompts.

## P2 · Typing practice carries answers into later attempts

[StudyView.swift, practice controls](https://github.com/thanhphuocnguyen/FlashCards/blob/8400842f8ef4b58e492a7157681018aac13c4f31/FlashCards/Features/Study/StudyView.swift#L171-L194)

The input binding uses session-owned `wordTyped`. Advance, Skip, and Practice Again leave that value intact. This can prefill a later question or evaluate stale input. Clear it at each of those boundaries. The unused `checkTypedAnswer` reads `typeTheWord.description`, which yields the mode flag as text. Remove that method and its unused result state if the live comparison stays in `FlashcardView`.

## P2 · Editing vocabulary type silently discards the change

[DeckDetailView.swift, edit callback](https://github.com/thanhphuocnguyen/FlashCards/blob/8400842f8ef4b58e492a7157681018aac13c4f31/FlashCards/Features/Decks/DeckDetailView.swift#L110-L120)

The editor includes the chosen type in the returned card. The callback copies only front and back onto the existing card. Also assign `deck.cards[index].vocabType = draft.vocabType` so both changing and clearing the picker persist while retaining the existing card's schedule.

## P2 · Import can silently drop ID-less cards in a matched deck

[DeckListView.swift, restore merge](https://github.com/thanhphuocnguyen/FlashCards/blob/8400842f8ef4b58e492a7157681018aac13c4f31/FlashCards/Features/Decks/DeckListView.swift#L161-L173)

Cards without UUIDs are accepted by the schema and assigned UUIDs when their deck is created. When a snapshot matches an existing deck UUID, the code skips those cards. A mixed import can therefore report success while dropping rows. Define how those rows should be handled. If they are accepted, use an explicit fallback identity policy and test reimport. If they are rejected, surface that outcome to the user.

## P3 · Hard rating hint ignores the configured delay

[StudyView.swift, Hard control](https://github.com/thanhphuocnguyen/FlashCards/blob/8400842f8ef4b58e492a7157681018aac13c4f31/FlashCards/Features/Study/StudyView.swift#L158-L162)

The button always shows “1 day,” while scheduling uses `hardDays`. Use the same setting for the hint and scheduler and display the correct singular or plural unit.

## P3 · Practice setup offers a direction choice during typed recall

[PracticeSetupView.swift, toggles](https://github.com/thanhphuocnguyen/FlashCards/blob/8400842f8ef4b58e492a7157681018aac13c4f31/FlashCards/Features/Study/PracticeSetupView.swift#L16-L26)

Typed recall always uses Back → Front, so the direction toggle has no effect while Type the Word is enabled. Disable it in that mode and preserve the previous selection for regular practice.
