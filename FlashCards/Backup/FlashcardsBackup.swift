//
//  FlashcardBackup.swift
//  FlashCards
//
//  Created by Thành Phước Nguyễn on 20/11/26.
//

import Foundation

struct FlashcardsBackup: Codable {
    let version: Int
    let decks: [DeckSnapshot]
    
    init(decks: [Deck]) {
        version = 2
        self.decks = decks.map { deck in
            DeckSnapshot(
                backupID: deck.backupID,
                name: deck.name,
                createdAt: deck.createdAt,
                cards: deck.cards.map { card in
                    CardSnapshot(
                        backupID: card.backupID,
                        front: card.front,
                        back: card.back,
                        nextReviewAt: card.nextReviewAt,
                        intervalDays: card.intervalDays
                    )
                }
            )
        }
    }
    
    struct DeckSnapshot: Codable {
        let backupID: UUID?
        let name: String
        let createdAt: Date
        let cards: [CardSnapshot]
    }
    
    struct CardSnapshot: Codable {
        let backupID: UUID?
        let front: String
        let back: String
        let nextReviewAt: Date?
        let intervalDays: Int?
    }
}
