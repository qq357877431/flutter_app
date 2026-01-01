// SwiftAppApp.swift
// Main entry point for the application

import SwiftUI
import UserNotifications

@main
struct SwiftAppApp: App {
    @StateObject private var authManager = AuthManager()
    
    init() {
        // Request notification permission on app launch
        requestNotificationPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            if authManager.isLoggedIn {
                ContentView()
                    .environmentObject(authManager)
            } else {
                LoginView()
                    .environmentObject(authManager)
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
}
