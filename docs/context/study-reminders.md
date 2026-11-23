# Study reminders

[TodayView.swift](../../FlashCards/Features/Today/TodayView.swift) exposes the reminder toggle backed by `@AppStorage("studyRemindersEnabled")`. It disables the control while the async request is running and shows an alert for denied permission or scheduling failure.

[StudyReminders.swift](../../FlashCards/Notifications/StudyReminders.swift) requests alert and sound permission. It schedules three repeating local calendar notifications at 08:00, 12:30, and 20:00 with identifiers `study.morning`, `study.lunch`, and `study.evening`. Turning reminders off removes those pending requests. If adding a request fails after scheduling has started, the service removes its pending requests before throwing.

The reminders are fixed daily prompts and run independently of due-card counts. The toggle uses the stored preference and currently does not refresh authorization after a settings change outside the app.

**Check** permission granted, permission denied, and disable. Inspect pending requests for the three IDs on a simulator or device and confirm they're gone after disabling.
