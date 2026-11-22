//
//  StudyReminders.swift
//  FlashCards
//
//  Created by Thành Phước Nguyễn on 22/11/26.
//

import Foundation
import UserNotifications

enum StudyReminders{
    private static let times = [
        ( id: "study.morning", hour: 8, minute: 0 ),
        ( id: "study.lunch", hour: 12, minute: 30 ),
        ( id: "study.evening", hour: 20, minute: 0 )
    ]
    
    static func enable() async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        guard try await center.requestAuthorization(options: [.alert, .sound]) else {
            return false
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Time to review"
        content.body = "Open FlashCards for a quick study session."
        content.sound = .default
        
        do {
            for time in times {
                let trigger = UNCalendarNotificationTrigger(
                    dateMatching: DateComponents(hour: time.hour, minute: time.minute),
                    repeats: true
                )
                let request = UNNotificationRequest(
                    identifier: time.id,
                    content: content,
                    trigger: trigger
                )
                
                try await center.add(request)
            }
            
            return true
        } catch {
            disable()
            throw error
        }
    }
    
    static func disable() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: times.map(\.id))
    }
}
