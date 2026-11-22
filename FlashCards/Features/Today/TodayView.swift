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
        let now = Date.now
        let dueCount = cards.count { $0.isDue(at: now) }
        let nextReview = cards
            .compactMap(\.nextReviewAt)
            .filter { $0 > now }
            .min()
        
        NavigationStack {
            VStack(spacing: 16) {
                if dueCount == 0 {
                    if let nextReview {
                        Text("Next review: \(nextReview.formatted(date: .abbreviated, time: .shortened))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Text(cards.isEmpty ? "Add a card in Decks to get started." : "You're caught up.")
                } else {
                    Text(dueCount == 1 ? "1 card due" : "\(dueCount) cards due")
                        .font(.title2)
                    
                    NavigationLink {
                        StudyView(cards: cards)
                            .navigationTitle("Review")
                    } label: {
                        Text("Start Review")
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                Toggle("Study Reminder", isOn: Binding(
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
                ))
                .disabled(isUpdatingReminders)
                .alert("Study Reminders", isPresented: $isShowingReminderMessage) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(reminderMessage)
                }
                .padding()
            }
            .padding()
            .navigationTitle("Today")
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
