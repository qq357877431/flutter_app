//
//  LiquidTabBarView.swift
//  LiquidGlassDemo
//
//  High-fidelity Liquid Glass Morphing Bottom Tab Bar
//  Telegram/Apple Watch style metaball fusion effects
//

import SwiftUI

// MARK: - Configuration

/// Tunable parameters for the liquid glass effect
struct LiquidConfiguration {
    /// Controls how "sticky" the liquid feels (0.0 - 1.0)
    var viscosity: CGFloat = 0.65
    
    /// Blur radius for metaball fusion
    var blurRadius: CGFloat = 20.0
    
    /// Surface tension affecting metaball merging (0.3 - 0.7 recommended)
    var tension: CGFloat = 0.5
    
    /// Spring response time
    var springResponse: CGFloat = 0.4
    
    /// Spring damping
    var springDamping: CGFloat = 0.65
    
    /// Maximum stretch when moving fast
    var maxStretch: CGFloat = 1.2
    
    /// Maximum squash when decelerating
    var maxSquash: CGFloat = 0.85
    
    /// Tab bar height
    var barHeight: CGFloat = 65
    
    /// Indicator size
    var indicatorSize: CGFloat = 50
    
    static let `default` = LiquidConfiguration()
}

// MARK: - Tab Item

enum LiquidTabItem: Int, CaseIterable, Identifiable {
    case home = 0
    case search = 1
    case notifications = 2
    case profile = 3
    
    var id: Int { rawValue }
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .search: return "magnifyingglass"
        case .notifications: return "bell.fill"
        case .profile: return "person.fill"
        }
    }
    
    var label: String {
        switch self {
        case .home: return "Home"
        case .search: return "Search"
        case .notifications: return "Activity"
        case .profile: return "Profile"
        }
    }
}

// MARK: - Main Tab Bar View

struct LiquidTabBarView: View {
    @Binding var selectedTab: LiquidTabItem
    var config: LiquidConfiguration = .default
    
    @State private var stretchFactor: CGFloat = 1.0
    @State private var isAnimating: Bool = false
    
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        GeometryReader { geometry in
            let tabCount = CGFloat(LiquidTabItem.allCases.count)
            let tabWidth = geometry.size.width / tabCount
            let selectedX = CGFloat(selectedTab.rawValue) * tabWidth + tabWidth / 2
            
            ZStack {
                // Layer 1: Metaball fusion background
                MetaballLayer(
                    selectedX: selectedX,
                    tabWidth: tabWidth,
                    barHeight: config.barHeight,
                    stretchFactor: stretchFactor,
                    config: config
                )
                
                // Layer 2: Glass material container
                RoundedRectangle(cornerRadius: config.barHeight / 2, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .frame(height: config.barHeight)
                    .overlay(
                        RoundedRectangle(cornerRadius: config.barHeight / 2, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [.white.opacity(0.4), .white.opacity(0.1)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 0.5
                            )
                    )
                    .shadow(color: .black.opacity(0.25), radius: 20, y: 5)
                
                // Layer 3: Selection indicator
                SelectionIndicator(
                    selectedX: selectedX,
                    stretchFactor: stretchFactor,
                    config: config
                )
                .frame(height: config.barHeight)
                
                // Layer 4: Tab buttons
                HStack(spacing: 0) {
                    ForEach(LiquidTabItem.allCases) { tab in
                        TabButton(
                            tab: tab,
                            isSelected: selectedTab == tab
                        ) {
                            selectTab(tab, from: selectedTab, tabWidth: tabWidth)
                        }
                        .frame(width: tabWidth, height: config.barHeight)
                    }
                }
                .frame(height: config.barHeight)
            }
            .frame(height: config.barHeight)
            .onAppear {
                hapticFeedback.prepare()
            }
        }
        .frame(height: config.barHeight)
    }
    
    private func selectTab(_ newTab: LiquidTabItem, from oldTab: LiquidTabItem, tabWidth: CGFloat) {
        guard newTab != oldTab else { return }
        
        let direction: CGFloat = newTab.rawValue > oldTab.rawValue ? 1 : -1
        
        hapticFeedback.impactOccurred(intensity: 0.7)
        isAnimating = true
        
        // Stretch in movement direction
        withAnimation(.easeOut(duration: 0.08)) {
            stretchFactor = direction > 0 ? config.maxStretch : (2 - config.maxStretch)
        }
        
        // Move to new tab
        withAnimation(.spring(
            response: config.springResponse,
            dampingFraction: config.springDamping,
            blendDuration: 0
        )) {
            selectedTab = newTab
        }
        
        // Squash on arrival
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                stretchFactor = config.maxSquash
            }
        }
        
        // Return to normal
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                stretchFactor = 1.0
                isAnimating = false
            }
        }
    }
}

// MARK: - Metaball Layer

struct MetaballLayer: View {
    let selectedX: CGFloat
    let tabWidth: CGFloat
    let barHeight: CGFloat
    let stretchFactor: CGFloat
    let config: LiquidConfiguration
    
    var body: some View {
        Canvas { context, size in
            // Draw metaballs that will fuse together
            context.addFilter(.alphaThreshold(min: config.tension, color: .white))
            context.addFilter(.blur(radius: config.blurRadius))
            
            context.drawLayer { ctx in
                // Main container blob
                let containerRect = CGRect(
                    x: 0,
                    y: (size.height - barHeight) / 2,
                    width: size.width,
                    height: barHeight
                )
                ctx.fill(
                    RoundedRectangle(cornerRadius: barHeight / 2)
                        .path(in: containerRect),
                    with: .color(.white)
                )
                
                // Indicator blob
                let indicatorWidth = config.indicatorSize * stretchFactor
                let indicatorHeight = config.indicatorSize / stretchFactor
                let indicatorRect = CGRect(
                    x: selectedX - indicatorWidth / 2,
                    y: size.height / 2 - indicatorHeight / 2,
                    width: indicatorWidth,
                    height: indicatorHeight
                )
                ctx.fill(
                    Ellipse().path(in: indicatorRect),
                    with: .color(.white)
                )
                
                // Bridge blobs for liquid connection
                let bridgeSize = config.indicatorSize * 0.6
                
                // Left bridge
                ctx.fill(
                    Circle().path(in: CGRect(
                        x: selectedX - indicatorWidth / 2 - bridgeSize * 0.3,
                        y: size.height / 2 - bridgeSize / 2,
                        width: bridgeSize,
                        height: bridgeSize
                    )),
                    with: .color(.white)
                )
                
                // Right bridge
                ctx.fill(
                    Circle().path(in: CGRect(
                        x: selectedX + indicatorWidth / 2 - bridgeSize * 0.7,
                        y: size.height / 2 - bridgeSize / 2,
                        width: bridgeSize,
                        height: bridgeSize
                    )),
                    with: .color(.white)
                )
            }
        }
        .opacity(0.15)
        .blendMode(.plusLighter)
    }
}

// MARK: - Selection Indicator

struct SelectionIndicator: View {
    let selectedX: CGFloat
    let stretchFactor: CGFloat
    let config: LiquidConfiguration
    
    var body: some View {
        GeometryReader { geometry in
            let indicatorWidth = config.indicatorSize * stretchFactor
            let indicatorHeight = config.indicatorSize / stretchFactor
            
            // Glowing indicator
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            .white.opacity(0.35),
                            .white.opacity(0.15),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: indicatorWidth / 2
                    )
                )
                .frame(width: indicatorWidth, height: indicatorHeight)
                .position(x: selectedX, y: geometry.size.height / 2)
                .animation(
                    .spring(
                        response: config.springResponse,
                        dampingFraction: config.springDamping,
                        blendDuration: 0
                    ),
                    value: selectedX
                )
        }
    }
}

// MARK: - Tab Button

struct TabButton: View {
    let tab: LiquidTabItem
    let isSelected: Bool
    let action: () -> Void
    
    @State private var bounceValue: Bool = false
    @State private var isPressed: Bool = false
    
    var body: some View {
        Button(action: {
            bounceValue.toggle()
            action()
        }) {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: isSelected ? 22 : 18, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.5))
                    .symbolEffect(.bounce, value: bounceValue)
                    .scaleEffect(isPressed ? 0.85 : 1.0)
                
                Text(tab.label)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.4))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(PressableButtonStyle(isPressed: $isPressed))
    }
}

struct PressableButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, newValue in
                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                    isPressed = newValue
                }
            }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        LinearGradient(
            colors: [
                Color(red: 0.08, green: 0.08, blue: 0.15),
                Color(red: 0.05, green: 0.05, blue: 0.12)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        
        VStack {
            Spacer()
            
            Text("Liquid Glass Demo")
                .font(.title.bold())
                .foregroundColor(.white)
            
            Spacer()
            
            LiquidTabBarView(selectedTab: .constant(.home))
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
        }
    }
    .preferredColorScheme(.dark)
}
