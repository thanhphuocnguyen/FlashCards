//
//  FlashcardView.swift
//  FlashCards
//
//  Created by Thành Phước Nguyễn on 22/11/26.
//

import SwiftUI

struct FlashcardView: View, Animatable {
    @State private var wordTyped = ""
    let typeTheWord: Bool
    let prompt: String
    let answer: String
    
    var angle: Double
    
    var animatableData: Double {
        get { angle }
        set { angle = newValue }
    }
    
    var body: some View {
        let showAnswer = angle >= 90
        ZStack {
            face("Prompt", text: prompt, font: .largeTitle)
                .opacity(showAnswer ? 0 : 1)
                .allowsHitTesting(!showAnswer)
                .accessibilityHidden(showAnswer)
            
            face("Answer", text: answer, font: .title2)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .opacity(showAnswer ? 1 : 0)
                .allowsHitTesting(showAnswer)
                .accessibilityHidden(!showAnswer)
        }
        .rotation3DEffect(.degrees(angle), axis: (x: 0, y: 1, z: 0), perspective: 0.5)
    }
    
    private func face(
        _ title: String,
        text: String,
        font: Font
    ) -> some View {
        let isAnswer = title == "Answer"

        return  VStack(spacing: 12) {
            Text(isAnswer ? title : (typeTheWord ? "Type the word" : "Prompt"))
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            
            Text(isAnswer ? answer : prompt)
                .font(font)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            if typeTheWord {
                if !isAnswer {
                    TextField("Input your answer", text: $wordTyped)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .accessibilityLabel("Your answer")
                        .padding(12)
                        .frame(maxWidth: 300)
                        .background(
                            Color(uiColor: .systemBackground),
                            in: RoundedRectangle(cornerRadius: 12)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(.secondary.opacity(0.25))
                        }
                } else  {
                    answerFeedback
                }

            }

        }
        .padding(24)
        .frame(maxWidth: .infinity, minHeight: 220)
        .background {
            RoundedRectangle(cornerRadius: 24.0)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                .overlay {
                    RoundedRectangle(cornerRadius: 24.0)
                        .fill(Color.accentColor.opacity(isAnswer ? 0.10 : 0))
                }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(
                    isAnswer ? Color.accentColor.opacity(0.25) : Color.secondary.opacity(0.18),
                    lineWidth: 1.0
                )
        }
    }
    
    private var answerFeedback: some View {
        let entered = wordTyped.trimmingCharacters(in: .whitespacesAndNewlines)
        let expected = answer.trimmingCharacters(in: .whitespacesAndNewlines)
        let matches = entered.compare(expected, options: .caseInsensitive) == .orderedSame

        return Label(
            entered.isEmpty ? "No answer entered" : (matches ? "Correct" : "Incorrect"),
            systemImage: entered.isEmpty ? "minus.circle" :
                (matches ? "checkmark.circle.fill" : "xmark.circle")
        )
        .font(.subheadline.weight(.medium))
        .foregroundStyle(matches && !entered.isEmpty ? Color.green : Color.secondary)
    }
}

#Preview {
    @Previewable @State var isFlipped = false
    @Previewable @State var wordTyped = ""
    VStack(spacing: 20) {
        FlashcardView(
            typeTheWord: true,
            prompt: "水",
            answer: "shuǐ\nwater",
            angle: isFlipped ? 180 : 0
        )
        .animation(.easeInOut(duration: 0.35), value: isFlipped)
        
        Button(isFlipped ? "Show prompt" : "Show answer") {
            isFlipped.toggle()
        }
    }
    .padding()
}
