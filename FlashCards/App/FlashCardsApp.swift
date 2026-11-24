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
    init() {
        let defaults = UserDefaults.standard
        
        guard defaults.object(forKey: "review.hardHours") == nil else { return }
        
        let oldDays = defaults.object(forKey: "review.hardDays") as? Int ?? 1
        let validDays = min(365, max(1, oldDays))
        defaults.set(validDays*24, forKey: "review.hardHours")
    }

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
