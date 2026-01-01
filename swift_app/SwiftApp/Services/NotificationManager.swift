// NotificationManager.swift
// Local notification management

import UserNotifications
import SwiftUI

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    
    private init() {
        Task {
            await requestAuthorization()
        }
    }
    
    func requestAuthorization() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            isAuthorized = granted
        } catch {
            print("Notification authorization error: \(error)")
        }
    }
    
    // MARK: - Water Reminder
    
    func scheduleWaterReminder(startHour: Int, startMinute: Int, intervalMinutes: Int, userName: String?) async {
        // Cancel existing water reminders
        for i in 0..<24 {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["water_\(i)"])
        }
        
        guard isAuthorized else { return }
        
        let greeting = userName != nil ? "\(userName!)，" : ""
        let messages = [
            "\(greeting)该喝水啦！保持水分充足 💧",
            "\(greeting)休息一下，喝杯水吧 ☕",
            "\(greeting)补充水分时间到！💦",
            "\(greeting)记得喝水哦，身体需要水分 🌊",
        ]
        
        var currentHour = startHour
        var currentMinute = startMinute
        var notificationIndex = 0
        
        while currentHour < 22 { // Until 10 PM
            var dateComponents = DateComponents()
            dateComponents.hour = currentHour
            dateComponents.minute = currentMinute
            
            let content = UNMutableNotificationContent()
            content.title = "喝水提醒"
            content.body = messages[notificationIndex % messages.count]
            content.sound = .default
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: "water_\(notificationIndex)",
                content: content,
                trigger: trigger
            )
            
            try? await UNUserNotificationCenter.current().add(request)
            
            // Calculate next time
            currentMinute += intervalMinutes
            while currentMinute >= 60 {
                currentMinute -= 60
                currentHour += 1
            }
            notificationIndex += 1
        }
    }
    
    // MARK: - Bedtime Reminder
    
    func scheduleBedtimeReminder(hour: Int, minute: Int) async {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["bedtime"])
        
        guard isAuthorized else { return }
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let content = UNMutableNotificationContent()
        content.title = "早睡提醒 🌙"
        content.body = "该准备休息了，早睡早起身体好！"
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "bedtime", content: content, trigger: trigger)
        
        try? await UNUserNotificationCenter.current().add(request)
    }
    
    func cancelBedtimeReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["bedtime"])
    }
    
    // MARK: - Plan Reminder
    
    func schedulePlanReminder(userName: String?) async {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["plan_reminder"])
        
        guard isAuthorized else { return }
        
        var dateComponents = DateComponents()
        dateComponents.hour = 21
        dateComponents.minute = 0
        
        let greeting = userName != nil ? "\(userName!)，" : ""
        
        let content = UNMutableNotificationContent()
        content.title = "计划提醒 📋"
        content.body = "\(greeting)今天还有未完成的计划，加油完成吧！"
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "plan_reminder", content: content, trigger: trigger)
        
        try? await UNUserNotificationCenter.current().add(request)
    }
    
    func cancelPlanReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["plan_reminder"])
    }
    
    // MARK: - Test Notification
    
    func sendTestNotification() async {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "测试通知"
        content.body = "通知功能正常工作！🎉"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "test", content: content, trigger: trigger)
        
        try? await UNUserNotificationCenter.current().add(request)
    }
}
