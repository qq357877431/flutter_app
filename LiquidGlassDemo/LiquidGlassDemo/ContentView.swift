//
//  ContentView.swift
//  LiquidGlassDemo
//
//  Root view integrating LiquidTabBarView with demo content
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: LiquidTabItem = .home
    @State private var liquidConfig = LiquidConfiguration.default
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Animated background
                AnimatedBackgroundView()
                    .ignoresSafeArea()
                
                // Content area
                VStack(spacing: 0) {
                    // Main content based on selected tab
                    Group {
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // Space for tab bar
                    Color.clear.frame(height: 104)
                }
                
                // Liquid Glass Tab Bar
                LiquidTabBarView(
                    selectedTab: $selectedTab,
                    config: liquidConfig
                )
            }
        }
        .ignoresSafeArea(.keyboard)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Animated Background

struct AnimatedBackgroundView: View {
    @State private var phase: CGFloat = 0
    
    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            
            Canvas { context, size in
                // Base gradient
                let baseGradient = Gradient(colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.12),
                    Color(red: 0.08, green: 0.06, blue: 0.18),
                    Color(red: 0.05, green: 0.08, blue: 0.15)
                ])
                
                context.fill(
                    Rectangle().path(in: CGRect(origin: .zero, size: size)),
                    with: .linearGradient(
                        baseGradient,
                        startPoint: .zero,
                        endPoint: CGPoint(x: size.width, y: size.height)
                    )
                )
                
                // Floating orbs
                let orbConfigs: [(color: Color, baseX: CGFloat, baseY: CGFloat, radius: CGFloat, speed: CGFloat)] = [
                    (.purple.opacity(0.3), 0.3, 0.2, 200, 0.3),
                    (.blue.opacity(0.25), 0.7, 0.4, 180, 0.4),
                    (.cyan.opacity(0.2), 0.2, 0.7, 160, 0.35),
                    (.indigo.opacity(0.25), 0.8, 0.8, 140, 0.45)
                ]
                
                for orb in orbConfigs {
                    let x = orb.baseX * size.width + sin(time * orb.speed) * 50
                    let y = orb.baseY * size.height + cos(time * orb.speed * 0.8) * 40
                    
                    let gradient = Gradient(colors: [
                        orb.color,
                        orb.color.opacity(0)
                    ])
                    
                    context.fill(
                        Circle().path(in: CGRect(
                            x: x - orb.radius,
                            y: y - orb.radius,
                            width: orb.radius * 2,
                            height: orb.radius * 2
                        )),
                        with: .radialGradient(
                            gradient,
                            center: CGPoint(x: x, y: y),
                            startRadius: 0,
                            endRadius: orb.radius
                        )
                    )
                }
            }
        }
    }
}

// MARK: - Notifications View (New)

struct NotificationsView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 70))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, .red],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .orange.opacity(0.5), radius: 20)
            
            Text("Notifications")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Text("Stay updated with the latest")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
            
            Spacer()
        }
    }
}

#Preview {
    ContentView()
}
