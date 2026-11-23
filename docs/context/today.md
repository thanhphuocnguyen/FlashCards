# Today dashboard

[TodayView.swift](../../FlashCards/Features/Today/TodayView.swift) is the Today tab root. It queries all flashcards across decks. Its `TimelineView` uses a 15-second cadence to recompute the due count and earliest future review with the timeline date.

- With due cards, the dashboard shows the count and launches `StudyView(cards: cards)` across decks. Study filters the cards again at session entry.
- With an empty store, it points users to the Decks tab. With cards and zero due, it shows the caught-up state and the next scheduled review when available.
- The settings panel links to [review intervals](scheduled-review.md) and owns the toggle for [study reminders](study-reminders.md).

**Check** an empty store, a future-only store, and due cards from two decks. Start review from Today and verify the queue contains due cards from both decks. Use the in-memory Today preview for dashboard styling.
