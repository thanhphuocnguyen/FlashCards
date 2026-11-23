# Practice and typed recall

[PracticeSetupView.swift](../../FlashCards/Features/Study/PracticeSetupView.swift) opens from a deck and passes direction, shuffle, and typing choices to [StudyView.swift](../../FlashCards/Features/Study/StudyView.swift).

- Practice starts with every card in the deck, including cards scheduled in the future. Shuffle can reorder the initial queue and the restarted queue. The normal flow reveals the card, then advances. Skip is available before reveal. Practice advances and skips without writing any schedule fields.
- Typing uses the back as the clue and expects the front. This takes precedence over the direction toggle. `FlashcardView` reads the binding and renders feedback on the answer face. Its comparison trims surrounding whitespace, ignores case, and retains accent and tone differences.
- The session currently keeps typed input after advancing, skipping, or restarting. Its unused `checkTypedAnswer` method reads the Boolean mode flag. Live feedback comes from `FlashcardView`.

**Check** reverse and shuffle independently. In a two-card typing session, check a correct answer, advance, and verify the second input starts empty after a fix. Repeat for Skip and Practice Again. Verify a scheduled card's due date stays the same. The study file includes a typed-practice preview.
