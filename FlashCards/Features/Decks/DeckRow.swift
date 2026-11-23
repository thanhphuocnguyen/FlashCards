//
//  DeckRow.swift
//  FlashCards
//
//  Created by Thành Phước Nguyễn on 22/11/26.
//

import SwiftUI
import SwiftData

struct DeckRow: View {
    let deck: Deck
    let onDeleteRequested: () -> Void
    var body: some View {
        let now = Date.now
        let total = deck.cards.count
        let due = deck.cards.count { $0.isDue(at: now)}
        let cardCount = total == 1 ? "1 card" : "\(total) cards"
        let summary = total == 0 ? "No cards yet" : "\(due) due · \(cardCount)"
        NavigationLink {
            DeckDetailView(deck: deck)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "rectangle.stack")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 40, height: 40)
                    .background(
                        Color.accentColor.opacity(0.12),
                        in: RoundedRectangle(cornerRadius: 12)
                    )
                VStack(alignment: .leading, spacing: 4) {
                    Text(deck.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text(summary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }
        }
        .swipeActions(allowsFullSwipe: false) {
            Button(role: .destructive, action: onDeleteRequested) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    NavigationStack {
        List {
            DeckRow(
                deck: Deck(name: "Chinese Basics", cards: [
                    Flashcard(front: "水", back: "shuǐ\nwater")
                ]),
                onDeleteRequested: {}
            )
        }
    }
    .modelContainer(for: [Deck.self, Flashcard.self], inMemory: true)
}

#Preview("Deck rows") {
    let now = Date.now
    let scheduled = Flashcard(front: "书", back: "shū\nbook")
    scheduled.nextReviewAt = now.addingTimeInterval(3_600)
    
    return NavigationStack {
        
        List {
            DeckRow(
                deck: Deck(name: "Chinese Basics", cards: [
                    Flashcard(front: "水", back: "shuǐ\nwater"),
                    scheduled
                ]),
                onDeleteRequested: {}
            )
            
            DeckRow(
                deck: Deck(name: "Swift Basics"),
                onDeleteRequested: {}
            )
        }
        .navigationTitle("Decks")
    }
    .modelContainer(for: [Deck.self, Flashcard.self], inMemory: true)
}
