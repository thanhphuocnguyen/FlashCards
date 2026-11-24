//
//  Deck.swift
//  FlashCards
//
//  Created by Thành Phước Nguyễn on 19/11/26.
//

import SwiftData
import Foundation

@Model
final class Deck {
    @Relationship(deleteRule: .cascade, inverse: \Flashcard.deck)
    var cards: [Flashcard] = []

    var backupID: UUID?
    var name: String
    var createdAt: Date
    var primaryLanguageCode: String? = nil
    
    var primaryLanguage: DeckLanguage? {
        get { primaryLanguageCode.flatMap(DeckLanguage.init(rawValue:)) }
        set { primaryLanguageCode = newValue?.rawValue }
    }
    
    init(name: String, cards: [Flashcard] = []) {
        self.backupID = UUID()
        self.name = name
        self.cards = cards
        self.createdAt = Date.now
    }
}
