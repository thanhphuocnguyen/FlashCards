//
//  VocabularyDraft.swift
//  FlashCards
//
//  Created by Thành Phước Nguyễn on 23/11/26.
//

import Foundation

struct CardDraft: Identifiable {
    let id = UUID()
    var front = ""
    var back = ""
    var vocabType: VocabType?
    
    var trimmedFront: String {
        front.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var trimmedBack: String {
        back.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var isValid: Bool {
        !trimmedFront.isEmpty && !trimmedBack.isEmpty
    }
}
