// ExpenseViewModel.swift
// Expense list state management

import SwiftUI

@MainActor
@Observable
class ExpenseViewModel {
    var expenses: [Expense] = []
    var selectedYear: Int?
    var selectedMonth: Int?
    var isLoading = false
    var error: String?
    
    private let api = APIService.shared
    
    var filteredExpenses: [Expense] {
        expenses.filter { expense in
            if let year = selectedYear, Calendar.current.component(.year, from: expense.createdAt) != year {
                return false
            }
            if let month = selectedMonth, Calendar.current.component(.month, from: expense.createdAt) != month {
                return false
            }
            return true
        }
    }
    
    var total: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    var filteredTotal: Double {
        filteredExpenses.reduce(0) { $0 + $1.amount }
    }
    
    func loadExpenses() async {
        isLoading = true
        error = nil
        
        do {
            expenses = try await api.getExpenses()
        } catch let apiError as APIError {
            error = apiError.errorDescription
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func createExpense(amount: Double, category: String, note: String?) async {
        do {
            let newExpense = try await api.createExpense(amount: amount, category: category, note: note)
            expenses.insert(newExpense, at: 0)
        } catch let apiError as APIError {
            error = apiError.errorDescription
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func deleteExpense(_ expense: Expense) async {
        guard let id = expense.id else { return }
        
        do {
            try await api.deleteExpense(id: id)
            expenses.removeAll { $0.id == id }
        } catch let apiError as APIError {
            error = apiError.errorDescription
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func setFilter(year: Int?, month: Int?) {
        selectedYear = year
        selectedMonth = month
    }
    
    func clearFilter() {
        selectedYear = nil
        selectedMonth = nil
    }
}
