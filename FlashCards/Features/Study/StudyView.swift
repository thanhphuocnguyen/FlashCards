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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @AppStorage("review.hardHours") private var hardHours = 24
    @AppStorage("review.goodMinDays") private var goodMinDays = 3
    @AppStorage("review.goodMaxDays") private var goodMaxDays = 90

    @State private var queue: [Flashcard]
    @State private var currentIndex = 0
    @State private var isAnswerVisible = false
    @State private var completeCards = 0
    @State private var retryCount = 0
    @State private var skippedCards = 0
    @State private var isTypedAnswerCorrected: Bool?
    
    enum Direction {
        case frontFirst
        case backFirst
    }
    
    let direction: Direction
    let shuffle: Bool
    let typeTheWord: Bool
    enum Mode {
        case review
        case practice
    }
    
    let mode: Mode
    
    init(
        cards: [Flashcard],
        mode: Mode = .review,
        direction: Direction = .frontFirst,
        shuffle: Bool = false,
        typeTheWord: Bool = false
    ) {
        self.mode = mode
        self.direction = direction
        self.shuffle = shuffle
        self.typeTheWord = typeTheWord
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
        VStack(spacing: 30) {
            if currentIndex < queue.count {
                let card = queue[currentIndex]
                
                ProgressView(value: Double(currentIndex),
                             total: Double(queue.count),
                )
                    .padding(EdgeInsets(top: 0, leading: 40.0, bottom: 0, trailing: 40.0))
                    .scaleEffect(x:1, y: 2, anchor: .center)

                Text("Remaining: \(remainingAttempts)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                studyCard(for: card)
                
                if mode == .practice {
                    practiceControls
                } else if isAnswerVisible {
                    answerVisibleControls(for: card)
                } else {
                    Button("Show answer") {
                        isAnswerVisible = true
                    }
                    .controlSize(.large)
                    .buttonStyle(.borderedProminent)
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
    
    private func answerVisibleControls(for card: Flashcard) -> some View {
        let layout = dynamicTypeSize.isAccessibilitySize
        ? AnyLayout(VStackLayout(spacing: 12))
        : AnyLayout(HStackLayout(spacing: 12))
        
        return layout {
            VStack {
                Button("Again") { rate(.again, card: card) }
                Text("Now")
            }
            
            VStack {
                Button("Hard") { rate(.hard, card: card) }
                Text(hardHours == 1 ? "1 hour" : "\(hardHours) hours")
            }
            
            VStack {
                Button("Good") { rate(.good, card: card) }
                Text("\(goodInterval(for: card.intervalDays)) days")
            }
        }
        .buttonStyle(.bordered)
    }
    
    private var practiceControls: some View {
        VStack(spacing: 12) {
            Button {
                if isAnswerVisible {
                    advance()
                } else {
                    isAnswerVisible = true
                }
            } label: {
                Text(isAnswerVisible ? "Next Card" : typeTheWord ? "Check Answer" : "Show Answer")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            Button("Skip Card") {
                skippedCards += 1
                currentIndex += 1
                isAnswerVisible = false
            }
            .opacity(isAnswerVisible ? 0 : 1)
            .disabled(isAnswerVisible)
            .accessibilityHidden(isAnswerVisible)
        }
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
            card.nextReviewAt = now.addingTimeInterval(Double(hardHours) * 3_600)
            card.intervalDays = (hardHours+23)/24
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
        let previous = min(goodMaxDays, max(0, interval ?? 0))
        return min(goodMaxDays, max(goodMinDays, previous * 2))
    }
    
    private func schedule(_ card: Flashcard, inDays days: Int, from date: Date) {
        card.intervalDays = days
        card.nextReviewAt = Calendar.current.date(byAdding: .day, value: days, to: date)
    }
    
    private func advance() {
        isAnswerVisible = false
        completeCards += 1
        currentIndex += 1
    }
    
    private func studyCard(for card: Flashcard) -> some View {
        ZStack {
            FlashcardView(
                typeTheWord: typeTheWord,
                prompt: direction == .frontFirst && !typeTheWord ? card.front : card.back,
                answer: direction == .frontFirst && !typeTheWord ? card.back : card.front,
                angle: isAnswerVisible ? 180 : 0
            )
            .animation(
                reduceMotion ? nil : .easeInOut(duration: 0.32),
                value: isAnswerVisible
            )
            .id(currentIndex)
            .transition(
                reduceMotion ? .identity : .asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                )
            )
            
        }
        .clipped()
        .animation(
            reduceMotion ? nil : .easeInOut(duration: 0.25),
            value: currentIndex
        )
    }
    
    private func checkTypedAnswer(for card: Flashcard) {
        let entered = typeTheWord.description.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !entered.isEmpty else {
            return
        }
        
        let expected = card.front.trimmingCharacters(in: .whitespacesAndNewlines)
        isTypedAnswerCorrected = entered.compare(expected, options: .caseInsensitive) == .orderedSame
    }
}

#Preview("Good interval hints") {
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

#Preview("Type The word practice") {
    StudyView(
        cards: [Flashcard(front: "Water", back: "water")],
        mode: .practice,
        direction: .backFirst,
        typeTheWord: true
    )
}


#Preview("Review with large text") {
    StudyView(cards: [
        Flashcard(front: "学", back: "xué\nto learn, to study")
    ])
    .environment(\.dynamicTypeSize, .accessibility3)
}


