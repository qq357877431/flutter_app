//
//  ContentView.swift
//  LiquidGlassDemo
//
//  Root view with Liquid Glass Tab Bar integration
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: TabItem = .home
    @State private var touchLocation: CGPoint? = nil
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.15),
                        Color(red: 0.1, green: 0.08, blue: 0.2),
                        Color(red: 0.08, green: 0.12, blue: 0.25)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Animated background orbs
                BackgroundOrbs()
                
                // Content area
                VStack(spacing: 0) {
                    // Main content based on selected tab
                    Group {
                        switch selectedTab {
                        case .home:
                            HomeView()
                        case .search:
                            SearchView()
                        case .profile:
                            ProfileView()
                        case .settings:
                            SettingsView()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // Spacer for tab bar
                    Color.clear
                        .frame(height: 100)
                }
                
                // Liquid Glass Tab Bar
                LiquidGlassTabBar(
                    selectedTab: $selectedTab,
                    touchLocation: $touchLocation
                )
                .frame(height: 100)
                .padding(.horizontal, 20)
                .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? 0 : 20)
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Background Orbs Animation
struct BackgroundOrbs: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Large ambient orbs
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.purple.opacity(0.3),
                            Color.purple.opacity(0.0)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .offset(x: animate ? -50 : 50, y: animate ? -100 : -150)
                .blur(radius: 60)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.blue.opacity(0.25),
                            Color.blue.opacity(0.0)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 180
                    )
                )
                .frame(width: 350, height: 350)
                .offset(x: animate ? 100 : 50, y: animate ? 200 : 250)
                .blur(radius: 50)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.cyan.opacity(0.2),
                            Color.cyan.opacity(0.0)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)
                .offset(x: animate ? -80 : -120, y: animate ? 100 : 50)
                .blur(radius: 40)
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 8)
                .repeatForever(autoreverses: true)
            ) {
                animate = true
            }
        }
    }
}

#Preview {
    ContentView()
}
