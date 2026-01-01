// SettingsView.swift
// Settings view with iOS 26 glass design

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var bedtimeEnabled = false
    @State private var bedtimeHour = 23
    @State private var bedtimeMinute = 0
    @State private var showEditProfile = false
    @State private var showChangePassword = false
    @State private var showLogoutAlert = false
    @AppStorage("selectedTheme") private var selectedTheme = 0 // 0: system, 1: light, 2: dark
    
    private let notificationManager = NotificationManager.shared
    
    var body: some View {
        NavigationStack {
            List {
                // User Header
                userHeader
                
                // Appearance
                Section {
                    Picker("主题模式", selection: $selectedTheme) {
                        Text("跟随系统").tag(0)
                        Text("浅色").tag(1)
                        Text("深色").tag(2)
                    }
                } header: {
                    Label("外观", systemImage: "paintbrush")
                }
                
                // Reminders
                Section {
                    Toggle("早睡提醒", isOn: $bedtimeEnabled)
                        .onChange(of: bedtimeEnabled) { _, newValue in
                            Task {
                                if newValue {
                                    await notificationManager.scheduleBedtimeReminder(hour: bedtimeHour, minute: bedtimeMinute)
                                } else {
                                    notificationManager.cancelBedtimeReminder()
                                }
                                saveBedtimeSettings()
                            }
                        }
                    
                    if bedtimeEnabled {
                        HStack {
                            Text("提醒时间")
                            Spacer()
                            Text(String(format: "%02d:%02d", bedtimeHour, bedtimeMinute))
                                .foregroundStyle(.blue)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // Would show time picker
                        }
                    }
                } header: {
                    Label("提醒设置", systemImage: "bell.fill")
                }
                
                // Account
                Section {
                    Button(action: { showChangePassword = true }) {
                        HStack {
                            Label("修改密码", systemImage: "lock.fill")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .foregroundStyle(.primary)
                    
                    Button(action: { showLogoutAlert = true }) {
                        Label("退出登录", systemImage: "rectangle.portrait.and.arrow.right")
                            .foregroundStyle(.red)
                    }
                } header: {
                    Label("账户安全", systemImage: "shield.fill")
                }
                
                // About
                Section {
                    HStack {
                        Label("版本", systemImage: "sparkles")
                        Spacer()
                        Text("2.0.0")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Label("关于", systemImage: "info.circle.fill")
                }
            }
            .navigationTitle("设置")
            .sheet(isPresented: $showEditProfile) {
                EditProfileSheet()
            }
            .sheet(isPresented: $showChangePassword) {
                ChangePasswordSheet()
            }
            .alert("退出登录", isPresented: $showLogoutAlert) {
                Button("取消", role: .cancel) {}
                Button("退出", role: .destructive) {
                    authManager.logout()
                }
            } message: {
                Text("确定要退出当前账号吗？")
            }
            .onAppear {
                loadBedtimeSettings()
            }
        }
    }
    
    // MARK: - User Header
    
    private var userHeader: some View {
        Section {
            HStack(spacing: 16) {
                // Avatar
                Text(authManager.user?.avatar ?? "👤")
                    .font(.system(size: 36))
                    .frame(width: 64, height: 64)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(authManager.user?.displayName ?? "未设置昵称")
                        .font(.title3.weight(.semibold))
                    Text(authManager.user?.phoneNumber ?? "")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button(action: { showEditProfile = true }) {
                    Image(systemName: "pencil")
                        .padding(8)
                        .background(.regularMaterial)
                        .clipShape(Circle())
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    private func loadBedtimeSettings() {
        bedtimeEnabled = UserDefaults.standard.bool(forKey: "bedtime_enabled")
        bedtimeHour = UserDefaults.standard.integer(forKey: "bedtime_hour")
        if bedtimeHour == 0 { bedtimeHour = 23 }
        bedtimeMinute = UserDefaults.standard.integer(forKey: "bedtime_minute")
    }
    
    private func saveBedtimeSettings() {
        UserDefaults.standard.set(bedtimeEnabled, forKey: "bedtime_enabled")
        UserDefaults.standard.set(bedtimeHour, forKey: "bedtime_hour")
        UserDefaults.standard.set(bedtimeMinute, forKey: "bedtime_minute")
    }
}

// MARK: - Edit Profile Sheet

struct EditProfileSheet: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    @State private var nickname: String = ""
    @State private var selectedAvatar: String = ""
    
    private let avatarOptions = ["😀", "😎", "🤖", "👨‍💻", "👩‍💻", "🦊", "🐱", "🐶",
                                 "🌟", "🚀", "💎", "🎯", "🎨", "🎵", "📚", "💡"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Current Avatar
                Text(selectedAvatar.isEmpty ? "👤" : selectedAvatar)
                    .font(.system(size: 48))
                    .frame(width: 80, height: 80)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                
                // Avatar Options
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 10) {
                    ForEach(avatarOptions, id: \.self) { emoji in
                        Button(action: { selectedAvatar = emoji }) {
                            Text(emoji)
                                .font(.title2)
                                .frame(width: 44, height: 44)
                                .background(
                                    selectedAvatar == emoji
                                        ? Color.blue.opacity(0.1)
                                        : .regularMaterial
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedAvatar == emoji ? Color.blue : Color.clear, lineWidth: 2)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // Nickname
                TextField("昵称", text: $nickname)
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Spacer()
            }
            .padding()
            .navigationTitle("编辑个人信息")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        Task {
                            await authManager.updateProfile(
                                nickname: nickname.isEmpty ? nil : nickname,
                                avatar: selectedAvatar.isEmpty ? nil : selectedAvatar
                            )
                            dismiss()
                        }
                    }
                }
            }
            .onAppear {
                nickname = authManager.user?.nickname ?? ""
                selectedAvatar = authManager.user?.avatar ?? ""
            }
        }
    }
}

// MARK: - Change Password Sheet

struct ChangePasswordSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var oldPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var error: String?
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                SecureField("当前密码", text: $oldPassword)
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                SecureField("新密码（至少6位）", text: $newPassword)
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                SecureField("确认新密码", text: $confirmPassword)
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                if let error = error {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("修改密码")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("确认") {
                        changePassword()
                    }
                    .disabled(isLoading)
                }
            }
        }
    }
    
    private func changePassword() {
        guard !oldPassword.isEmpty else {
            error = "请输入当前密码"
            return
        }
        guard newPassword.count >= 6 else {
            error = "新密码至少6位"
            return
        }
        guard newPassword == confirmPassword else {
            error = "两次密码不一致"
            return
        }
        
        isLoading = true
        error = nil
        
        Task {
            do {
                try await APIService.shared.changePassword(oldPassword: oldPassword, newPassword: newPassword)
                dismiss()
            } catch {
                self.error = "当前密码错误"
            }
            isLoading = false
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthManager())
}
