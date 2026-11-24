//
//  ReviewSettingView.swift
//  FlashCards
//
//  Created by Thành Phước Nguyễn on 23/11/26.
//

import SwiftUI

struct ReviewSettingView: View {
    @AppStorage("review.hardHours") private var hardHours = 24
    @AppStorage("review.goodMinDays") private var goodMinDays = 3
    @AppStorage("review.goodMaxDays") private var goodMaxDays = 90
    
    var body: some View {
        let hourOptions = Set([1, 3, 6, 12, 24, 48, 72, hardHours]).sorted()
        Form {
            Section("Review Intervals") {
                Picker("Hard delay", selection: $hardHours) {
                    ForEach(hourOptions, id: \.self) { hours in
                        Text(hours == 1 ? "1 hour" : "\(hours) hours")
                            .tag(hours)
                    }
                }
                
                Stepper("Good minimum: \(goodMinDays) days",
                        value: $goodMinDays, in: 1...goodMaxDays
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
