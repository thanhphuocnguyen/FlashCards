//
//  DeckLanguage.swift
//  FlashCards
//
//  Created by Thành Phước Nguyễn on 24/11/26.
//

import Foundation

enum DeckLanguage: String, CaseIterable {
    case english = "en"
    case vietnamese = "vi"
    case simplifiedChinese = "zh-Hans"
    case traditionalChinese = "zh-Hant"
    case spanish = "es"
    
    var title: String {
        switch self {
        case .english: "English"
        case .vietnamese: "Vietnamese"
        case .simplifiedChinese: "Chinese (Simplified)"
        case .traditionalChinese: "Chinese (Traditional)"
        case .spanish: "Español"
        }
    }
}
