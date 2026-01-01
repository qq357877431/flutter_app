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
            Group {
                if authManager.isCheckingAuth {
                    // Show splash screen while checking auth
                    SplashView()
                } else if authManager.isLoggedIn {
                    ContentView()
                        .environmentObject(authManager)
                } else {
                    LoginView()
                        .environmentObject(authManager)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: authManager.isLoggedIn)
            .animation(.easeInOut(duration: 0.3), value: authManager.isCheckingAuth)
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

// MARK: - Splash View
struct SplashView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.white)
                
                Text("Plan Manager")
                    .font(.title.bold())
                    .foregroundStyle(.white)
                
                ProgressView()
                    .tint(.white)
            }
        }
    }
}
