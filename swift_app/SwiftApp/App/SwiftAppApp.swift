// SwiftAppApp.swift
// Main entry point for the application

import SwiftUI

@main
struct SwiftAppApp: App {
    @StateObject private var authManager = AuthManager()
    
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
}
