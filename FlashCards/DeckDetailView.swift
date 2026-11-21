//
//  SwiftUIView.swift
//  FlashCards
//
//  Created by Thành Phước Nguyễn on 19/11/26.
//

import SwiftUI
import SwiftData

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
    private var newCardName = ""
    
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
            NavigationLink("Practice") {
                StudyView(cards: deck.cards, mode: .practice)
                    .navigationTitle("Practice")
            }
            .disabled(deck.cards.isEmpty)

            NavigationLink("Study") {
                StudyView(cards: deck.cards)
                    .navigationTitle(deck.name)
            }
            
            Section("Cards") {
                if deck.cards.isEmpty {
                    Text("This deck has no cards yet.")
                        .foregroundStyle(.secondary)
                } else if !searchText.isEmpty && visibleCards.isEmpty {
                    Text("No matching cards.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(visibleCards) { card in
                        Button {
                            cardToEdit = card
                        } label: {
                            VStack(alignment: .leading) {
                                Text(card.front)
                                Text(card.back)
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
            AddCardView(deckName: deck.name) { newCard in
                deck.cards.append(newCard)
            }
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

#Preview {
    DeckDetailPreview()
}
