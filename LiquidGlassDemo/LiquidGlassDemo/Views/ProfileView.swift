//
//  ProfileView.swift
//  LiquidGlassDemo
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.pink, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 120, height: 120)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                )
                .shadow(color: .pink.opacity(0.5), radius: 20)
            
            Text("User Profile")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Text("Demo Account")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
            
            Spacer()
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ProfileView()
    }
}
