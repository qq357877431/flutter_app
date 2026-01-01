//
//  SettingsView.swift
//  LiquidGlassDemo
//

import SwiftUI

struct SettingsView: View {
    @State private var hapticEnabled = true
    @State private var animationsEnabled = true
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Settings")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 60)
            
            VStack(spacing: 16) {
                SettingToggle(
                    icon: "hand.tap",
                    title: "Haptic Feedback",
                    isOn: $hapticEnabled
                )
                
                SettingToggle(
                    icon: "sparkles",
                    title: "Animations",
                    isOn: $animationsEnabled
                )
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
}

struct SettingToggle: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.orange)
                .frame(width: 40)
            
            Text(title)
                .foregroundColor(.white)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(.orange)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        SettingsView()
    }
}
