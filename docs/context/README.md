# FlashCards feature context

Source baseline: [main at 8400842](https://github.com/thanhphuocnguyen/FlashCards/tree/8400842f8ef4b58e492a7157681018aac13c4f31). Each file describes the behavior in that commit and includes a check to run after changing the feature.

| Area | Context |
| --- | --- |
| App startup, tabs, and data ownership | [App and persistence](app-and-persistence.md) |
| Due counts and dashboard | [Today](today.md) |
| Create, rename, delete, and navigate decks | [Deck management](deck-management.md) |
| Search, add, batch add, edit, and delete cards | [Card management](card-management.md) |
| Due queues, ratings, and interval settings | [Scheduled review](scheduled-review.md) |
| Reverse, shuffle, skip, and typed recall | [Practice](practice.md) |
| Flip animation and card accessibility | [Flashcard presentation](flashcard-presentation.md) |
| Local notification scheduling | [Study reminders](study-reminders.md) |
| JSON export, restore, and UUID matching | [Backup and restore](backup-and-restore.md) |

The [code review](code-review.md) records findings against this baseline. To work on a feature, start with its context file, then follow its source links. Recheck related files when changing model fields, due-date behavior, or the backup format.
