//
//  DashboardViewModel.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import Foundation

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var tasksByCategory: [(category: TaskCategory?, tasks: [Task])] = []
    @Published var tasksInProgress: [Task] = []
    @Published var errorMessage: String?
    
    init() {
    }
    
    func loadProgressTask() {
        TaskManagerDB.shared.getInProgressTasks { [weak self] result in
            switch result {
            case .success(let loadedTasks):
                let sortedTasks = loadedTasks.sorted {
                    $0.priority > $1.priority
                }
                self?.tasksInProgress = sortedTasks
            case .failure(let error):
                self?.errorMessage = "Failed to load tasks: \(error.localizedDescription)"
                print(self?.errorMessage ?? "Unknown error")
            }
        }
    }

    func loadGroupTasks() {
        TaskManagerDB.shared.getAllTasks { [weak self] result in
            switch result {
            case .success(let loadedTasks):
                // Group tasks by category
                let groupedTasks = Dictionary(grouping: loadedTasks) { $0.category }
                
                let sortedTasksByCategory = groupedTasks
                    .map { (category: $0.key, tasks: $0.value) }
                    .sorted { $0.tasks.count > $1.tasks.count }
                
                self?.tasksByCategory = sortedTasksByCategory
                
            case .failure(let error):
                self?.errorMessage = "Failed to load tasks: \(error.localizedDescription)"
                print(self?.errorMessage ?? "Unknown error")
            }
        }
    }
}
