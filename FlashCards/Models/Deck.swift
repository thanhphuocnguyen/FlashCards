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
    var backupID: UUID?
    var name: String
    var createdAt: Date
    @Relationship(deleteRule: .cascade, inverse: \Flashcard.deck)
    var cards: [Flashcard] = []
    
    init(name: String, cards: [Flashcard] = []) {
        self.backupID = UUID()
        self.name = name
        self.cards = cards
        self.createdAt = Date.now
    }
}
