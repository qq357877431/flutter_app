// Plan.swift
// Plan data model

import Foundation

struct Plan: Codable, Identifiable {
    let id: Int?
    var content: String
    var executionDate: Date
    var status: String
    
    var isCompleted: Bool {
        status == "completed"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, content, status
        case executionDate = "execution_date"
    }
    
    init(id: Int? = nil, content: String, executionDate: Date, status: String = "pending") {
        self.id = id
        self.content = content
        self.executionDate = executionDate
        self.status = status
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        content = try container.decode(String.self, forKey: .content)
        status = try container.decodeIfPresent(String.self, forKey: .status) ?? "pending"
        
        let dateString = try container.decode(String.self, forKey: .executionDate)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        executionDate = formatter.date(from: dateString) ?? Date()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(content, forKey: .content)
        try container.encode(status, forKey: .status)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        try container.encode(formatter.string(from: executionDate), forKey: .executionDate)
    }
}
