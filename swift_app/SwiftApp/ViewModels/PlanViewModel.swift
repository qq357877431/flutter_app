// PlanViewModel.swift
// Plan list state management

import SwiftUI
import Foundation

@MainActor
@Observable
class PlanViewModel {
    var plans: [Plan] = []
    var selectedDate = Date()
    var isLoading = false
    var error: String?
    
    private let api = APIService.shared
    
    var completedCount: Int {
        plans.filter { $0.isCompleted }.count
    }
    
    var progress: Double {
        guard !plans.isEmpty else { return 0 }
        return Double(completedCount) / Double(plans.count)
    }
    
    func loadPlans() async {
        isLoading = true
        error = nil
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: selectedDate)
        
        do {
            plans = try await api.getPlans(date: dateString)
        } catch let apiError as APIError {
            error = apiError.errorDescription
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func setDate(_ date: Date) async {
        selectedDate = date
        await loadPlans()
    }
    
    func createPlan(content: String) async {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: selectedDate)
        
        do {
            let newPlan = try await api.createPlan(content: content, executionDate: dateString)
            plans.insert(newPlan, at: 0)
        } catch let apiError as APIError {
            error = apiError.errorDescription
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func togglePlan(_ plan: Plan) async {
        guard let id = plan.id else { return }
        let newStatus = plan.isCompleted ? "pending" : "completed"
        
        do {
            let updated = try await api.updatePlan(id: id, status: newStatus)
            if let index = plans.firstIndex(where: { $0.id == id }) {
                plans[index] = updated
            }
        } catch let apiError as APIError {
            error = apiError.errorDescription
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func deletePlan(_ plan: Plan) async {
        guard let id = plan.id else { return }
        
        do {
            try await api.deletePlan(id: id)
            plans.removeAll { $0.id == id }
        } catch let apiError as APIError {
            error = apiError.errorDescription
        } catch {
            self.error = error.localizedDescription
        }
    }
}
