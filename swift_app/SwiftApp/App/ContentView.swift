// ContentView.swift
// Main TabView with iOS 26 Liquid Glass design

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("计划", systemImage: "calendar", value: 0) {
                PlanListView()
            }
            
            Tab("记账", systemImage: "dollarsign.circle", value: 1) {
                ExpenseListView()
            }
            
            Tab("喝水", systemImage: "drop", value: 2) {
                WaterTrackerView()
            }
            
            Tab("设置", systemImage: "gearshape", value: 3) {
                SettingsView()
            }
        }
        .tint(.primary)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
}
