// PlanListView.swift
// Plan management view with iOS 26 glass design

import SwiftUI

struct PlanListView: View {
    @State private var viewModel = PlanViewModel()
    @State private var showAddSheet = false
    @State private var showDatePicker = false
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Date & Progress Card
                    dateProgressCard
                    
                    // Plan List
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 200)
                    } else if viewModel.plans.isEmpty {
                        emptyState
                    } else {
                        planList
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("每日计划")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 8) {
                        Button(action: { showDatePicker = true }) {
                            Image(systemName: "calendar")
                                .padding(8)
                                .background(.regularMaterial)
                                .clipShape(Circle())
                        }
                        
                        Button(action: { showAddSheet = true }) {
                            HStack(spacing: 4) {
                                Image(systemName: "plus")
                                Text("添加")
                            }
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .foregroundStyle(.white)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(Capsule())
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddPlanSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $showDatePicker) {
                DatePickerSheet(selectedDate: $viewModel.selectedDate) {
                    Task { await viewModel.loadPlans() }
                }
            }
            .task {
                await viewModel.loadPlans()
            }
        }
    }
    
    // MARK: - Date & Progress Card
    
    private var dateProgressCard: some View {
        HStack {
            HStack(spacing: 12) {
                Image(systemName: "calendar.badge.clock")
                    .font(.title2)
                    .foregroundStyle(Color(hex: "667eea"))
                    .frame(width: 44, height: 44)
                    .background(Color(hex: "667eea").opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(formattedDate)
                        .font(.headline)
                    Text("\(viewModel.plans.count) 个计划 · \(viewModel.completedCount) 已完成")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            if !viewModel.plans.isEmpty {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                    Circle()
                        .trim(from: 0, to: viewModel.progress)
                        .stroke(Color.green, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text("\(Int(viewModel.progress * 100))%")
                        .font(.caption2.weight(.bold))
                }
                .frame(width: 50, height: 50)
            }
        }
        .padding(16)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日 EEEE"
        return formatter.string(from: viewModel.selectedDate)
    }
    
    // MARK: - Plan List
    
    private var planList: some View {
        LazyVStack(spacing: 12) {
            ForEach(viewModel.plans) { plan in
                PlanRow(plan: plan) {
                    Task { await viewModel.togglePlan(plan) }
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        Task { await viewModel.deletePlan(plan) }
                    } label: {
                        Label("删除", systemImage: "trash")
                    }
                }
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 48))
                .foregroundStyle(Color(hex: "667eea").opacity(0.5))
                .padding(24)
                .background(Color(hex: "667eea").opacity(0.05))
                .clipShape(Circle())
            
            Text("暂无计划")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text("点击右上角 \"添加\" 按钮开始规划")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - Plan Row

struct PlanRow: View {
    let plan: Plan
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 16) {
                // Checkbox
                Image(systemName: plan.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(plan.isCompleted ? .green : .secondary)
                
                // Content
                Text(plan.content)
                    .strikethrough(plan.isCompleted)
                    .foregroundStyle(plan.isCompleted ? .secondary : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Add Plan Sheet

struct AddPlanSheet: View {
    let viewModel: PlanViewModel
    @Environment(\.dismiss) var dismiss
    @State private var content = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("输入计划内容...", text: $content, axis: .vertical)
                    .lineLimit(3...6)
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Spacer()
            }
            .padding()
            .navigationTitle("添加新计划")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("添加") {
                        Task {
                            await viewModel.createPlan(content: content)
                            dismiss()
                        }
                    }
                    .disabled(content.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Date Picker Sheet

struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    let onConfirm: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            DatePicker("选择日期", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .padding()
            .navigationTitle("选择日期")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("确定") {
                        onConfirm()
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    PlanListView()
        .environmentObject(AuthManager())
}
