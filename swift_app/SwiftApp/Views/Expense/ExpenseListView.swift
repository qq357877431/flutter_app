// ExpenseListView.swift
// Expense tracking view with iOS 26 glass design

import SwiftUI
import UIKit

struct ExpenseListView: View {
    @State private var viewModel = ExpenseViewModel()
    @State private var showAddSheet = false
    @State private var showFilterSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Summary Card
                    summaryCard
                    
                    // Expense List
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 200)
                    } else if viewModel.filteredExpenses.isEmpty {
                        emptyState
                    } else {
                        expenseList
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("消费记录")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 8) {
                        Button(action: { showFilterSheet = true }) {
                            Image(systemName: "calendar")
                                .padding(8)
                                .background(
                                    viewModel.selectedYear != nil || viewModel.selectedMonth != nil
                                        ? Color.green.opacity(0.15)
                                        : Color(uiColor: .systemGray5)
                                )
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(viewModel.selectedYear != nil ? Color.green : Color.clear, lineWidth: 1)
                                )
                        }
                        .tint(.green)
                        
                        Button(action: { showAddSheet = true }) {
                            HStack(spacing: 4) {
                                Image(systemName: "plus")
                                Text("记一笔")
                            }
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .foregroundStyle(.white)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "10B981"), Color(hex: "059669")],
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
                AddExpenseSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $showFilterSheet) {
                FilterSheet(viewModel: viewModel)
            }
            .task {
                await viewModel.loadExpenses()
            }
        }
    }
    
    // MARK: - Summary Card
    
    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.title2)
                    .padding(10)
                    .background(.white.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Text(viewModel.selectedYear != nil && viewModel.selectedMonth != nil
                     ? "\(viewModel.selectedYear!)年\(viewModel.selectedMonth!)月支出"
                     : "总支出")
                    .foregroundStyle(.white.opacity(0.9))
            }
            
            Text(formatCurrency(viewModel.selectedYear != nil || viewModel.selectedMonth != nil
                               ? viewModel.filteredTotal
                               : viewModel.total))
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.white)
            
            Text("共 \(viewModel.filteredExpenses.count) 笔消费")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(
            LinearGradient(
                colors: [Color(hex: "10B981"), Color(hex: "059669")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color(hex: "10B981").opacity(0.3), radius: 20, y: 10)
    }
    
    // MARK: - Expense List
    
    private var expenseList: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.filteredExpenses) { expense in
                ExpenseRow(expense: expense, onDelete: {
                    Task { await viewModel.deleteExpense(expense) }
                })
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "dollarsign.circle")
                .font(.system(size: 48))
                .foregroundStyle(.green.opacity(0.5))
                .padding(24)
                .background(Color.green.opacity(0.05))
                .clipShape(Circle())
            
            Text(viewModel.selectedYear != nil || viewModel.selectedMonth != nil
                 ? "该时间段暂无消费记录"
                 : "暂无消费记录")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: NSNumber(value: amount)) ?? "¥0.00"
    }
}

// MARK: - Expense Row

struct ExpenseRow: View {
    let expense: Expense
    let onDelete: () -> Void
    
    private var category: ExpenseCategory {
        ExpenseCategory(rawValue: expense.category) ?? .other
    }
    
    private var categoryColor: Color {
        Color(hex: category.colors[0])
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Category Icon
            Image(systemName: category.icon)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .background(
                    LinearGradient(
                        colors: category.colors.map { Color(hex: $0) },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.category)
                    .font(.headline)
                
                if let note = expense.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Amount & Time
            VStack(alignment: .trailing, spacing: 4) {
                Text("-\(formatCurrency(expense.amount))")
                    .font(.headline)
                    .foregroundStyle(.red)
                
                Text(formatTime(expense.createdAt))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            
            // Delete button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundStyle(.red.opacity(0.6))
            }
        }
        .padding(16)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: NSNumber(value: amount)) ?? "¥0.00"
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Add Expense Sheet

struct AddExpenseSheet: View {
    let viewModel: ExpenseViewModel
    @Environment(\.dismiss) var dismiss
    @State private var amount = ""
    @State private var selectedCategory = "餐饮"
    @State private var note = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Amount
                HStack {
                    Text("¥")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.green)
                    TextField("0.00", text: $amount)
                        .font(.system(size: 28, weight: .bold))
                        .keyboardType(.decimalPad)
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                
                // Categories
                VStack(alignment: .leading, spacing: 10) {
                    Text("分类")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                    
                    FlowLayout(spacing: 8) {
                        ForEach(ExpenseCategory.allCases, id: \.rawValue) { category in
                            CategoryChip(
                                category: category,
                                isSelected: selectedCategory == category.rawValue,
                                action: { selectedCategory = category.rawValue }
                            )
                        }
                    }
                }
                
                // Note
                TextField("添加备注...", text: $note)
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Spacer()
            }
            .padding()
            .navigationTitle("记一笔")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        if let amountValue = Double(amount), amountValue > 0 {
                            Task {
                                await viewModel.createExpense(
                                    amount: amountValue,
                                    category: selectedCategory,
                                    note: note.isEmpty ? nil : note
                                )
                                dismiss()
                            }
                        }
                    }
                    .disabled(Double(amount) == nil || (Double(amount) ?? 0) <= 0)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

struct CategoryChip: View {
    let category: ExpenseCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: category.icon)
                    .font(.caption)
                Text(category.rawValue)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .foregroundStyle(isSelected ? .white : Color(hex: category.colors[0]))
            .background(isSelected ? Color(hex: category.colors[0]) : Color(hex: category.colors[0]).opacity(0.1))
            .clipShape(Capsule())
        }
    }
}

// MARK: - Filter Sheet

struct FilterSheet: View {
    let viewModel: ExpenseViewModel
    @Environment(\.dismiss) var dismiss
    @State private var year: Int
    @State private var month: Int
    
    init(viewModel: ExpenseViewModel) {
        self.viewModel = viewModel
        let now = Date()
        _year = State(initialValue: viewModel.selectedYear ?? Calendar.current.component(.year, from: now))
        _month = State(initialValue: viewModel.selectedMonth ?? Calendar.current.component(.month, from: now))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Picker("年", selection: $year) {
                        ForEach(2020...Calendar.current.component(.year, from: Date()) + 1, id: \.self) { y in
                            Text("\(y)年").tag(y)
                        }
                    }
                    .pickerStyle(.wheel)
                    
                    Picker("月", selection: $month) {
                        ForEach(1...12, id: \.self) { m in
                            Text("\(m)月").tag(m)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                
                Button("重置筛选") {
                    viewModel.clearFilter()
                    dismiss()
                }
                .foregroundStyle(.orange)
            }
            .navigationTitle("筛选日期")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("确定") {
                        viewModel.setFilter(year: year, month: month)
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY), proposal: .unspecified)
        }
    }
    
    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, frames: [CGRect]) {
        var frames: [CGRect] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        let maxWidth = proposal.width ?? .infinity
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            frames.append(CGRect(origin: CGPoint(x: x, y: y), size: size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        
        return (CGSize(width: maxWidth, height: y + rowHeight), frames)
    }
}

#Preview {
    ExpenseListView()
}
