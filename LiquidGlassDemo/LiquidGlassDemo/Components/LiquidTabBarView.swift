//
//  LiquidTabBarView.swift
//  LiquidGlassDemo
//
//  High-fidelity Liquid Glass Morphing Tab Bar
//  Implements Telegram/Apple Watch style metaball fusion effects
//
//  Techniques:
//  - Metaball fusion via alphaThreshold filter
//  - Physical spring animations with velocity-based deformation
//  - Home Indicator soft fusion
//  - Symbol Effects for icons
//

import SwiftUI

// MARK: - Configuration

/// Tunable parameters for the liquid glass effect
/// Adjust these values to fine-tune the visual behavior
struct LiquidConfiguration {
    /// Controls how "sticky" the liquid feels (0.0 - 1.0)
    /// Higher values = more resistance to movement
    var viscosity: CGFloat = 0.65
    
    /// Blur radius for the glass material effect
    var blurRadius: CGFloat = 25.0
    
    /// Surface tension affecting metaball merging threshold
    /// Lower values = blobs merge more easily
    var tension: CGFloat = 0.5
    
    /// Spring response time (seconds)
    var springResponse: CGFloat = 0.4
    
    /// Spring damping (0.0 = undamped, 1.0 = critically damped)
    var springDamping: CGFloat = 0.65
    
    /// Maximum stretch factor when moving fast
    var maxStretch: CGFloat = 1.25
    
    /// Maximum squash factor when decelerating
    var maxSquash: CGFloat = 0.85
    
    /// Indicator corner radius
    var indicatorRadius: CGFloat = 22.0
    
    /// Container corner radius
    var containerRadius: CGFloat = 32.0
    
    /// Metaball blob radius for fusion effect
    var blobRadius: CGFloat = 28.0
    
    static let `default` = LiquidConfiguration()
}

// MARK: - Tab Item Model

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

// MARK: - Main View

struct LiquidTabBarView: View {
    @Binding var selectedTab: LiquidTabItem
    var config: LiquidConfiguration = .default
    
    // Animation state
    @State private var indicatorOffset: CGFloat = 0
    @State private var previousOffset: CGFloat = 0
    @State private var velocity: CGFloat = 0
    @State private var stretchFactor: CGFloat = 1.0
    @State private var isAnimating: Bool = false
    
    // Touch tracking
    @State private var isDragging: Bool = false
    @State private var dragLocation: CGPoint = .zero
    
    // Haptics
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    
    var body: some View {
        GeometryReader { geometry in
            let tabWidth = geometry.size.width / CGFloat(LiquidTabItem.allCases.count)
            let containerHeight: CGFloat = 70
            
            ZStack(alignment: .bottom) {
                // Metaball Layer - Creates the liquid fusion effect
                MetaballFusionLayer(
                    selectedIndex: selectedTab.rawValue,
                    tabWidth: tabWidth,
                    containerHeight: containerHeight,
                    indicatorOffset: indicatorOffset,
                    stretchFactor: stretchFactor,
                    config: config
                )
                
                // Glass Container with soft Home Indicator fusion
                GlassContainerView(
                    config: config,
                    containerHeight: containerHeight
                )
                
                // Tab Items
                HStack(spacing: 0) {
                    ForEach(LiquidTabItem.allCases) { tab in
                        LiquidTabButton(
                            tab: tab,
                            isSelected: selectedTab == tab,
                            config: config
                        ) {
                            selectTab(tab, tabWidth: tabWidth)
                        }
                        .frame(width: tabWidth, height: containerHeight)
                    }
                }
                .frame(height: containerHeight)
            }
            .frame(height: containerHeight + 34) // Extra space for Home Indicator fusion
            .onAppear {
                impactFeedback.prepare()
                selectionFeedback.prepare()
                // Set initial position
                indicatorOffset = CGFloat(selectedTab.rawValue) * tabWidth + tabWidth / 2
                previousOffset = indicatorOffset
            }
        }
    }
    
    private func selectTab(_ tab: LiquidTabItem, tabWidth: CGFloat) {
        guard tab != selectedTab else { return }
        
        let targetOffset = CGFloat(tab.rawValue) * tabWidth + tabWidth / 2
        let distance = abs(targetOffset - indicatorOffset)
        
        // Calculate velocity for stretch effect
        velocity = (targetOffset - indicatorOffset) / max(distance, 1) * 500
        
        // Trigger haptic
        impactFeedback.impactOccurred(intensity: 0.7)
        
        // Start animation
        isAnimating = true
        
        // Stretch phase - elongate in direction of movement
        withAnimation(.easeOut(duration: 0.1)) {
            stretchFactor = velocity > 0 ? config.maxStretch : (1 / config.maxStretch)
        }
        
        // Main movement with spring
        withAnimation(.spring(
            response: config.springResponse,
            dampingFraction: config.springDamping,
            blendDuration: 0
        )) {
            selectedTab = tab
            indicatorOffset = targetOffset
        }
        
        // Squash on arrival + overshoot recovery
        DispatchQueue.main.asyncAfter(deadline: .now() + config.springResponse * 0.6) {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                stretchFactor = config.maxSquash
            }
        }
        
        // Return to normal
        DispatchQueue.main.asyncAfter(deadline: .now() + config.springResponse * 0.9) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                stretchFactor = 1.0
                isAnimating = false
            }
        }
        
        previousOffset = indicatorOffset
    }
}

// MARK: - Metaball Fusion Layer

/// Creates the liquid "pull and tear" effect using alphaThreshold
struct MetaballFusionLayer: View {
    let selectedIndex: Int
    let tabWidth: CGFloat
    let containerHeight: CGFloat
    let indicatorOffset: CGFloat
    let stretchFactor: CGFloat
    let config: LiquidConfiguration
    
    var body: some View {
        Canvas { context, size in
            // Create metaball shapes that will fuse together
            
            // Container blob (background bar shape)
            let containerRect = CGRect(
                x: config.containerRadius,
                y: size.height - containerHeight - 20,
                width: size.width - config.containerRadius * 2,
                height: containerHeight
            )
            
            let containerPath = RoundedRectangle(cornerRadius: config.containerRadius)
                .path(in: containerRect)
            
            // Selection indicator blob
            let indicatorWidth = tabWidth * 0.7 * stretchFactor
            let indicatorHeight = 44 / stretchFactor
            let indicatorRect = CGRect(
                x: indicatorOffset - indicatorWidth / 2,
                y: size.height - containerHeight - 20 + (containerHeight - indicatorHeight) / 2,
                width: indicatorWidth,
                height: indicatorHeight
            )
            
            let indicatorPath = RoundedRectangle(cornerRadius: config.indicatorRadius)
                .path(in: indicatorRect)
            
            // Bridge blobs for liquid connection effect
            let bridgeRadius = config.blobRadius
            
            // Left bridge blob
            let leftBridgeCenter = CGPoint(
                x: indicatorRect.minX + bridgeRadius * 0.3,
                y: indicatorRect.midY
            )
            let leftBridgePath = Circle().path(in: CGRect(
                x: leftBridgeCenter.x - bridgeRadius,
                y: leftBridgeCenter.y - bridgeRadius,
                width: bridgeRadius * 2,
                height: bridgeRadius * 2
            ))
            
            // Right bridge blob
            let rightBridgeCenter = CGPoint(
                x: indicatorRect.maxX - bridgeRadius * 0.3,
                y: indicatorRect.midY
            )
            let rightBridgePath = Circle().path(in: CGRect(
                x: rightBridgeCenter.x - bridgeRadius,
                y: rightBridgeCenter.y - bridgeRadius,
                width: bridgeRadius * 2,
                height: bridgeRadius * 2
            ))
            
            // Draw all blobs with the same color for alphaThreshold fusion
            context.addFilter(.alphaThreshold(min: config.tension, color: .white))
            context.addFilter(.blur(radius: config.blurRadius))
            
            context.drawLayer { ctx in
                ctx.fill(containerPath, with: .color(.white))
                ctx.fill(indicatorPath, with: .color(.white))
                ctx.fill(leftBridgePath, with: .color(.white))
                ctx.fill(rightBridgePath, with: .color(.white))
            }
        }
        .compositingGroup()
        .opacity(0.15)
        .blendMode(.plusLighter)
    }
}

// MARK: - Glass Container

struct GlassContainerView: View {
    let config: LiquidConfiguration
    let containerHeight: CGFloat
    
    var body: some View {
        VStack(spacing: 0) {
            // Main glass container
            RoundedRectangle(cornerRadius: config.containerRadius, style: .continuous)
                .fill(.ultraThinMaterial)
                .frame(height: containerHeight)
                .overlay(
                    // Top edge highlight
                    RoundedRectangle(cornerRadius: config.containerRadius, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.5),
                                    .white.opacity(0.2),
                                    .white.opacity(0.05),
                                    .clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 0.5
                        )
                )
                .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
            
            // Home Indicator fusion zone - gradual fade
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(.systemBackground).opacity(0.3),
                            Color(.systemBackground).opacity(0.1),
                            .clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 34)
                .blur(radius: 10)
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Tab Button

struct LiquidTabButton: View {
    let tab: LiquidTabItem
    let isSelected: Bool
    let config: LiquidConfiguration
    let action: () -> Void
    
    @State private var isPressed: Bool = false
    @State private var symbolBounce: Bool = false
    
    var body: some View {
        Button(action: {
            triggerSymbolEffect()
            action()
        }) {
            VStack(spacing: 4) {
                // Icon with Symbol Effect
                Image(systemName: tab.icon)
                    .font(.system(size: isSelected ? 24 : 20, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(isSelected ? .primary : .secondary)
                    .symbolEffect(.bounce, value: symbolBounce)
                    .scaleEffect(isPressed ? 0.85 : 1.0)
                    .animation(
                        .spring(response: 0.2, dampingFraction: 0.6),
                        value: isPressed
                    )
                
                // Label
                Text(tab.label)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? .primary : .tertiary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(LiquidButtonStyle(isPressed: $isPressed))
    }
    
    private func triggerSymbolEffect() {
        symbolBounce.toggle()
    }
}

// MARK: - Button Style

struct LiquidButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, pressed in
                isPressed = pressed
            }
    }
}

// MARK: - Selection Indicator Overlay

struct SelectionIndicatorView: View {
    let tabWidth: CGFloat
    let selectedIndex: Int
    let stretchFactor: CGFloat
    let config: LiquidConfiguration
    
    var body: some View {
        GeometryReader { geometry in
            let indicatorWidth = tabWidth * 0.65 * stretchFactor
            let xOffset = CGFloat(selectedIndex) * tabWidth + (tabWidth - indicatorWidth) / 2
            
            RoundedRectangle(cornerRadius: config.indicatorRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.4),
                            .white.opacity(0.2)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: indicatorWidth, height: 44 / stretchFactor)
                .overlay(
                    RoundedRectangle(cornerRadius: config.indicatorRadius, style: .continuous)
                        .strokeBorder(.white.opacity(0.3), lineWidth: 0.5)
                )
                .shadow(color: .white.opacity(0.2), radius: 8, y: 0)
                .offset(x: xOffset)
                .animation(
                    .spring(
                        response: config.springResponse,
                        dampingFraction: config.springDamping,
                        blendDuration: 0
                    ),
                    value: selectedIndex
                )
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        // Background
        LinearGradient(
            colors: [
                Color(red: 0.1, green: 0.1, blue: 0.2),
                Color(red: 0.05, green: 0.05, blue: 0.15)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        
        VStack {
            Spacer()
            
            // Demo content
            Text("Liquid Glass Demo")
                .font(.largeTitle.bold())
                .foregroundColor(.white)
            
            Spacer()
            
            // Tab Bar
            LiquidTabBarView(
                selectedTab: .constant(.home),
                config: LiquidConfiguration(
                    viscosity: 0.7,
                    blurRadius: 30,
                    tension: 0.5
                )
            )
        }
    }
    .preferredColorScheme(.dark)
}
