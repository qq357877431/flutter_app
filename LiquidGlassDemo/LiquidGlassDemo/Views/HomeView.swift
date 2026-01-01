//
//  HomeView.swift
//  LiquidGlassDemo
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "drop.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.cyan, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .cyan.opacity(0.5), radius: 20)
            
            Text("Liquid Glass")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("iOS 26 Tab Bar Demo")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
            
            Spacer()
            
            VStack(spacing: 12) {
                FeatureRow(icon: "hand.tap.fill", text: "Touch the tab bar to see fluid deformation")
                FeatureRow(icon: "sparkles", text: "Metaball blending between tabs")
                FeatureRow(icon: "eye.fill", text: "Real-time glass morphism effects")
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.cyan)
                .frame(width: 30)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        HomeView()
    }
}
