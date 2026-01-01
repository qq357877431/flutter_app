//
//  MetaballRenderer.swift
//  LiquidGlassDemo
//
//  Metaball algorithm for fluid blob merging
//

import SwiftUI

struct Metaball: Identifiable {
    let id = UUID()
    var center: CGPoint
    var radius: CGFloat
    var color: Color
    
    func fieldValue(at point: CGPoint) -> CGFloat {
        let dx = point.x - center.x
        let dy = point.y - center.y
        let distanceSquared = dx * dx + dy * dy
        return (radius * radius) / max(distanceSquared, 0.0001)
    }
}

class MetaballField: ObservableObject {
    @Published var metaballs: [Metaball] = []
    private let threshold: CGFloat = 1.0
    
    init() {
        metaballs = [
            Metaball(center: .zero, radius: 25, color: .cyan),
            Metaball(center: .zero, radius: 25, color: .purple),
            Metaball(center: .zero, radius: 25, color: .pink),
            Metaball(center: .zero, radius: 25, color: .orange)
        ]
    }
    
    func fieldValue(at point: CGPoint) -> CGFloat {
        metaballs.reduce(0) { $0 + $1.fieldValue(at: point) }
    }
    
    func updateForTouch(at location: CGPoint?, in bounds: CGRect, selectedIndex: Int) {
        let tabWidth = bounds.width / CGFloat(metaballs.count)
        
        for i in 0..<metaballs.count {
            let defaultX = (CGFloat(i) + 0.5) * tabWidth
            let defaultY = bounds.height / 2
            
            if let loc = location {
                let dx = loc.x - defaultX
                let distance = abs(dx)
                let influence = max(0, 1 - distance / (tabWidth * 1.5))
                let newX = defaultX + dx * influence * 0.4
                let baseRadius: CGFloat = i == selectedIndex ? 30 : 22
                metaballs[i].center = CGPoint(x: newX, y: defaultY)
                metaballs[i].radius = baseRadius + influence * 15
            } else {
                metaballs[i].center = CGPoint(x: defaultX, y: defaultY)
                metaballs[i].radius = i == selectedIndex ? 30 : 22
            }
        }
    }
}
