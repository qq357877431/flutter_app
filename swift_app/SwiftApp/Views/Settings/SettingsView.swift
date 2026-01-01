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
    @State private var showTimePicker = false
    @AppStorage("selectedTheme") private var selectedTheme = 0 // 0: system, 1: light, 2: dark
    
    private let notificationManager = NotificationManager.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // User Header Card
                    userHeaderCard
                    
                    // Theme Selection Card
                    themeCard
                    
                    // Reminders Card
                    remindersCard
                    
                    // Account Card
                    accountCard
                    
                    // About Card
                    aboutCard
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("设置")
            .sheet(isPresented: $showEditProfile) {
                EditProfileSheet()
            }
            .sheet(isPresented: $showChangePassword) {
                ChangePasswordSheet()
            }
            .sheet(isPresented: $showTimePicker) {
                TimePickerSheet(hour: $bedtimeHour, minute: $bedtimeMinute) {
                    Task {
                        await notificationManager.scheduleBedtimeReminder(hour: bedtimeHour, minute: bedtimeMinute)
                        saveBedtimeSettings()
                    }
                }
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
    
    // MARK: - User Header Card
    
    private var userHeaderCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Avatar
                Text(authManager.user?.avatar ?? "👤")
                    .font(.system(size: 40))
                    .frame(width: 70, height: 70)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "667eea").opacity(0.2), Color(hex: "764ba2").opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
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
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(Color(hex: "667eea"))
                }
            }
        }
        .padding(20)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Theme Card
    
    private var themeCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "paintbrush.fill")
                    .foregroundStyle(Color(hex: "8B5CF6"))
                Text("主题模式")
                    .font(.headline)
            }
            
            HStack(spacing: 12) {
                ThemeOption(
                    title: "跟随系统",
                    icon: "iphone",
                    isSelected: selectedTheme == 0,
                    color: Color(hex: "64748B")
                ) { selectedTheme = 0 }
                
                ThemeOption(
                    title: "浅色",
                    icon: "sun.max.fill",
                    isSelected: selectedTheme == 1,
                    color: Color(hex: "F59E0B")
                ) { selectedTheme = 1 }
                
                ThemeOption(
                    title: "深色",
                    icon: "moon.fill",
                    isSelected: selectedTheme == 2,
                    color: Color(hex: "6366F1")
                ) { selectedTheme = 2 }
            }
        }
        .padding(20)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Reminders Card
    
    private var remindersCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "bell.fill")
                    .foregroundStyle(Color(hex: "3B82F6"))
                Text("提醒设置")
                    .font(.headline)
            }
            
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("早睡提醒")
                            .font(.subheadline.weight(.medium))
                        Text("每天定时提醒您休息")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Toggle("", isOn: $bedtimeEnabled)
                        .labelsHidden()
                        .tint(Color(hex: "3B82F6"))
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
                }
                
                if bedtimeEnabled {
                    Divider()
                    Button(action: { showTimePicker = true }) {
                        HStack {
                            Text("提醒时间")
                                .foregroundStyle(.primary)
                            Spacer()
                            Text(String(format: "%02d:%02d", bedtimeHour, bedtimeMinute))
                                .font(.headline)
                                .foregroundStyle(Color(hex: "3B82F6"))
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                
                Divider()
                
                Button(action: {
                    Task { await notificationManager.sendTestNotification() }
                }) {
                    HStack {
                        Text("测试通知")
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "bell.badge")
                            .foregroundStyle(Color(hex: "10B981"))
                    }
                }
            }
        }
        .padding(20)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Account Card
    
    private var accountCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "shield.fill")
                    .foregroundStyle(Color(hex: "10B981"))
                Text("账户安全")
                    .font(.headline)
            }
            
            VStack(spacing: 0) {
                Button(action: { showChangePassword = true }) {
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(Color(hex: "667eea"))
                            .frame(width: 24)
                        Text("修改密码")
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.vertical, 12)
                }
                
                Divider()
                
                Button(action: { showLogoutAlert = true }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundStyle(.red)
                            .frame(width: 24)
                        Text("退出登录")
                            .foregroundStyle(.red)
                        Spacer()
                    }
                    .padding(.vertical, 12)
                }
            }
        }
        .padding(20)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - About Card
    
    private var aboutCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(Color(hex: "64748B"))
                Text("关于")
                    .font(.headline)
            }
            
            HStack {
                Text("版本")
                Spacer()
                Text("2.0.0")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
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

// MARK: - Theme Option Button

struct ThemeOption: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? .white : color)
                    .frame(width: 50, height: 50)
                    .background(isSelected ? color : color.opacity(0.1))
                    .clipShape(Circle())
                
                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(isSelected ? color : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? color.opacity(0.1) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? color.opacity(0.4) : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Time Picker Sheet

struct TimePickerSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var hour: Int
    @Binding var minute: Int
    let onSave: () -> Void
    
    @State private var tempHour: Int
    @State private var tempMinute: Int
    
    init(hour: Binding<Int>, minute: Binding<Int>, onSave: @escaping () -> Void) {
        self._hour = hour
        self._minute = minute
        self.onSave = onSave
        self._tempHour = State(initialValue: hour.wrappedValue)
        self._tempMinute = State(initialValue: minute.wrappedValue)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text(String(format: "%02d:%02d", tempHour, tempMinute))
                    .font(.system(size: 48, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "3B82F6"))
                
                HStack {
                    Picker("小时", selection: $tempHour) {
                        ForEach(0..<24, id: \.self) { h in
                            Text("\(h)时").tag(h)
                        }
                    }
                    .pickerStyle(.wheel)
                    
                    Picker("分钟", selection: $tempMinute) {
                        ForEach(0..<60, id: \.self) { m in
                            Text("\(m)分").tag(m)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                .frame(height: 180)
            }
            .padding()
            .navigationTitle("选择时间")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("确定") {
                        hour = tempHour
                        minute = tempMinute
                        onSave()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
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
            VStack(spacing: 24) {
                // Current Avatar
                Text(selectedAvatar.isEmpty ? "👤" : selectedAvatar)
                    .font(.system(size: 56))
                    .frame(width: 100, height: 100)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                    .shadow(color: Color(hex: "667eea").opacity(0.3), radius: 15, y: 8)
                
                // Avatar Options
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 12) {
                    ForEach(avatarOptions, id: \.self) { emoji in
                        Button(action: { selectedAvatar = emoji }) {
                            Text(emoji)
                                .font(.title2)
                                .frame(width: 44, height: 44)
                                .background(
                                    selectedAvatar == emoji
                                        ? Color(hex: "667eea").opacity(0.2)
                                        : Color(uiColor: .systemGray6)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedAvatar == emoji ? Color(hex: "667eea") : Color.clear, lineWidth: 2)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // Nickname
                VStack(alignment: .leading, spacing: 8) {
                    Text("昵称")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    TextField("输入昵称", text: $nickname)
                        .padding()
                        .background(Color(uiColor: .systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Spacer()
            }
            .padding(24)
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
                    .fontWeight(.semibold)
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
    @State private var showSuccess = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Lock Icon
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .padding(.top, 20)
                
                // Form Fields
                VStack(spacing: 16) {
                    PasswordField(
                        placeholder: "当前密码",
                        icon: "lock",
                        text: $oldPassword
                    )
                    
                    PasswordField(
                        placeholder: "新密码（至少6位）",
                        icon: "lock.badge.plus",
                        text: $newPassword
                    )
                    
                    PasswordField(
                        placeholder: "确认新密码",
                        icon: "lock.rotation",
                        text: $confirmPassword
                    )
                }
                
                if let error = error {
                    HStack {
                        Image(systemName: "exclamationmark.circle.fill")
                        Text(error)
                    }
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.red.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                Spacer()
                
                // Submit Button
                Button(action: changePassword) {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("确认修改")
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .foregroundStyle(.white)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: Color(hex: "667eea").opacity(0.3), radius: 15, y: 6)
                .disabled(isLoading)
            }
            .padding(24)
            .navigationTitle("修改密码")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
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

// MARK: - Password Field

struct PasswordField: View {
    let placeholder: String
    let icon: String
    @Binding var text: String
    @State private var isSecure = true
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Color(hex: "667eea"))
                .frame(width: 24)
            
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
            
            Button(action: { isSecure.toggle() }) {
                Image(systemName: isSecure ? "eye.slash" : "eye")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(uiColor: .systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthManager())
}
