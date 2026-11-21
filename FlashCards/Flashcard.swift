//
//  FlashCard.swift
//  FlashCards
//
//  Created by Thành Phước Nguyễn on 19/11/26.
//
import Foundation
import SwiftData

@Model
final class Flashcard {
    var backupID: UUID?
    var front: String
    var back: String
    
    var nextReviewAt: Date?
    var intervalDays: Int?
    
    var deck: Deck?
    
    init(front: String, back: String) {
        self.backupID = UUID()
        self.front = front
        self.back = back
    }
    
    func isDue(at date: Date) -> Bool {
        guard let nextReviewAt else { return true }
        
        return nextReviewAt <= date
    }
}
