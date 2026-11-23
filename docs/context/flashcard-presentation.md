# Flashcard presentation

[FlashcardView.swift](../../FlashCards/Features/Study/FlashcardView.swift) draws two faces and interpolates a single angle through `Animatable`. At 90° the visible face switches. The answer face is pre-rotated by 180°. The hidden face has hit testing and accessibility disabled. The answer face uses a light accent tint and shows feedback in typing mode.

[StudyView.swift](../../FlashCards/Features/Study/StudyView.swift) passes the prompt and answer strings, the input binding, and the angle. It uses the attempt index as view identity and slides new attempts in from the trailing edge. With Reduce Motion, the flip and slide change immediately. The rating buttons stack vertically at accessibility text sizes.

**Check** prompt and answer with multiline text, a flip while the typing keyboard is active, VoiceOver visibility during a reveal, and the Reduce Motion path. For realistic typed-recall preview data, display `shuǐ\nwater` and expect `水`. The component's current standalone preview has the two sides reversed for that exercise.
