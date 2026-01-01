// WaterRecord.swift
// Water tracking data model

import SwiftUI

struct WaterRecord: Codable, Identifiable {
    var id = UUID()
    var type: String
    var amount: Int
    var time: Date
    var iconCodePoint: Int
    var colorValue: UInt
    
    enum CodingKeys: String, CodingKey {
        case type, amount, time, iconCodePoint, colorValue
    }
    
    init(type: String, amount: Int, time: Date = Date(), iconCodePoint: Int, colorValue: UInt) {
        self.type = type
        self.amount = amount
        self.time = time
        self.iconCodePoint = iconCodePoint
        self.colorValue = colorValue
    }
}

// Drink types
struct DrinkType: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    let defaultAmount: Int
    
    static let allTypes: [DrinkType] = [
        DrinkType(name: "白开水", icon: "drop.fill", color: Color(hex: "42A5F5"), defaultAmount: 250),
        DrinkType(name: "茶", icon: "cup.and.saucer.fill", color: Color(hex: "66BB6A"), defaultAmount: 200),
        DrinkType(name: "咖啡", icon: "cup.and.saucer.fill", color: Color(hex: "6D4C41"), defaultAmount: 150),
        DrinkType(name: "牛奶", icon: "cup.and.saucer.fill", color: Color(hex: "FFA726"), defaultAmount: 250),
        DrinkType(name: "奶茶", icon: "bubbles.and.sparkles.fill", color: Color(hex: "BCAAA4"), defaultAmount: 500),
        DrinkType(name: "果汁", icon: "wineglass.fill", color: Color(hex: "FFB74D"), defaultAmount: 300),
        DrinkType(name: "饮料", icon: "waterbottle.fill", color: Color(hex: "EF5350"), defaultAmount: 330),
        DrinkType(name: "其他", icon: "plus.circle", color: Color(hex: "90A4AE"), defaultAmount: 200),
    ]
}

// Color extension for hex values
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
