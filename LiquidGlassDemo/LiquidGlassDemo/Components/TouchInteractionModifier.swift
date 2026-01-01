//
//  TouchInteractionModifier.swift
//  LiquidGlassDemo
//
//  Touch tracking for fluid deformation effects
//

import SwiftUI

struct TouchTrackingModifier: ViewModifier {
    @Binding var touchLocation: CGPoint?
    var onTouchBegan: ((CGPoint) -> Void)?
    var onTouchMoved: ((CGPoint) -> Void)?
    var onTouchEnded: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        touchLocation = value.location
                        if value.translation == .zero {
                            onTouchBegan?(value.location)
                        } else {
                            onTouchMoved?(value.location)
                        }
                    }
                    .onEnded { _ in
                        touchLocation = nil
                        onTouchEnded?()
                    }
            )
    }
}

extension View {
    func trackingTouch(
        location: Binding<CGPoint?>,
        onBegan: ((CGPoint) -> Void)? = nil,
        onMoved: ((CGPoint) -> Void)? = nil,
        onEnded: (() -> Void)? = nil
    ) -> some View {
        modifier(TouchTrackingModifier(
            touchLocation: location,
            onTouchBegan: onBegan,
            onTouchMoved: onMoved,
            onTouchEnded: onEnded
        ))
    }
}

struct ProximityDeformationModifier: ViewModifier {
    let touchLocation: CGPoint?
    let elementCenter: CGPoint
    let maxDistance: CGFloat
    let deformationStrength: CGFloat
    
    @State private var offset: CGSize = .zero
    @State private var scale: CGFloat = 1.0
    
    func body(content: Content) -> some View {
        content
            .offset(offset)
            .scaleEffect(scale)
            .onChange(of: touchLocation) { _, location in
                updateDeformation(for: location)
            }
    }
    
    private func updateDeformation(for location: CGPoint?) {
        guard let location = location else {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                offset = .zero
                scale = 1.0
            }
            return
        }
        
        let dx = location.x - elementCenter.x
        let dy = location.y - elementCenter.y
        let distance = hypot(dx, dy)
        let influence = max(0, 1 - distance / maxDistance)
        
        withAnimation(.interactiveSpring(response: 0.15, dampingFraction: 0.5)) {
            offset = CGSize(
                width: dx * influence * deformationStrength,
                height: dy * influence * deformationStrength * 0.5
            )
            scale = 1.0 + influence * 0.15
        }
    }
}

extension View {
    func proximityDeformation(
        touchLocation: CGPoint?,
        elementCenter: CGPoint,
        maxDistance: CGFloat = 100,
        strength: CGFloat = 0.2
    ) -> some View {
        modifier(ProximityDeformationModifier(
            touchLocation: touchLocation,
            elementCenter: elementCenter,
            maxDistance: maxDistance,
            deformationStrength: strength
        ))
    }
}
