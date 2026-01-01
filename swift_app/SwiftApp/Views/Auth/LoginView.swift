// LoginView.swift
// Login and registration screen with glass effect

import SwiftUI
import UIKit

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    
    @State private var isLogin = true
    @State private var account = ""
    @State private var username = ""
    @State private var phoneNumber = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @State private var accountError: String?
    @State private var usernameError: String?
    @State private var phoneError: String?
    @State private var passwordError: String?
    @State private var confirmPasswordError: String?
    
    var body: some View {
        ZStack {
            // Animated gradient background
            MeshGradientBackground()
            
            ScrollView {
                VStack(spacing: 32) {
                    Spacer(minLength: 60)
                    
                    // Logo
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.white)
                        .frame(width: 100, height: 100)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                        .shadow(color: Color(hex: "667eea").opacity(0.4), radius: 30, y: 10)
                    
                    // Title
                    VStack(spacing: 8) {
                        Text("Plan Manager")
                            .font(.system(size: 32, weight: .bold))
                        Text("规划生活，记录点滴")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    // Glass Card
                    VStack(spacing: 20) {
                        if isLogin {
                            InputField(
                                text: $account,
                                placeholder: "用户名 / 手机号",
                                icon: "person",
                                error: accountError
                            )
                            
                            InputField(
                                text: $password,
                                placeholder: "密码",
                                icon: "lock",
                                isSecure: true,
                                error: passwordError
                            )
                        } else {
                            InputField(
                                text: $username,
                                placeholder: "用户名（登录用）",
                                icon: "person",
                                error: usernameError
                            )
                            
                            InputField(
                                text: $phoneNumber,
                                placeholder: "手机号",
                                icon: "phone",
                                keyboardType: .phonePad,
                                error: phoneError
                            )
                            
                            InputField(
                                text: $password,
                                placeholder: "密码（至少6位）",
                                icon: "lock",
                                isSecure: true,
                                error: passwordError
                            )
                            
                            InputField(
                                text: $confirmPassword,
                                placeholder: "确认密码",
                                icon: "lock",
                                isSecure: true,
                                error: confirmPasswordError
                            )
                        }
                        
                        if let error = authManager.error {
                            HStack {
                                Image(systemName: "exclamationmark.circle")
                                Text(error)
                                    .font(.caption)
                            }
                            .foregroundStyle(.red)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // Submit Button
                        Button(action: submit) {
                            if authManager.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text(isLogin ? "登录" : "注册")
                                    .font(.headline)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .foregroundStyle(.white)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color(hex: "667eea").opacity(0.3), radius: 20, y: 8)
                        .disabled(authManager.isLoading)
                    }
                    .padding(32)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    
                    // Switch mode
                    Button(action: switchMode) {
                        HStack(spacing: 4) {
                            Text(isLogin ? "没有账号？" : "已有账号？")
                                .foregroundStyle(.secondary)
                            Text(isLogin ? "立即注册" : "立即登录")
                                .fontWeight(.semibold)
                                .foregroundStyle(Color(hex: "667eea"))
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
            }
        }
    }
    
    private func validate() -> Bool {
        var isValid = true
        
        if isLogin {
            accountError = account.isEmpty ? "请输入用户名或手机号" : nil
            passwordError = password.isEmpty ? "请输入密码" : nil
            isValid = account.isEmpty == false && password.isEmpty == false
        } else {
            usernameError = username.isEmpty ? "请输入用户名" : (username.count < 3 ? "用户名至少3位" : nil)
            phoneError = phoneNumber.isEmpty ? "请输入手机号" : (phoneNumber.count != 11 ? "请输入有效的手机号" : nil)
            passwordError = password.isEmpty ? "请输入密码" : (password.count < 6 ? "密码至少6位" : nil)
            confirmPasswordError = confirmPassword.isEmpty ? "请确认密码" : (confirmPassword != password ? "两次密码不一致" : nil)
            
            isValid = usernameError == nil && phoneError == nil && passwordError == nil && confirmPasswordError == nil
        }
        
        return isValid
    }
    
    private func submit() {
        guard validate() else { return }
        
        Task {
            if isLogin {
                await authManager.login(account: account, password: password)
            } else {
                await authManager.register(username: username, phoneNumber: phoneNumber, password: password)
            }
        }
    }
    
    private func switchMode() {
        withAnimation {
            isLogin.toggle()
            accountError = nil
            usernameError = nil
            phoneError = nil
            passwordError = nil
            confirmPasswordError = nil
        }
    }
}

// MARK: - Input Field Component

struct InputField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    var error: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(.secondary)
                
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                }
            }
            .padding(16)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(error != nil ? Color.red : Color.clear, lineWidth: 1)
            )
            
            if let error = error {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.leading, 6)
            }
        }
    }
}

// MARK: - Mesh Gradient Background

struct MeshGradientBackground: View {
    @State private var animationPhase = 0.0
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                
                // Background
                context.fill(
                    Path(CGRect(origin: .zero, size: size)),
                    with: .color(Color(uiColor: .systemBackground))
                )
                
                // Animated orbs
                drawOrb(context: context, size: size, 
                       center: CGPoint(x: size.width * 0.2 + cos(t * 0.5) * 30,
                                      y: size.height * 0.2 + sin(t * 0.5) * 30),
                       color: Color(hex: "667eea").opacity(0.4),
                       radius: size.width * 0.6)
                
                drawOrb(context: context, size: size,
                       center: CGPoint(x: size.width * 0.8 - sin(t * 0.3) * 30,
                                      y: size.height * 0.8 - cos(t * 0.3) * 30),
                       color: Color(hex: "764ba2").opacity(0.4),
                       radius: size.width * 0.5)
            }
        }
        .ignoresSafeArea()
    }
    
    private func drawOrb(context: GraphicsContext, size: CGSize, center: CGPoint, color: Color, radius: CGFloat) {
        let gradient = Gradient(colors: [color, color.opacity(0)])
        context.fill(
            Circle().path(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)),
            with: .radialGradient(gradient, center: center, startRadius: 0, endRadius: radius)
        )
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager())
}
