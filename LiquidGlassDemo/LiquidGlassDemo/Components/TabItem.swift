//
//  TabItem.swift
//  LiquidGlassDemo
//
//  Tab item model for the navigation bar
//

import SwiftUI

enum TabItem: Int, CaseIterable, Identifiable {
    case home = 0
    case search = 1
    case profile = 2
    case settings = 3
    
    var id: Int { rawValue }
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .search: return "magnifyingglass"
        case .profile: return "person.fill"
        case .settings: return "gearshape.fill"
        }
    }
    
    var label: String {
        switch self {
        case .home: return "Home"
        case .search: return "Search"
        case .profile: return "Profile"
        case .settings: return "Settings"
        }
    }
    
    var color: Color {
        switch self {
        case .home: return .cyan
        case .search: return .purple
        case .profile: return .pink
        case .settings: return .orange
        }
    }
}
