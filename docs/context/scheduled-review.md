# Scheduled review

[StudyView.swift](../../FlashCards/Features/Study/StudyView.swift) receives cards from Today or a deck. On session entry, review filters by `isDue(at:)` and sorts ascending by review date, with undated cards after dated due cards. The session keeps its own queue and index.

| Action | Scheduling effect |
| --- | --- |
| Again | Clears the stored day interval, sets the due date to now, appends the card to the queue, increments retries |
| Hard | Schedules a calendar-day offset from now using `review.hardDays`, increments completed |
| Good | Doubles the previous day interval within configured minimum and maximum bounds, schedules a calendar-day offset, increments completed |

[ReviewSettingView.swift](../../FlashCards/Features/Today/ReviewSettingView.swift) shares `@AppStorage` keys with the session. Defaults are Hard 1 day, Good minimum 3 days, and Good maximum 90 days. The steppers constrain the values so Hard ≤ Good minimum ≤ Good maximum ≤ 365. The current feature stores day values. Hour-based Hard scheduling is a proposed change.

## Current progression defect

Show Answer advances the index before revealing, and rating resets the reveal state without advancing. The expected sequence is reveal the current card, rate that same card, then consume one queue attempt. The Hard hint also displays a fixed “1 day” even when the setting differs.

**Check** one due card, two due cards, Again followed by Good, and Hard with a non-default interval. Confirm that a future card is excluded and that each rated card's timestamp reflects its own action. See the [review findings](code-review.md).
