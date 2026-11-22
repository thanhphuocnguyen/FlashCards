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
        NavigationLink {
            DeckDetailView(deck: deck)
        } label: {
            VStack(alignment: .leading) {
                Text(deck.name)
                Text("\(due) due - \(total) total")
                    .font(.caption)
                    .foregroundStyle(.secondary)
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

