// Expense.swift
// Expense data model

import Foundation

struct Expense: Codable, Identifiable {
    let id: Int?
    var amount: Double
    var category: String
    var note: String?
    var createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, amount, category, note
        case createdAt = "created_at"
    }
    
    init(id: Int? = nil, amount: Double, category: String, note: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.amount = amount
        self.category = category
        self.note = note
        self.createdAt = createdAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        amount = try container.decode(Double.self, forKey: .amount)
        category = try container.decode(String.self, forKey: .category)
        note = try container.decodeIfPresent(String.self, forKey: .note)
        
        let dateString = try container.decode(String.self, forKey: .createdAt)
        
        // Try multiple date formats
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd HH:mm:ss"
        ]
        
        var parsedDate: Date?
        for format in formats {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.timeZone = TimeZone(identifier: "UTC")
            if let date = formatter.date(from: dateString) {
                parsedDate = date
                break
            }
        }
        
        // Also try ISO8601DateFormatter
        if parsedDate == nil {
            let iso8601Formatter = ISO8601DateFormatter()
            iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            parsedDate = iso8601Formatter.date(from: dateString)
        }
        
        if parsedDate == nil {
            let iso8601Formatter = ISO8601DateFormatter()
            iso8601Formatter.formatOptions = [.withInternetDateTime]
            parsedDate = iso8601Formatter.date(from: dateString)
        }
        
        // Convert UTC to local timezone (Asia/Shanghai)
        if let utcDate = parsedDate {
            createdAt = utcDate
        } else {
            createdAt = Date()
        }
    }
}

// Expense categories
enum ExpenseCategory: String, CaseIterable {
    case food = "餐饮"
    case transport = "交通"
    case shopping = "购物"
    case entertainment = "娱乐"
    case other = "其他"
    
    var icon: String {
        switch self {
        case .food: return "cart.fill"
        case .transport: return "car.fill"
        case .shopping: return "bag.fill"
        case .entertainment: return "gamecontroller.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    var colors: [String] {
        switch self {
        case .food: return ["F59E0B", "D97706"]
        case .transport: return ["3B82F6", "2563EB"]
        case .shopping: return ["EC4899", "DB2777"]
        case .entertainment: return ["8B5CF6", "7C3AED"]
        case .other: return ["64748B", "475569"]
        }
    }
}
