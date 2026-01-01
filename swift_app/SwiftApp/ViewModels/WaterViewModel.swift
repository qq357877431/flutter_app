// WaterViewModel.swift
// Water tracking state management

import SwiftUI

@MainActor
@Observable
class WaterViewModel {
    var records: [WaterRecord] = []
    var dailyGoal: Int = 2000
    var reminderEnabled = false
    var startHour = 8
    var startMinute = 0
    var intervalMinutes = 60
    
    private let notificationManager = NotificationManager.shared
    
    var todayTotal: Int {
        records.reduce(0) { $0 + $1.amount }
    }
    
    var progress: Double {
        min(Double(todayTotal) / Double(dailyGoal), 1.0)
    }
    
    func loadData() {
        let today = formattedDate(Date())
        if let data = UserDefaults.standard.data(forKey: "water_records_\(today)"),
           let decoded = try? JSONDecoder().decode([WaterRecord].self, from: data) {
            records = decoded
        }
        
        reminderEnabled = UserDefaults.standard.bool(forKey: "water_reminder_enabled")
        startHour = UserDefaults.standard.integer(forKey: "water_start_hour")
        if startHour == 0 { startHour = 8 }
        startMinute = UserDefaults.standard.integer(forKey: "water_start_minute")
        intervalMinutes = UserDefaults.standard.integer(forKey: "water_interval")
        if intervalMinutes == 0 { intervalMinutes = 60 }
        dailyGoal = UserDefaults.standard.integer(forKey: "water_daily_goal")
        if dailyGoal == 0 { dailyGoal = 2000 }
    }
    
    func saveData() {
        let today = formattedDate(Date())
        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: "water_records_\(today)")
        }
        
        UserDefaults.standard.set(reminderEnabled, forKey: "water_reminder_enabled")
        UserDefaults.standard.set(startHour, forKey: "water_start_hour")
        UserDefaults.standard.set(startMinute, forKey: "water_start_minute")
        UserDefaults.standard.set(intervalMinutes, forKey: "water_interval")
        UserDefaults.standard.set(dailyGoal, forKey: "water_daily_goal")
    }
    
    func addRecord(type: DrinkType, amount: Int) {
        let record = WaterRecord(
            type: type.name,
            amount: amount,
            time: Date(),
            iconCodePoint: 0,
            colorValue: 0
        )
        records.insert(record, at: 0)
        saveData()
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    func deleteRecord(at index: Int) {
        records.remove(at: index)
        saveData()
    }
    
    func scheduleReminder(userName: String?) async {
        if reminderEnabled {
            await notificationManager.scheduleWaterReminder(
                startHour: startHour,
                startMinute: startMinute,
                intervalMinutes: intervalMinutes,
                userName: userName
            )
        } else {
            // Cancel all water reminders
            for i in 0..<24 {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["water_\(i)"])
            }
        }
        saveData()
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
