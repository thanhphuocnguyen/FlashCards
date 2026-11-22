//
//  FlashCardsApp.swift
//  FlashCards
//
//  Created by Thành Phước Nguyễn on 19/11/26.
//

import SwiftUI
import SwiftData

@main
struct FlashCardsApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                TodayView()
                    .tabItem( {
                        Label("Today", systemImage: "calendar")
                    })
                DeckListView()
                    .tabItem {
                        Label("Decks", systemImage: "rectangle.stack")
                    }
            }
            
        }
        .modelContainer(for: [Deck.self, Flashcard.self])
    }
}
