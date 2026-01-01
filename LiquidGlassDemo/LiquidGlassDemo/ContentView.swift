//
//  ContentView.swift
//  LiquidGlassDemo
//
//  Root view with bottom-positioned Liquid Glass Tab Bar
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: LiquidTabItem = .home
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                BackgroundView()
                    .ignoresSafeArea()
                
                // Main layout
                VStack(spacing: 0) {
                    // Content area - takes remaining space
                    TabContentView(selectedTab: selectedTab)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // Bottom Tab Bar - fixed at bottom
                    LiquidTabBarView(selectedTab: $selectedTab)
                        .padding(.horizontal, 16)
                        .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? 0 : 16)
                }
            }
            .ignoresSafeArea(.keyboard)
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Tab Content

struct TabContentView: View {
    let selectedTab: LiquidTabItem
    
    var body: some View {
        switch selectedTab {
        case .home:
            HomeView()
        case .search:
            SearchView()
        case .notifications:
            NotificationsView()
        case .profile:
            ProfileView()
        }
    }
}

// MARK: - Background

struct BackgroundView: View {
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    Color(red: 0.06, green: 0.06, blue: 0.14),
                    Color(red: 0.04, green: 0.04, blue: 0.10)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Ambient orbs
            TimelineView(.animation(minimumInterval: 1/30)) { timeline in
                let time = timeline.date.timeIntervalSinceReferenceDate
                
                Canvas { context, size in
                    // Purple orb
                    drawOrb(
                        context: context,
                        center: CGPoint(
                            x: size.width * 0.3 + sin(time * 0.3) * 30,
                            y: size.height * 0.25 + cos(time * 0.25) * 20
                        ),
                        radius: 180,
                        color: .purple.opacity(0.25)
                    )
                    
                    // Blue orb
                    drawOrb(
                        context: context,
                        center: CGPoint(
                            x: size.width * 0.75 + cos(time * 0.35) * 25,
                            y: size.height * 0.5 + sin(time * 0.3) * 30
                        ),
                        radius: 150,
                        color: .blue.opacity(0.2)
                    )
                    
                    // Cyan orb
                    drawOrb(
                        context: context,
                        center: CGPoint(
                            x: size.width * 0.2 + cos(time * 0.4) * 20,
                            y: size.height * 0.7 + sin(time * 0.35) * 25
                        ),
                        radius: 120,
                        color: .cyan.opacity(0.18)
                    )
                }
            }
        }
    }
    
    private func drawOrb(context: GraphicsContext, center: CGPoint, radius: CGFloat, color: Color) {
        let gradient = Gradient(colors: [color, color.opacity(0)])
        context.fill(
            Circle().path(in: CGRect(
                x: center.x - radius,
                y: center.y - radius,
                width: radius * 2,
                height: radius * 2
            )),
            with: .radialGradient(gradient, center: center, startRadius: 0, endRadius: radius)
        )
    }
}

// MARK: - Views

struct NotificationsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .shadow(color: .orange.opacity(0.5), radius: 20)
            
            Text("Activity")
                .font(.title.bold())
                .foregroundColor(.white)
            
            Text("Your notifications appear here")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
            
            Spacer()
        }
    }
}

#Preview {
    ContentView()
}
