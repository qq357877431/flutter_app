// APIService.swift
// Network service for API communication

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case serverError(String)
    case decodingError
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "无效的URL"
        case .invalidResponse: return "服务器响应异常"
        case .unauthorized: return "登录已过期，请重新登录"
        case .serverError(let msg): return msg
        case .decodingError: return "数据解析失败"
        case .networkError(let error): return error.localizedDescription
        }
    }
}

@MainActor
class APIService: ObservableObject {
    static let shared = APIService()
    
    private let baseURL = "http://120.27.115.89:8080/api"
    private var token: String?
    
    private init() {
        loadToken()
    }
    
    func setToken(_ token: String) {
        self.token = token
        UserDefaults.standard.set(token, forKey: "jwt_token")
    }
    
    func loadToken() {
        token = UserDefaults.standard.string(forKey: "jwt_token")
    }
    
    func clearToken() {
        token = nil
        UserDefaults.standard.removeObject(forKey: "jwt_token")
    }
    
    var hasToken: Bool { token != nil }
    
    // MARK: - Request Helper
    
    private func request<T: Codable>(
        endpoint: String,
        method: String = "GET",
        body: [String: Any]? = nil
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            if httpResponse.statusCode == 401 {
                clearToken()
                throw APIError.unauthorized
            }
            
            if httpResponse.statusCode >= 400 {
                if let errorMsg = try? JSONDecoder().decode([String: String].self, from: data),
                   let msg = errorMsg["error"] ?? errorMsg["message"] {
                    throw APIError.serverError(msg)
                }
                throw APIError.serverError("请求失败")
            }
            
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            print("Decoding error: \(error)")
            throw APIError.decodingError
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    // MARK: - Auth
    
    func login(account: String, password: String) async throws -> AuthResponse {
        struct LoginRequest: Codable { let account, password: String }
        
        guard let url = URL(string: baseURL + "/auth/login") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(LoginRequest(account: account, password: password))
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode >= 400 {
            if let errorMsg = try? JSONDecoder().decode([String: String].self, from: data),
               let msg = errorMsg["error"] ?? errorMsg["message"] {
                throw APIError.serverError(msg)
            }
            throw APIError.serverError("登录失败")
        }
        
        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
        setToken(authResponse.token)
        return authResponse
    }
    
    func register(username: String, phoneNumber: String, password: String) async throws -> AuthResponse {
        guard let url = URL(string: baseURL + "/auth/register") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "username": username,
            "phone_number": phoneNumber,
            "password": password
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode >= 400 {
            if let errorMsg = try? JSONDecoder().decode([String: String].self, from: data),
               let msg = errorMsg["error"] ?? errorMsg["message"] {
                throw APIError.serverError(msg)
            }
            throw APIError.serverError("注册失败")
        }
        
        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
        setToken(authResponse.token)
        return authResponse
    }
    
    func verifyToken() async throws -> Bool {
        guard token != nil else { return false }
        do {
            let _: [String: String] = try await request(endpoint: "/auth/verify")
            return true
        } catch {
            clearToken()
            return false
        }
    }
    
    func getProfile() async throws -> User {
        return try await request(endpoint: "/user/profile")
    }
    
    func updateProfile(nickname: String?, avatar: String?) async throws -> User {
        var body: [String: String] = [:]
        if let nickname = nickname { body["nickname"] = nickname }
        if let avatar = avatar { body["avatar"] = avatar }
        return try await request(endpoint: "/user/profile", method: "PUT", body: body)
    }
    
    func changePassword(oldPassword: String, newPassword: String) async throws {
        let _: [String: String] = try await request(
            endpoint: "/user/password",
            method: "PUT",
            body: ["old_password": oldPassword, "new_password": newPassword]
        )
    }
    
    // MARK: - Plans
    
    func getPlans(date: String? = nil) async throws -> [Plan] {
        var endpoint = "/plans"
        if let date = date { endpoint += "?date=\(date)" }
        return try await request(endpoint: endpoint)
    }
    
    func createPlan(content: String, executionDate: String) async throws -> Plan {
        return try await request(
            endpoint: "/plans",
            method: "POST",
            body: ["content": content, "execution_date": executionDate]
        )
    }
    
    func updatePlan(id: Int, content: String? = nil, status: String? = nil) async throws -> Plan {
        var body: [String: String] = [:]
        if let content = content { body["content"] = content }
        if let status = status { body["status"] = status }
        return try await request(endpoint: "/plans/\(id)", method: "PUT", body: body)
    }
    
    func deletePlan(id: Int) async throws {
        let _: [String: String] = try await request(endpoint: "/plans/\(id)", method: "DELETE")
    }
    
    // MARK: - Expenses
    
    func getExpenses() async throws -> [Expense] {
        return try await request(endpoint: "/expenses")
    }
    
    func createExpense(amount: Double, category: String, note: String?) async throws -> Expense {
        return try await request(
            endpoint: "/expenses",
            method: "POST",
            body: ["amount": amount, "category": category, "note": note ?? ""]
        )
    }
    
    func deleteExpense(id: Int) async throws {
        let _: [String: String] = try await request(endpoint: "/expenses/\(id)", method: "DELETE")
    }
}
