//
//  SwiftUIView.swift
//  FlashCards
//
//  Created by Thành Phước Nguyễn on 19/11/26.
//

import SwiftData
import SwiftUI

struct DeckDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var cardToEdit: Flashcard?
    @State private var isAddCardOpen = false
    @State private var searchText = ""
    @State private var isRenamingDeck = false
    @State private var draftDeckName = ""
    @State private var cardToDelete: Flashcard?
    @State private var isConfirmingDelete = false

    let deck: Deck

    private var visibleCards: [Flashcard] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return deck.cards }

        return deck.cards.filter { card in
            card.front.localizedCaseInsensitiveContains(query)
                || card.back.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        List {
            Section("Study") {
                TimelineView(.periodic(from: .now, by: 15)) { context in
                    let dueCount = deck.cards.filter { $0.isDue(at: context.date) }.count

                    NavigationLink {
                        StudyView(cards: deck.cards)
                            .navigationTitle(deck.name)
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        studyActions(
                            title: "Review due cards",
                            subtitle: dueCount == 1 ? "1 card ready" : "\(dueCount) cards ready",
                            icon: "clock"
                        )
                    }
                    .disabled(deck.cards.isEmpty)
                }

                NavigationLink {
                    PracticeSetupView(cards: deck.cards)
                } label: {
                    studyActions(
                        title: "Practice All Cards",
                        subtitle: "Review schedules stay the same",
                        icon: "rectangle.stack"
                    )
                }
                .disabled(deck.cards.isEmpty)
            }

            Section("Cards") {
                if deck.cards.isEmpty {
                    Text("This deck has no cards yet.")
                        .foregroundStyle(.secondary)
                } else if visibleCards.isEmpty {
                    Text("No matching cards.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(visibleCards) { card in
                        Button {
                            cardToEdit = card
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(card.front)
                                    .font(.headline)
                                    .foregroundStyle(.primary)

                                if let type = card.vocabType {
                                    Text(type.rawValue.capitalized)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Text(
                                    card.back.split(whereSeparator: \.isNewline).joined(
                                        separator: " . ")
                                )
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                            }
                        }
                        .swipeActions(allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                cardToDelete = card
                                isConfirmingDelete = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search cards")
        .navigationTitle(deck.name)
        .sheet(item: $cardToEdit) { card in
            AddCardView(deckName: deck.name, card: card) { draft in
                guard let index = deck.cards.firstIndex(where: { $0.id == card.id }) else {
                    return
                }

                deck.cards[index].front = draft.front
                deck.cards[index].back = draft.back
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("New Card", systemImage: "plus") {
                    isAddCardOpen = true
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button("Rename Deck", systemImage: "pencil") {
                    draftDeckName = deck.name
                    isRenamingDeck = true
                }
            }
        }
        .sheet(isPresented: $isAddCardOpen) {
            AddCardView(
                deckName: deck.name,
                onSave: { card in
                    deck.cards.append(card)
                },
                onSaveAll: { cards in
                    deck.cards.append(contentsOf: cards)
                }
            )
        }
        .alert("Rename Deck", isPresented: $isRenamingDeck) {
            TextField("Deck Name", text: $draftDeckName)
            Button("Cancel", role: .cancel) {}
            Button("Save") {
                let name = draftDeckName.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !name.isEmpty else {
                    return
                }
                deck.name = name
            }
        }
        .alert(
            "Delete this card?",
            isPresented: $isConfirmingDelete,
            presenting: cardToDelete
        ) { card in
            Button("Cancel", role: .cancel) {
                cardToDelete = nil
            }

            Button("Delete Card", role: .destructive) {
                modelContext.delete(card)
                cardToDelete = nil
            }
        } message: { card in
            Text(card.front)
        }
    }

    private func studyActions(
        title: String,
        subtitle: String,
        icon: String
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(Color.accentColor)
                .frame(width: 36, height: 36)
                .background(
                    Color.accentColor.opacity(0.12),
                    in: RoundedRectangle(cornerRadius: 10)
                )
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

        }
        .padding(.vertical, 4)
    }
}

private struct DeckDetailPreview: View {
    @State private var deck = Deck(
        name: "Chinese Basics",
        cards: [Flashcard(front: "学", back: "xué\nto learn, to study")]
    )

    var body: some View {
        NavigationStack {
            DeckDetailView(deck: deck)
        }
    }
}

#Preview("Deck detail") {
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Deck.self, Flashcard.self,
        configurations: configuration
    )

    let deck = Deck(
        name: "Chinese Basics",
        cards: [
            Flashcard(front: "学", back: "xué\nto learn"),
            Flashcard(front: "水", back: "shuǐ\nwater"),
        ])
    container.mainContext.insert(deck)

    return NavigationStack {
        DeckDetailView(deck: deck)
    }
    .modelContainer(container)
}
