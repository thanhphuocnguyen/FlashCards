    //
    //  TodayView.swift
    //  FlashCards
    //
    //  Created by Thành Phước Nguyễn on 20/11/26.
    //

    import SwiftUI
    import SwiftData

    struct TodayView: View {
        @AppStorage("studyRemindersEnabled") private var remindersEnabled = false
        @State private var isUpdatingReminders = false
        @State private var reminderMessage = ""
        @State private var isShowingReminderMessage = false
        @Query private var cards: [Flashcard]
        
        var body: some View {            
            NavigationStack() {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        TimelineView(.periodic(from: .now, by: 15)) { context in
                            let now = context.date
                            let dueCount = cards.filter { $0.isDue(at: now) }.count
                            let nextReview = cards.compactMap(\.nextReviewAt).filter { $0 > now }.min()
                            
                            reviewPanel(dueCount: dueCount, nextReview: nextReview)
                        }
                        
                        settingsPanel
                    }
                    .frame(maxWidth: 560)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                }
                .background(Color(uiColor: .systemGroupedBackground))
                .navigationTitle("Today")
            }
        }
        
        private var settingsPanel: some View {
            VStack(spacing: 0) {
                reminderToggle
                    .padding(.vertical, 14)
                
                Divider()
                
                NavigationLink {
                    ReviewSettingView()
                } label: {
                    HStack(spacing: 12) {
                        Label("Review Settings", systemImage: "slider.horizontal.3")
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.tertiary)
                            .accessibilityHidden(true)

                    }
                    .foregroundStyle(.primary)
                    .padding(.vertical, 14)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .background(
                Color(uiColor: .secondarySystemGroupedBackground),
                in: RoundedRectangle(cornerRadius: 20)
            )
        }
        
        private func todayContent(now: Date) -> some View {
            let dueCount = cards.filter { $0.isDue(at: now) }.count
            let nextReview = cards.compactMap(\.nextReviewAt)
                .filter { $0 > now }
                .min()
            
            return VStack(alignment: .leading, spacing: 12) {
                reviewPanel(dueCount: dueCount, nextReview: nextReview)
            }
            
        }
        
        private var reminderToggle: some View {
            Toggle(isOn: Binding(
                get: { remindersEnabled },
                set: { enabled in
                    isUpdatingReminders = true
                    Task {
                        defer { isUpdatingReminders = false }
                        
                        if enabled {
                            do {
                                remindersEnabled = try await StudyReminders.enable()
                                if !remindersEnabled {
                                    reminderMessage = "Allow FlashCards notification in Settings."
                                    isShowingReminderMessage = true
                                }
                            } catch {
                                reminderMessage = "Couldn't schedule study reminders."
                                isShowingReminderMessage = true
                            }
                        } else {
                            StudyReminders.disable()
                            remindersEnabled = false
                        }
                    }
                }
            )) {
                Label("Study Reminder", systemImage: "bell")
            }
            .disabled(isUpdatingReminders)
            .alert("Study Reminders", isPresented: $isShowingReminderMessage) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(reminderMessage)
            }
            .padding()
        }
        
        private func reviewPanel(dueCount: Int, nextReview: Date?) -> some View {
            VStack(alignment: .leading, spacing: 16) {
                if dueCount > 0 {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(dueCount.formatted())
                            .font(.system(.largeTitle, design: .rounded).weight(.bold))
                            .monospacedDigit()
                            .foregroundStyle(Color.accentColor)
                        
                        Text(dueCount == 1 ? "card due" : "cards due")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                                        
                    NavigationLink {
                        StudyView(cards: cards)
                            .navigationTitle("Review")
                    } label: {
                        Text("Start Review")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    
                } else if cards.isEmpty {
                    Text("No cards yet").font(.title2.bold())

                    Text("Add your first card in the Decks tab.")
                        .foregroundStyle(.secondary)
                } else {
                    Text("You're caught up!")
                        .font(.title2.bold())

                    if let nextReview {
                        let nextReviewDateFormatted = nextReview.formatted(date: .abbreviated, time: .shortened)
                        Text("Next review: \(nextReviewDateFormatted)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
                    .overlay {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.accentColor.opacity(0.08))
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(Color.accentColor.opacity(0.15), lineWidth: 1)
                    .allowsHitTesting(false)
            }
        }
    }

    #Preview {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Deck.self, Flashcard.self, configurations: configuration)
        
        let deck = Deck(name: "Chinese Basics", cards: [
            Flashcard(front: "学", back: "xué\nto learn, to study")
        ])
        
        container.mainContext.insert(deck)
        return TodayView()
            .modelContainer(container)
    }
