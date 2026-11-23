//
//  ReviewSettingView.swift
//  FlashCards
//
//  Created by Thành Phước Nguyễn on 23/11/26.
//

import SwiftUI

struct ReviewSettingView: View {
    @AppStorage("review.hardDays") private var hardDays = 1
    @AppStorage("review.goodMinDays") private var goodMinDays = 3
    @AppStorage("review.goodMaxDays") private var goodMaxDays = 90
    
    var body: some View {
        Form {
            Section("Review Intervals") {
                Stepper("Hard: \(hardDays) days",
                        value: $hardDays, in: 1...goodMinDays
                )
                
                Stepper("Good minimum: \(goodMinDays) days",
                        value: $goodMinDays, in: hardDays...goodMaxDays
                )
                
                Stepper("Good maximum: \(goodMaxDays) days",
                        value: $goodMaxDays, in: goodMinDays...365
                )
                
            }
        }
        .navigationTitle("Review Settings")
    }
}

#Preview {
    NavigationStack {
        ReviewSettingView()
    }
    .defaultAppStorage(UserDefaults(suiteName: "FlashCards.ReviewSettingsPreview")!)
}
