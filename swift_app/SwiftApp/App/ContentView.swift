// ContentView.swift
// Main TabView with iOS 26 Liquid Glass design

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        TabView(selection: $selectedTab) {
            PlanListView()
                .tabItem {
                    Label("计划", systemImage: "calendar")
                }
                .tag(0)
            
            ExpenseListView()
                .tabItem {
                    Label("记账", systemImage: "dollarsign.circle")
                }
                .tag(1)
            
            WaterTrackerView()
                .tabItem {
                    Label("喝水", systemImage: "drop")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gearshape")
                }
                .tag(3)
        }
        .tint(.blue)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
}
