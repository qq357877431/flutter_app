//
//  SearchView.swift
//  LiquidGlassDemo
//

import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Search")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 60)
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.5))
                
                TextField("Search...", text: $searchText)
                    .foregroundColor(.white)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
            .padding(.horizontal, 20)
            
            Spacer()
            
            Image(systemName: "magnifyingglass.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .opacity(0.5)
            
            Spacer()
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        SearchView()
    }
}
