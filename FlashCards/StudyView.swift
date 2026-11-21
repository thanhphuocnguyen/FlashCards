//
//  StudyView.swift
//  FlashCards
//
//  Created by Thành Phước Nguyễn on 19/11/26.
//

import SwiftUI

struct StudyView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.dismiss) private var dismiss
    @State private var queue: [Flashcard]
    @State private var currentIndex = 0
    @State private var isAnswerVisible = false
    @State private var completeCards = 0
    @State private var retryCount = 0
    @State private var skippedCards = 0
    
    enum Direction {
        case frontFirst
        case backFirst
    }
    
    let direction: Direction
    let shuffle: Bool
    enum Mode {
        case review
        case practice
    }
    
    let mode: Mode
    
    init(
        cards: [Flashcard],
        mode: Mode = .review,
        direction: Direction = .frontFirst,
        shuffle: Bool = false
    ) {
        self.mode = mode
        self.direction = direction
        self.shuffle = shuffle
        let now = Date.now
        var sessionCards: [Flashcard]
        
        switch mode {
        case .review:
            sessionCards = cards
                .filter { $0.isDue(at: now)}
                .sorted { first, second in
                    (first.nextReviewAt ?? .distantFuture) < (second.nextReviewAt ?? .distantFuture)
                }
        case .practice:
            sessionCards = shuffle ? cards.shuffled() : cards
        }
        
        _queue = State(initialValue: sessionCards)
    }
    
    private var remainingAttempts: Int {
        max(0, queue.count - currentIndex)
    }
    
    var body: some View {
        VStack(spacing:24) {
            if currentIndex < queue.count {
                let card = queue[currentIndex]
                
                ProgressView(value: Double(currentIndex), total: Double(queue.count))
                    .padding(EdgeInsets(top: 0, leading: 60.0, bottom: 0, trailing: 60.0))
                Text("Remaining: \(remainingAttempts)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(direction == .frontFirst ? card.front : card.back)
                    .font(.largeTitle)
                if isAnswerVisible {
                    Text(direction == .frontFirst ? card.back : card.front)
                        .multilineTextAlignment(.center)
                    if mode == .practice {
                        Button("Next Card") {
                            advance()
                        }
                    } else {
                        let layout = dynamicTypeSize.isAccessibilitySize
                        ? AnyLayout(VStackLayout(spacing: 12))
                        : AnyLayout(HStackLayout(spacing: 12))
                        
                        layout {
                            VStack {
                                Button("Again") { rate(.again, card: card) }
                                Text("Now")
                            }
                            VStack {
                                
                                Button("Hard") { rate(.hard, card: card) }
                                Text("1 day")
                            }
                            VStack {
                                Button("Good") { rate(.good, card: card) }
                                let days = goodInterval(for: card.intervalDays)
                                Text("\(days) days")
                            }                    }
                        .buttonStyle(.bordered)
                        
                    }
                } else {
                    Button("Show answer") {
                        isAnswerVisible = true
                    }
                    .buttonStyle(.borderedProminent)
                    
                    if mode == .practice {
                        Button("Skip card") {
                            skippedCards += 1
                            currentIndex += 1
                            isAnswerVisible = false
                        }
                    }
                }
                
                
            } else {
                if queue.isEmpty {
                    Text(mode == .review ? "No cards due" : "No cards to practice")
                        .font(.title2)
                } else {
                    Text(mode == .review ? "Review complete" : "Practice complete")
                        .font(.title2)
                    
                    Text("Cards completed: \(completeCards)")
                    
                    if mode == .practice {
                        Text("Cards skipped: \(skippedCards)")
                    }
                    
                    if mode == .review {
                        Text("Retries requested: \(retryCount)")
                            .foregroundStyle(.secondary)
                    }
                    
                    Button("Done") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    
                    if mode == .practice {
                        Button("Practice Again") {
                            if shuffle {
                                queue.shuffle()
                            }
                            currentIndex = 0
                            isAnswerVisible = false
                            completeCards = 0
                            retryCount = 0
                            skippedCards = 0
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            
        }
        .padding()
    }
    
    private enum Rating {
        case again, hard, good
    }
    
    private func rate(_ rating: Rating, card: Flashcard) {
        let now = Date.now
        
        switch rating {
        case .again:
            card.intervalDays = nil
            card.nextReviewAt = now
            retryCount += 1
            queue.append(card)
        case .hard:
            schedule(card, inDays: 1, from: now)
            completeCards += 1
        case .good:
            let days = goodInterval(for: card.intervalDays)
            schedule(card, inDays: days, from: now)
            completeCards += 1
        }
        currentIndex += 1
        isAnswerVisible = false
    }
    
    private func goodInterval(for interval: Int?) -> Int {
        let previous = min(45, max(0, interval ?? 0))
        return max(3, previous * 2)
    }
    
    private func schedule(_ card: Flashcard, inDays days: Int, from date: Date) {
        card.intervalDays = days
        card.nextReviewAt = Calendar.current.date(byAdding: .day, value: days, to: date)
    }
    
    private func advance() {
        currentIndex += 1
        isAnswerVisible = false
        completeCards += 1
    }
}

#Preview("Good interval hints") {
    let now = Date.now
    let newCard = Flashcard(front: "学", back: "xué\nto learn")
    newCard.intervalDays = 0
    let reviewedCard = Flashcard(front: "水", back: "shuǐ\nwater")
    reviewedCard.intervalDays = 10
    
    let cappedCard = Flashcard(front: "书", back: "shū\nbook")
    cappedCard.intervalDays = 90
    
    
    return StudyView(cards: [newCard, reviewedCard, cappedCard])
}

#Preview("Practice a scheduled card") {
    let now = Date.now
    let card = Flashcard(front: "水", back: "shuǐ\nwater")
    let reviewedCard = Flashcard(front: "水", back: "shuǐ\nwater")
    reviewedCard.nextReviewAt = now.addingTimeInterval(7_200)
    
    card.nextReviewAt = now.addingTimeInterval(3_600)
    return StudyView(cards: [card,reviewedCard], mode: .practice)
}

#Preview("Reverse practice") {
    StudyView(
        cards: [Flashcard(front: "水", back: "shuǐ\nwater")],
        mode: .practice,
        direction: .backFirst
    )
}

#Preview("Review with large text") {
    StudyView(cards: [
        Flashcard(front: "学", back: "xué\nto learn, to study")
    ])
    .environment(\.dynamicTypeSize, .accessibility3)
}
