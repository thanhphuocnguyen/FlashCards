//
//  AddCardView.swift
//  FlashCards
//
//  Created by Thành Phước Nguyễn on 19/11/26.
//

import SwiftUI
import Translation

struct AddCardView: View {
    let deckName: String
    let onSave: (Flashcard) -> Void
    let onSaveAll: (([Flashcard]) -> Void)?
    @State private var drafts: [CardDraft]
    private let isEditing: Bool
    
    @Environment(\.dismiss) private var dismiss
    
    init(
        deckName: String,
        card: Flashcard? = nil,
        onSave: @escaping (Flashcard) -> Void,
        onSaveAll: (([Flashcard]) -> Void)? = nil
    ) {
        self.deckName = deckName
        self.onSave = onSave
        self.onSaveAll = onSaveAll
        self.isEditing = card != nil
        _drafts = State(initialValue: [CardDraft(
            front: card?.front ?? "",
            back: card?.back ?? "",
            vocabType: card?.vocabType
        )])
        
    }
    
    private var allowMultipleCards: Bool {
        !isEditing && onSaveAll != nil
    }
    
    private var canSave: Bool {
        !drafts.isEmpty && drafts.allSatisfy(\.isValid)
    }
    
    private func save() {
        guard canSave, let firstDraft = drafts.first else { return }
        
        if allowMultipleCards, let onSaveAll {
            onSaveAll(drafts.map { makeCard(from: $0) })
        } else {
            onSave(makeCard(from: firstDraft))
        }
        
        dismiss()
    }
    
    private func makeCard(from draft: CardDraft) -> Flashcard {
        let card = Flashcard(front: draft.trimmedFront, back: draft.trimmedBack)
        card.vocabType = draft.vocabType
        
        return card
    }
    
    var body: some View {
        NavigationStack {
            Form {
                ForEach($drafts) { $draft in
                    let number = (drafts.firstIndex { $0.id == draft.id } ?? 0) + 1
                    Section {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Front")
                                .font(.subheadline.weight(.semibold))
                            
                            TextField("e.g. 水", text: $draft.front)
                                .accessibilityLabel("Front")
                        }
                        .padding(.vertical, 4)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Back")
                                .font(.subheadline.weight(.semibold))
                            
                            ZStack(alignment: .topLeading) {
                                if draft.back.isEmpty {
                                    Text("Pinyin, meaning, or notes")
                                        .foregroundStyle(.tertiary)
                                        .padding(.top, 8)
                                        .padding(.leading, 5)
                                        .allowsHitTesting(false)
                                        .accessibilityHidden(true)
                                }
                                TextEditor(text: $draft.back)
                                    .scrollContentBackground(.hidden)
                                    .frame(minHeight: 80)
                                    .accessibilityLabel("Back")
                            }
                        }
                        .padding(.vertical, 4)
                        
                        Picker("Vocabulary type", selection: $draft.vocabType) {
                            Text("Unspecified").tag(nil as VocabType?)
                            
                            ForEach(VocabType.allCases, id: \.self) { type in
                                Text(type.rawValue.capitalized)
                                    .tag(Optional(type))
                            }
                        }
                        
                        if allowMultipleCards && drafts.count > 1 {
                            Button("Remove Card", role: .destructive) {
                                let id = draft.id
                                drafts.removeAll { $0.id == id }
                            }
                        }
                    } header: {
                        Text(allowMultipleCards ? "Card \(number)" : "Card")
                    } footer: {
                        if number == 1 {
                            Text("Deck · \(deckName)")
                        }
                    }
                }
                
                if allowMultipleCards {
                    Button("Add Another Card", systemImage: "plus") {
                        drafts.append(CardDraft())
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Card" :"Add Card")
            .toolbar {
                ToolbarItem(placement: .cancellationAction){
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(allowMultipleCards ? "Save All" : "Save", action: save)
                        .disabled(!canSave)
                }
            }
        }
        
    }
}


#Preview {
    var cards: [Flashcard] = []
    AddCardView(
        deckName: "Chinese Basics",
        onSave: {card in
            cards.append(card)
        },
    )
}

#Preview("Save all") {
    var cards: [Flashcard] = []
    AddCardView(
        deckName: "New",
        onSave: {card in
            cards.append(card)
        },
        onSaveAll: { addCards in
            cards.append(contentsOf: addCards)
        }
    )
}

#Preview("Edit card") {
    AddCardView(
        deckName: "Chinese Basics",
        card: Flashcard(front: "水", back: "shuǐ\nwater"),
        onSave: { _ in }
    )
}
