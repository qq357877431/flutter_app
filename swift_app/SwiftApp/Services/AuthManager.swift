// AuthManager.swift
// Authentication state management

import SwiftUI

@MainActor
class AuthManager: ObservableObject {
    @Published var user: User?
    @Published var isLoggedIn = false
    @Published var isLoading = false
    @Published var error: String?
    
    private let api = APIService.shared
    
    init() {
        Task {
            await checkAuth()
        }
    }
    
    func checkAuth() async {
        guard api.hasToken else {
            isLoggedIn = false
            return
        }
        
        isLoading = true
        do {
            let isValid = try await api.verifyToken()
            if isValid {
                user = try await api.getProfile()
                isLoggedIn = true
            } else {
                isLoggedIn = false
            }
        } catch {
            isLoggedIn = false
        }
        isLoading = false
    }
    
    func login(account: String, password: String) async -> Bool {
        isLoading = true
        error = nil
        
        do {
            let response = try await api.login(account: account, password: password)
            user = response.user
            isLoggedIn = true
            isLoading = false
            return true
        } catch let apiError as APIError {
            error = apiError.errorDescription
            isLoading = false
            return false
        } catch {
            self.error = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    func register(username: String, phoneNumber: String, password: String) async -> Bool {
        isLoading = true
        error = nil
        
        do {
            let response = try await api.register(username: username, phoneNumber: phoneNumber, password: password)
            user = response.user
            isLoggedIn = true
            isLoading = false
            return true
        } catch let apiError as APIError {
            error = apiError.errorDescription
            isLoading = false
            return false
        } catch {
            self.error = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    func updateProfile(nickname: String?, avatar: String?) async {
        do {
            user = try await api.updateProfile(nickname: nickname, avatar: avatar)
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func logout() {
        api.clearToken()
        user = nil
        isLoggedIn = false
    }
}
