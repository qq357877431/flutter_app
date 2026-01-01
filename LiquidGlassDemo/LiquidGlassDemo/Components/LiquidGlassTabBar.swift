//
//  LiquidGlassTabBar.swift
//  LiquidGlassDemo
//
//  iOS 26 Liquid Glass Tab Bar with Metaball effect
//  Implements fluid glass morphism with touch-reactive deformation
//

import SwiftUI

struct LiquidGlassTabBar: View {
    @Binding var selectedTab: TabItem
    @Binding var touchLocation: CGPoint?
    
    @State private var hoverIndex: Int? = nil
    @State private var pressedIndex: Int? = nil
    @State private var animationPhase: CGFloat = 0
    
    // Metaball positions for fluid effect
    @State private var metaballOffsets: [CGSize] = Array(repeating: .zero, count: 4)
    
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        GeometryReader { geometry in
            let tabWidth = geometry.size.width / CGFloat(TabItem.allCases.count)
            
            ZStack {
                // Liquid Glass Background
                LiquidGlassBackground(
                    selectedIndex: selectedTab.rawValue,
                    tabWidth: tabWidth,
                    totalWidth: geometry.size.width,
                    touchLocation: touchLocation,
                    animationPhase: animationPhase
                )
                
                // Tab Items
                HStack(spacing: 0) {
                    ForEach(TabItem.allCases) { tab in
                        TabButton(
                            tab: tab,
                            isSelected: selectedTab == tab,
                            isPressed: pressedIndex == tab.rawValue,
                            touchLocation: touchLocation,
                            tabFrame: CGRect(
                                x: CGFloat(tab.rawValue) * tabWidth,
                                y: 0,
                                width: tabWidth,
                                height: geometry.size.height
                            )
                        )
                        .frame(width: tabWidth)
                        .contentShape(Rectangle())
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    touchLocation = value.location
                                    pressedIndex = tab.rawValue
                                    updateMetaballOffsets(for: value.location, in: geometry.size, tabIndex: tab.rawValue)
                                }
                                .onEnded { _ in
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        selectedTab = tab
                                        pressedIndex = nil
                                        touchLocation = nil
                                        resetMetaballOffsets()
                                    }
                                    hapticFeedback.impactOccurred()
                                }
                        )
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
            .shadow(color: selectedTab.color.opacity(0.2), radius: 30, x: 0, y: 15)
        }
        .onAppear {
            hapticFeedback.prepare()
            startAnimationLoop()
        }
    }
    
    private func startAnimationLoop() {
        withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
            animationPhase = .pi * 2
        }
    }
    
    private func updateMetaballOffsets(for location: CGPoint, in size: CGSize, tabIndex: Int) {
        let tabWidth = size.width / CGFloat(TabItem.allCases.count)
        
        for i in 0..<metaballOffsets.count {
            let tabCenterX = (CGFloat(i) + 0.5) * tabWidth
            let distance = abs(location.x - tabCenterX)
            let maxDistance = tabWidth * 1.5
            let influence = max(0, 1 - distance / maxDistance)
            
            let dx = (location.x - tabCenterX) * influence * 0.3
            let dy = (location.y - size.height / 2) * influence * 0.2
            
            withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.6)) {
                metaballOffsets[i] = CGSize(width: dx, height: dy)
            }
        }
    }
    
    private func resetMetaballOffsets() {
        for i in 0..<metaballOffsets.count {
            metaballOffsets[i] = .zero
        }
    }
}

// MARK: - Liquid Glass Background
struct LiquidGlassBackground: View {
    let selectedIndex: Int
    let tabWidth: CGFloat
    let totalWidth: CGFloat
    let touchLocation: CGPoint?
    let animationPhase: CGFloat
    
    var body: some View {
        ZStack {
            // Base glass layer
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
            
            // Dynamic color wash
            Canvas { context, size in
                drawLiquidBackground(context: context, size: size)
            }
            .blur(radius: 30)
            .opacity(0.6)
            
            // Selection indicator blob
            SelectionBlob(
                selectedIndex: selectedIndex,
                tabWidth: tabWidth,
                touchLocation: touchLocation,
                animationPhase: animationPhase
            )
            
            // Glass noise texture overlay (simple grain effect)
            Canvas { context, size in
                // Simple procedural noise using random dots
                for _ in 0..<200 {
                    let x = CGFloat.random(in: 0..<size.width)
                    let y = CGFloat.random(in: 0..<size.height)
                    let alpha = CGFloat.random(in: 0.01..<0.05)
                    context.fill(
                        Circle().path(in: CGRect(x: x, y: y, width: 1, height: 1)),
                        with: .color(.white.opacity(alpha))
                    )
                }
            }
            .blendMode(.overlay)
        }
    }
    
    private func drawLiquidBackground(context: GraphicsContext, size: CGSize) {
        let colors: [Color] = [.cyan, .purple, .pink, .orange]
        
        for (index, color) in colors.enumerated() {
            let x = (CGFloat(index) + 0.5) * tabWidth
            let y = size.height / 2
            
            // Metaball-like gradient
            let gradient = Gradient(colors: [
                color.opacity(selectedIndex == index ? 0.6 : 0.2),
                color.opacity(0)
            ])
            
            let center = CGPoint(x: x, y: y)
            let radius = selectedIndex == index ? tabWidth * 0.8 : tabWidth * 0.4
            
            context.fill(
                Circle().path(in: CGRect(
                    x: center.x - radius,
                    y: center.y - radius,
                    width: radius * 2,
                    height: radius * 2
                )),
                with: .radialGradient(
                    gradient,
                    center: center,
                    startRadius: 0,
                    endRadius: radius
                )
            )
        }
    }
}

// MARK: - Selection Blob
struct SelectionBlob: View {
    let selectedIndex: Int
    let tabWidth: CGFloat
    let touchLocation: CGPoint?
    let animationPhase: CGFloat
    
    @State private var blobOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            let colors = TabItem.allCases.map { $0.color }
            let selectedColor = colors[selectedIndex]
            
            // Metaball blob
            Canvas { context, size in
                let centerX = (CGFloat(selectedIndex) + 0.5) * tabWidth + blobOffset
                let centerY = size.height / 2
                
                // Main blob
                drawMetaball(
                    context: context,
                    center: CGPoint(x: centerX, y: centerY),
                    radius: 35,
                    color: selectedColor
                )
                
                // Smaller satellite blobs for liquid effect
                for i in 0..<3 {
                    let angle = animationPhase + CGFloat(i) * .pi * 2 / 3
                    let orbitRadius: CGFloat = 20 + sin(animationPhase * 2) * 5
                    let satelliteX = centerX + cos(angle) * orbitRadius
                    let satelliteY = centerY + sin(angle) * orbitRadius * 0.5
                    let satelliteRadius: CGFloat = 12 + cos(animationPhase + CGFloat(i)) * 3
                    
                    drawMetaball(
                        context: context,
                        center: CGPoint(x: satelliteX, y: satelliteY),
                        radius: satelliteRadius,
                        color: selectedColor.opacity(0.6)
                    )
                }
            }
            .blur(radius: 8)
            .blendMode(.plusLighter)
            
            // Glass highlight
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.4),
                            Color.white.opacity(0.1),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 50, height: 20)
                .offset(
                    x: (CGFloat(selectedIndex) + 0.5) * tabWidth - 25 + blobOffset,
                    y: 15
                )
                .blur(radius: 3)
        }
        .onChange(of: touchLocation) { _, newLocation in
            if let location = newLocation {
                let expectedCenter = (CGFloat(selectedIndex) + 0.5) * tabWidth
                withAnimation(.interactiveSpring(response: 0.2, dampingFraction: 0.5)) {
                    blobOffset = (location.x - expectedCenter) * 0.3
                }
            } else {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    blobOffset = 0
                }
            }
        }
    }
    
    private func drawMetaball(context: GraphicsContext, center: CGPoint, radius: CGFloat, color: Color) {
        let gradient = Gradient(colors: [
            color,
            color.opacity(0.5),
            color.opacity(0)
        ])
        
        context.fill(
            Circle().path(in: CGRect(
                x: center.x - radius,
                y: center.y - radius,
                width: radius * 2,
                height: radius * 2
            )),
            with: .radialGradient(
                gradient,
                center: center,
                startRadius: 0,
                endRadius: radius
            )
        )
    }
}

// MARK: - Tab Button
struct TabButton: View {
    let tab: TabItem
    let isSelected: Bool
    let isPressed: Bool
    let touchLocation: CGPoint?
    let tabFrame: CGRect
    
    @State private var iconScale: CGFloat = 1.0
    @State private var iconOffset: CGSize = .zero
    
    var body: some View {
        VStack(spacing: 4) {
            // Icon with deformation
            Image(systemName: tab.icon)
                .font(.system(size: isSelected ? 24 : 20, weight: .semibold))
                .foregroundStyle(
                    isSelected
                        ? AnyShapeStyle(tab.color)
                        : AnyShapeStyle(Color.white.opacity(0.6))
                )
                .scaleEffect(iconScale)
                .offset(iconOffset)
                .shadow(color: isSelected ? tab.color.opacity(0.5) : .clear, radius: 8)
            
            // Label
            Text(tab.label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(isSelected ? .white : .white.opacity(0.5))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: isPressed) { _, pressed in
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                iconScale = pressed ? 0.85 : (isSelected ? 1.1 : 1.0)
            }
        }
        .onChange(of: isSelected) { _, selected in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                iconScale = selected ? 1.1 : 1.0
            }
        }
        .onChange(of: touchLocation) { _, location in
            updateIconDeformation(with: location)
        }
    }
    
    private func updateIconDeformation(with location: CGPoint?) {
        guard let location = location else {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                iconOffset = .zero
            }
            return
        }
        
        let tabCenter = CGPoint(
            x: tabFrame.midX,
            y: tabFrame.midY
        )
        
        let distance = hypot(location.x - tabCenter.x, location.y - tabCenter.y)
        let maxDistance = tabFrame.width
        let influence = max(0, 1 - distance / maxDistance)
        
        let dx = (location.x - tabCenter.x) * influence * 0.15
        let dy = (location.y - tabCenter.y) * influence * 0.1
        
        withAnimation(.interactiveSpring(response: 0.15, dampingFraction: 0.5)) {
            iconOffset = CGSize(width: dx, height: dy)
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack {
            Spacer()
            LiquidGlassTabBar(
                selectedTab: .constant(.home),
                touchLocation: .constant(nil)
            )
            .frame(height: 80)
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
    }
}
