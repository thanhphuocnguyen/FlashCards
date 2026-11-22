//
//  AddCardView.swift
//  FlashCards
//
//  Created by Thành Phước Nguyễn on 19/11/26.
//

import SwiftUI

struct AddCardView: View {
    let deckName: String
    let onSave: (Flashcard) -> Void
    
    private let isEditing: Bool
    
    @Environment(\.dismiss) private var dismiss
    @State private var front = ""
    @State private var back = ""
    
    init(
        deckName: String,
        card: Flashcard? = nil,
        onSave: @escaping (Flashcard) -> Void
    ) {
        self.deckName = deckName
        self.onSave = onSave
        self.isEditing = card != nil
        _front = State(initialValue: card?.front ?? "")
        _back = State(initialValue: card?.back ?? "")
    }
    
    private var trimmedFront: String {
        front.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var trimmedBack: String {
        back.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var body: some View {
        NavigationStack {
            Form{
                Text(deckName)
                TextField("Front", text: $front)
                TextField("Back", text: $back, axis: .vertical)
            }
            .navigationTitle(isEditing ? "Edit Card" :"Add Card")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction){
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            onSave(Flashcard(front: trimmedFront, back: trimmedBack))
                            dismiss()
                        }.disabled(trimmedFront.isEmpty || trimmedBack.isEmpty)
                    }
                }
        }
    }
}

#Preview {
    var cards: [Flashcard] = []
    AddCardView(deckName: "New") { card in
        cards.append(card)
    }
}
