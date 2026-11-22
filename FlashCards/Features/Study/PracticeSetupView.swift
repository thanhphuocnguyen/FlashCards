//
//  PracticeSetupView.swift
//  FlashCards
//
//  Created by Thành Phước Nguyễn on 21/11/26.
//

import SwiftUI

struct PracticeSetupView: View {
    let cards: [Flashcard]
    @State private var backFirst = false
    @State private var shuffle = false
    
    var body: some View {
        Form {
            Toggle("Show back first", isOn: $backFirst)
            Toggle("Shuffle cards", isOn: $shuffle)
            
            NavigationLink("Start Practice") {
                StudyView(
                    cards: cards,
                    mode: .practice,
                    direction: backFirst ? .backFirst : .frontFirst,
                    shuffle: shuffle
                )
                .navigationTitle("Practice")
            }
            .disabled(cards.isEmpty)
        }
        .navigationTitle("Practice Setup")
    }
}

#Preview {
    NavigationStack {
            PracticeSetupView(cards: [
                Flashcard(front: "水", back: "shuǐ\nwater"),
                Flashcard(front: "书", back: "shū\nbook")
            ])
        }
}
