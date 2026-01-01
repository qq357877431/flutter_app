// WaterTrackerView.swift
// Water tracking view with iOS 26 glass design

import SwiftUI

struct WaterTrackerView: View {
    @State private var viewModel = WaterViewModel()
    @State private var showSettingsSheet = false
    @State private var showAddSheet = false
    @State private var selectedDrinkType: DrinkType?
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Progress Card
                    progressCard
                    
                    // Quick Add Section
                    quickAddSection
                    
                    // Today's Records
                    recordsSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("喝水记录")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showSettingsSheet = true }) {
                        Image(systemName: viewModel.reminderEnabled 
                              ? "bell.badge.fill" 
                              : "bell")
                            .padding(10)
                            .background(
                                viewModel.reminderEnabled 
                                    ? Color.blue.opacity(0.15) 
                                    : .regularMaterial
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .tint(viewModel.reminderEnabled ? .blue : .secondary)
                }
            }
            .sheet(isPresented: $showSettingsSheet) {
                WaterSettingsSheet(viewModel: viewModel, userName: authManager.user?.displayName)
            }
            .sheet(item: $selectedDrinkType) { drinkType in
                AddWaterSheet(viewModel: viewModel, drinkType: drinkType)
            }
            .onAppear {
                viewModel.loadData()
            }
        }
    }
    
    // MARK: - Progress Card
    
    private var progressCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("今日饮水")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                
                HStack(alignment: .bottom, spacing: 4) {
                    Text("\(viewModel.todayTotal)")
                        .font(.system(size: 42, weight: .bold))
                    Text("ml")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.bottom, 8)
                }
                .foregroundStyle(.white)
                
                Text("目标 \(viewModel.dailyGoal) ml")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }
            
            Spacer()
            
            // Circular Progress
            ZStack {
                Circle()
                    .stroke(.white.opacity(0.2), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: viewModel.progress)
                    .stroke(.white, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(Int(viewModel.progress * 100))%")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .frame(width: 90, height: 90)
        }
        .padding(24)
        .background(
            LinearGradient(
                colors: [Color(hex: "3B82F6"), Color(hex: "2563EB")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color(hex: "3B82F6").opacity(0.3), radius: 20, y: 10)
    }
    
    // MARK: - Quick Add Section
    
    private var quickAddSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("快速添加")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(DrinkType.allTypes) { drinkType in
                    DrinkButton(drinkType: drinkType) {
                        selectedDrinkType = drinkType
                    }
                }
            }
        }
    }
    
    // MARK: - Records Section
    
    private var recordsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今日记录")
                .font(.headline)
            
            if viewModel.records.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "drop")
                        .font(.system(size: 48))
                        .foregroundStyle(.blue.opacity(0.3))
                    Text("还没有记录")
                        .foregroundStyle(.secondary)
                    Text("点击上方添加饮水记录")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                ForEach(Array(viewModel.records.enumerated()), id: \.element.id) { index, record in
                    RecordRow(record: record)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                viewModel.deleteRecord(at: index)
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                }
            }
        }
    }
}

// MARK: - Drink Button

struct DrinkButton: View {
    let drinkType: DrinkType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: drinkType.icon)
                    .font(.title2)
                    .foregroundStyle(drinkType.color)
                Text(drinkType.name)
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
            .frame(width: 76, height: 76)
            .background(drinkType.color.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(drinkType.color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Record Row

struct RecordRow: View {
    let record: WaterRecord
    
    private var drinkType: DrinkType? {
        DrinkType.allTypes.first { $0.name == record.type }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: drinkType?.icon ?? "drop.fill")
                .font(.title3)
                .foregroundStyle(drinkType?.color ?? .blue)
                .frame(width: 40, height: 40)
                .background((drinkType?.color ?? .blue).opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(record.type)
                    .font(.subheadline.weight(.medium))
                Text(formatTime(record.time))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text("+\(record.amount) ml")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.blue)
        }
        .padding(12)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Add Water Sheet

struct AddWaterSheet: View {
    let viewModel: WaterViewModel
    let drinkType: DrinkType
    @Environment(\.dismiss) var dismiss
    @State private var amount: Int
    
    init(viewModel: WaterViewModel, drinkType: DrinkType) {
        self.viewModel = viewModel
        self.drinkType = drinkType
        _amount = State(initialValue: drinkType.defaultAmount)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                HStack {
                    Image(systemName: drinkType.icon)
                        .font(.title)
                        .foregroundStyle(drinkType.color)
                    Text(drinkType.name)
                        .font(.title2.weight(.bold))
                }
                
                Text("选择饮用量")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Picker("饮用量", selection: $amount) {
                    ForEach(1..<21) { i in
                        Text("\(i * 50) ml").tag(i * 50)
                    }
                }
                .pickerStyle(.wheel)
                
                Spacer()
            }
            .padding()
            .navigationTitle("添加饮水")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("添加") {
                        viewModel.addRecord(type: drinkType, amount: amount)
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Water Settings Sheet

struct WaterSettingsSheet: View {
    let viewModel: WaterViewModel
    let userName: String?
    @Environment(\.dismiss) var dismiss
    @State private var reminderEnabled: Bool
    @State private var startHour: Int
    @State private var startMinute: Int
    @State private var intervalMinutes: Int
    @State private var dailyGoal: Int
    
    init(viewModel: WaterViewModel, userName: String?) {
        self.viewModel = viewModel
        self.userName = userName
        _reminderEnabled = State(initialValue: viewModel.reminderEnabled)
        _startHour = State(initialValue: viewModel.startHour)
        _startMinute = State(initialValue: viewModel.startMinute)
        _intervalMinutes = State(initialValue: viewModel.intervalMinutes)
        _dailyGoal = State(initialValue: viewModel.dailyGoal)
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section("每日目标") {
                    Picker("目标量", selection: $dailyGoal) {
                        ForEach([1000, 1500, 2000, 2500, 3000, 3500, 4000], id: \.self) { goal in
                            Text("\(goal) ml").tag(goal)
                        }
                    }
                }
                
                Section("提醒设置") {
                    Toggle("开启提醒", isOn: $reminderEnabled)
                    
                    if reminderEnabled {
                        Picker("开始时间", selection: $startHour) {
                            ForEach(6..<22) { hour in
                                Text("\(hour):00").tag(hour)
                            }
                        }
                        
                        Picker("提醒间隔", selection: $intervalMinutes) {
                            ForEach([15, 30, 45, 60, 90, 120], id: \.self) { mins in
                                Text("\(mins) 分钟").tag(mins)
                            }
                        }
                    }
                }
                
                Section {
                    Button("发送测试通知") {
                        Task {
                            await NotificationManager.shared.sendTestNotification()
                        }
                    }
                }
            }
            .navigationTitle("喝水设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        viewModel.reminderEnabled = reminderEnabled
                        viewModel.startHour = startHour
                        viewModel.startMinute = startMinute
                        viewModel.intervalMinutes = intervalMinutes
                        viewModel.dailyGoal = dailyGoal
                        
                        Task {
                            await viewModel.scheduleReminder(userName: userName)
                        }
                        dismiss()
                    }
                }
            }
        }
    }
}

// Make DrinkType identifiable for sheet presentation
extension DrinkType: Hashable {
    static func == (lhs: DrinkType, rhs: DrinkType) -> Bool {
        lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

#Preview {
    WaterTrackerView()
        .environmentObject(AuthManager())
}
