//
//  ContentView.swift
//  LiquidGlassDemo
//
//  iOS 26 Native Liquid Glass Tab Bar Demo
//  Uses SwiftUI's built-in Liquid Glass TabView
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home tab with glass effect content
            Tab("Home", systemImage: "house", value: 0) {
                HomeTabView()
            }
            
            // Search tab with interactive elements
            Tab("Search", systemImage: "magnifyingglass", value: 1, role: .search) {
                SearchTabView()
            }
            
            // Activity tab
            Tab("Activity", systemImage: "bell", value: 2) {
                ActivityTabView()
            }
            
            // Profile tab with morphing glass animations
            Tab("Profile", systemImage: "person", value: 3) {
                ProfileTabView()
            }
        }
        .tint(.white) // Sets the accent color for tab selection
        .tabViewBottomAccessory {
            NowPlayingAccessory()
        }
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}

// MARK: - Home Tab

struct HomeTabView: View {
    var body: some View {
        NavigationStack {
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
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Hero section
                        GlassHeroCard()
                        
                        // Feature cards
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            FeatureCard(icon: "drop.fill", title: "Liquid", color: .cyan)
                            FeatureCard(icon: "sparkles", title: "Glass", color: .purple)
                            FeatureCard(icon: "wand.and.stars", title: "Effects", color: .pink)
                            FeatureCard(icon: "cube.transparent", title: "3D", color: .orange)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Liquid Glass")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Settings", systemImage: "gearshape") { }
                        .glassEffect()
                }
            }
        }
    }
}

// MARK: - Glass Hero Card

struct GlassHeroCard: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "drop.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.cyan, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .cyan.opacity(0.5), radius: 20)
            
            Text("iOS 26 Liquid Glass")
                .font(.title.bold())
                .foregroundColor(.white)
            
            Text("Native Tab Bar with automatic glass morphism")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal, 20)
        .glassEffect()
        .padding(.horizontal)
    }
}

// MARK: - Feature Card

struct FeatureCard: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundStyle(color)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .glassEffect()
    }
}

// MARK: - Search Tab

struct SearchTabView: View {
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.08, green: 0.08, blue: 0.18),
                        Color(red: 0.04, green: 0.04, blue: 0.12)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                if searchText.isEmpty {
                    ContentUnavailableView(
                        "Search",
                        systemImage: "magnifyingglass",
                        description: Text("Search bar is integrated in the glass navigation bar")
                    )
                } else {
                    List {
                        ForEach(0..<10) { i in
                            Text("Result \(i + 1) for \"\(searchText)\"")
                                .foregroundStyle(.white)
                        }
                        .listRowBackground(Color.white.opacity(0.1))
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .searchable(
                text: $searchText,
                placement: .toolbar,
                prompt: "Type here to search"
            )
        }
    }
}

// MARK: - Activity Tab

struct ActivityTabView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.08, blue: 0.18),
                        Color(red: 0.05, green: 0.04, blue: 0.12)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                List {
                    ForEach(0..<20) { i in
                        HStack(spacing: 16) {
                            Circle()
                                .fill(Color.orange.opacity(0.3))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Image(systemName: "bell.fill")
                                        .foregroundStyle(.orange)
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Notification \(i + 1)")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                
                                Text("This is a sample notification")
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                            
                            Spacer()
                            
                            Text("\(i + 1)m")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.4))
                        }
                        .padding(.vertical, 8)
                        .listRowBackground(Color.white.opacity(0.05))
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Activity")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Mark All", systemImage: "checkmark.circle") { }
                        .glassEffect()
                }
            }
        }
    }
}

// MARK: - Profile Tab

struct ProfileTabView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.12, green: 0.08, blue: 0.2),
                        Color(red: 0.06, green: 0.04, blue: 0.12)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Avatar
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.purple, .pink],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.white)
                            )
                            .shadow(color: .purple.opacity(0.5), radius: 20)
                        
                        Text("User Profile")
                            .font(.title.bold())
                            .foregroundColor(.white)
                        
                        Text("iOS 26 Liquid Glass Demo")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                        
                        // Settings buttons
                        VStack(spacing: 12) {
                            ProfileButton(icon: "gearshape", title: "Settings")
                            ProfileButton(icon: "bell", title: "Notifications")
                            ProfileButton(icon: "lock", title: "Privacy")
                            ProfileButton(icon: "questionmark.circle", title: "Help")
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 40)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Edit", systemImage: "pencil") { }
                        .buttonStyle(.glassProminent)
                        .tint(.purple)
                }
            }
        }
    }
}

struct ProfileButton: View {
    let icon: String
    let title: String
    
    var body: some View {
        Button(action: {}) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 30)
                Text(title)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .glassEffect()
    }
}

// MARK: - Now Playing Accessory

struct NowPlayingAccessory: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "music.note")
                .foregroundStyle(.cyan)
            
            Text("Now Playing")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.8))
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "play.fill")
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
