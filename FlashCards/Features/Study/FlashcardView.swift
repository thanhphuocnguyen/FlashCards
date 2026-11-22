//
//  FlashcardView.swift
//  FlashCards
//
//  Created by Thành Phước Nguyễn on 22/11/26.
//

import SwiftUI

struct FlashcardView: View, Animatable {
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
            face("Prompt", text: prompt)
                .opacity(showAnswer ? 0 : 1)
                .accessibilityHidden(showAnswer)
            
            face("Answer", text: answer)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .opacity(showAnswer ? 1 : 0)
                .accessibilityHidden(!showAnswer)
        }
        .rotation3DEffect(.degrees(angle), axis: (x: 0, y: 1, z: 0), perspective: 0.5)
    }
    
    private func face(_ title: String, text: String) -> some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(text)
                .font(.title)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity, minHeight: 220)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(.quaternary)
        }
    }
}

#Preview {
    @Previewable @State var isFlipped = false
    VStack(spacing: 20) {
        FlashcardView(
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
