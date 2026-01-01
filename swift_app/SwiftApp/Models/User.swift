// User.swift
// User data model

import Foundation

struct User: Codable {
    let id: Int
    var username: String?
    var phoneNumber: String
    var nickname: String?
    var avatar: String?
    var token: String?
    
    enum CodingKeys: String, CodingKey {
        case id, username, nickname, avatar, token
        case phoneNumber = "phone_number"
    }
    
    var displayName: String {
        if let nickname = nickname, !nickname.isEmpty {
            return nickname
        }
        if let username = username, !username.isEmpty {
            return username
        }
        return phoneNumber
    }
    
    var hasProfile: Bool {
        (nickname != nil && !nickname!.isEmpty) || (avatar != nil && !avatar!.isEmpty)
    }
}

// Login/Register response
struct AuthResponse: Codable {
    let token: String
    let user: User
}

// API response wrapper
struct APIResponse<T: Codable>: Codable {
    let data: T?
    let message: String?
    let error: String?
}
